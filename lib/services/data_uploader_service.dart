import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class DataUploaderService {
  DataUploaderService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _seedAssetPath = 'assets/database_seed.json';

  Future<void> uploadData() async {
    final String jsonString = await rootBundle.loadString(_seedAssetPath);
    final Map<String, dynamic> data = json.decode(jsonString) as Map<String, dynamic>;

    await _uploadExercises(data['exercises'] as List<dynamic>?);
    await _uploadPaths(data['paths'] as List<dynamic>?);
  }

  Future<void> _uploadExercises(List<dynamic>? exercises) async {
    if (exercises == null) {
      debugPrint('[DataUploader] Nessun esercizio da caricare.');
      return;
    }

    debugPrint('[DataUploader] Caricamento esercizi...');
    final WriteBatch batch = _firestore.batch();

    for (final dynamic exercise in exercises) {
      if (exercise is Map<String, dynamic> && exercise['id'] != null) {
        final DocumentReference<Map<String, dynamic>> docRef =
            _firestore.collection('exercises').doc(exercise['id'] as String);
        batch.set(docRef, exercise);
        debugPrint('[DataUploader] Accodato esercizio ${exercise['id']}');
      }
    }

    await batch.commit();
    debugPrint('[DataUploader] Esercizi caricati con successo.');
  }

  Future<void> _uploadPaths(List<dynamic>? paths) async {
    if (paths == null) {
      debugPrint('[DataUploader] Nessun percorso da caricare.');
      return;
    }

    debugPrint('[DataUploader] Caricamento percorsi...');

    for (final dynamic path in paths) {
      if (path is! Map<String, dynamic> || path['id'] == null) {
        continue;
      }

      final String pathId = path['id'] as String;
      final List<dynamic>? modules = path['modules'] as List<dynamic>?;

      final Map<String, dynamic> pathData = Map<String, dynamic>.from(path)
        ..remove('modules');

  await _firestore.collection('paths').doc(pathId).set(pathData);
  debugPrint('[DataUploader] Percorso $pathId caricato.');

      if (modules == null) {
        continue;
      }

      for (final dynamic module in modules) {
        if (module is! Map<String, dynamic> || module['id'] == null) {
          continue;
        }

        final String moduleId = module['id'] as String;
        final List<dynamic>? sessions = module['sessions'] as List<dynamic>?;

        final Map<String, dynamic> moduleData = Map<String, dynamic>.from(module)
          ..remove('sessions');

        final DocumentReference<Map<String, dynamic>> moduleRef = _firestore
            .collection('paths')
            .doc(pathId)
            .collection('modules')
            .doc(moduleId);

  await moduleRef.set(moduleData);
  debugPrint('[DataUploader] Modulo $moduleId caricato per percorso $pathId.');

        if (sessions == null) {
          continue;
        }

        for (final dynamic session in sessions) {
          if (session is! Map<String, dynamic> || session['id'] == null) {
            continue;
          }

          final String sessionId = session['id'] as String;

          final Map<String, dynamic> sessionData = Map<String, dynamic>.from(session);

          await moduleRef.collection('sessions').doc(sessionId).set(sessionData);
          debugPrint(
            '[DataUploader] Sessione $sessionId caricata per modulo $moduleId (percorso $pathId).',
          );
        }
      }
    }

    debugPrint('[DataUploader] Percorsi caricati con successo.');
  }
}
