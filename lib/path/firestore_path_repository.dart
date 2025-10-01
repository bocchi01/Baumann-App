import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/path_module.dart';
import '../models/posture_path.dart';
import 'path_repository.dart';

export 'path_repository.dart';

final Provider<IPathRepository> pathRepositoryProvider =
    Provider<IPathRepository>((Ref ref) {
  return FirestorePathRepository();
});

class FirestorePathRepository implements IPathRepository {
  FirestorePathRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
    IPathRepository? fallbackRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = firebaseAuth ?? FirebaseAuth.instance,
        _fallbackRepository = fallbackRepository ?? MockPathRepository();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final IPathRepository _fallbackRepository;

  CollectionReference<Map<String, dynamic>> get _userProgressCollection =>
      _firestore.collection('user_progress');

  @override
  Future<PosturePath> fetchUserPath(String userId) async {
    final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await _firestore.collection('users').doc(userId).get();

    String assignedPathId =
        (userSnapshot.data()?['assignedPathId'] as String?)?.trim() ?? '';
    if (assignedPathId.isEmpty) {
      assignedPathId = 'percorso_ufficio_01';
    }

    DocumentSnapshot<Map<String, dynamic>> pathSnapshot =
        await _firestore.collection('paths').doc(assignedPathId).get();

    if (!pathSnapshot.exists && assignedPathId != 'percorso_ufficio_01') {
      pathSnapshot =
          await _firestore.collection('paths').doc('percorso_ufficio_01').get();
      assignedPathId = 'percorso_ufficio_01';
    }

    if (!pathSnapshot.exists) {
      return _fallbackRepository.fetchUserPath(userId);
    }

    final Map<String, dynamic> pathData =
        Map<String, dynamic>.from(pathSnapshot.data() ?? <String, dynamic>{})
          ..putIfAbsent('id', () => pathSnapshot.id);

    final List<PathModule> modules = await _loadModules(pathSnapshot.reference);

    return PosturePath(
      id: pathData['id'] as String,
      title: (pathData['title'] as String?) ?? 'Percorso personalizzato',
      description: (pathData['description'] as String?) ?? '',
      durationInWeeks: (pathData['durationInWeeks'] is num)
          ? (pathData['durationInWeeks'] as num).toInt()
          : modules.length,
      modules: modules,
    );
  }

  @override
  Future<void> markSessionAsComplete(String sessionId) async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      return;
    }

    await _userProgressCollection.doc(userId).set(
      <String, dynamic>{
        'completedSessions': FieldValue.arrayUnion(<String>[sessionId]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<Set<String>> getCompletedSessionIds() async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      return <String>{};
    }

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _userProgressCollection.doc(userId).get();

    if (!snapshot.exists) {
      return <String>{};
    }

    final Map<String, dynamic>? data = snapshot.data();
    if (data == null) {
      return <String>{};
    }

    final dynamic rawCompleted = data['completedSessions'];
    if (rawCompleted is Iterable) {
      return rawCompleted.whereType<String>().toSet();
    }

    return <String>{};
  }

  Future<List<PathModule>> _loadModules(
    DocumentReference<Map<String, dynamic>> pathRef,
  ) async {
    final QuerySnapshot<Map<String, dynamic>> moduleSnapshot =
        await pathRef.collection('modules').orderBy('weekNumber').get();

    final List<PathModule> modules = <PathModule>[];
    for (final QueryDocumentSnapshot<Map<String, dynamic>> moduleDoc
        in moduleSnapshot.docs) {
      final Map<String, dynamic> moduleData =
          Map<String, dynamic>.from(moduleDoc.data());
      moduleData['id'] ??= moduleDoc.id;

      final QuerySnapshot<Map<String, dynamic>> sessionsSnapshot =
          await moduleDoc.reference
              .collection('sessions')
              .orderBy('dayNumber')
              .get();

      final List<Map<String, dynamic>> sessionJson = sessionsSnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> sessionDoc) {
        final Map<String, dynamic> sessionData =
            Map<String, dynamic>.from(sessionDoc.data());
        sessionData['id'] ??= sessionDoc.id;
        return sessionData;
      }).toList(growable: false);

      final Map<String, dynamic> moduleJson = <String, dynamic>{
        ...moduleData,
        'sessions': sessionJson,
      };
      modules.add(PathModule.fromJson(moduleJson));
    }

    return modules;
  }

  @override
  Future<Map<String, dynamic>> getUserProgressData() async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      return <String, dynamic>{};
    }

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _userProgressCollection.doc(userId).get();

    if (!snapshot.exists || snapshot.data() == null) {
      return <String, dynamic>{};
    }

    return Map<String, dynamic>.from(snapshot.data()!);
  }
}
