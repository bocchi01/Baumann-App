import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/patient_profile.dart';

/// Repository per gestire il profilo paziente su Firestore
/// Include timeout, caching locale e gestione errori robusta
class PatientRepository {
  final FirebaseFirestore _firestore;
  static const String _collectionName = 'patients';
  static const Duration _defaultTimeout = Duration(seconds: 6);

  PatientRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Ottiene il profilo paziente da Firestore con timeout e cache fallback
  /// 
  /// Timeout di 6 secondi: se scade, tenta di usare la cache locale.
  /// Salva onboardingCompleted in SharedPreferences per uso offline.
  Future<PatientProfile> getProfile(String uid) async {
    try {
      // Fetch da Firestore con timeout
      final docSnapshot = await _firestore
          .collection(_collectionName)
          .doc(uid)
          .get()
          .timeout(_defaultTimeout);

      if (!docSnapshot.exists) {
        // Documento non esiste: nuovo utente, onboarding da fare
        return PatientProfile(
          uid: uid,
          onboardingCompleted: false,
        );
      }

      final data = docSnapshot.data()!;
      final profile = PatientProfile.fromFirestore(data, uid);

      // Salva in cache per uso futuro
      await _cacheOnboardingFlag(uid, profile.onboardingCompleted);

      return profile;
    } on FirebaseException catch (e) {
      // Errore Firestore: prova cache
      final cachedValue = await _getCachedOnboardingFlag(uid);
      if (cachedValue != null) {
        return _buildCachedProfile(uid, cachedValue);
      }
      throw Exception(
        'Errore caricamento profilo: ${e.message ?? 'Problema di rete'}',
      );
    } on TimeoutException {
      // Timeout: prova a usare la cache
      final cachedValue = await _getCachedOnboardingFlag(uid);
      if (cachedValue != null) {
        return _buildCachedProfile(uid, cachedValue);
      }
      throw Exception(
        'Timeout durante il caricamento del profilo. Controlla la connessione.',
      );
    } catch (e) {
      // Altri errori: tenta comunque la cache come fallback
      final cachedValue = await _getCachedOnboardingFlag(uid);
      if (cachedValue != null) {
        return _buildCachedProfile(uid, cachedValue);
      }
      rethrow;
    }
  }

  /// Aggiorna o crea il flag onboardingCompleted su Firestore
  /// 
  /// Usa merge: true per non sovrascrivere altri campi.
  /// Aggiorna anche i timestamp.
  Future<void> upsertOnboardingFlag(
    String uid,
    bool completed, {
    String? email,
  }) async {
    try {
      final data = <String, dynamic>{
        'onboardingCompleted': completed,
        'updatedAt': FieldValue.serverTimestamp(),
        if (email != null) 'email': email,
      };

      // Se il documento non esiste, aggiungi createdAt
      final docRef = _firestore.collection(_collectionName).doc(uid);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      await docRef.set(data, SetOptions(merge: true));

      // Aggiorna cache locale
      await _cacheOnboardingFlag(uid, completed);
    } on FirebaseException catch (e) {
      throw Exception(
        'Errore aggiornamento profilo: ${e.message ?? 'Riprova'}',
      );
    }
  }

  /// Salva i dati completi dell'onboarding su Firestore
  /// Include risposte, percorso assegnato e flag completamento
  Future<void> saveOnboardingData(
    String uid,
    PatientProfile profile,
  ) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc(uid);
      final docSnapshot = await docRef.get();

      final data = profile.toFirestore();
      
      // Server timestamp per updatedAt
      data['updatedAt'] = FieldValue.serverTimestamp();

      // Se nuovo documento, aggiungi createdAt
      if (!docSnapshot.exists) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      await docRef.set(data, SetOptions(merge: true));

      // Aggiorna cache locale
      await _cacheOnboardingFlag(uid, profile.onboardingCompleted);
    } on FirebaseException catch (e) {
      throw Exception(
        'Errore salvataggio onboarding: ${e.message ?? 'Riprova'}',
      );
    }
  }

  /// Salva il flag onboarding in SharedPreferences
  Future<void> _cacheOnboardingFlag(String uid, bool completed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboardingCompleted:$uid', completed);
    } catch (_) {
      // Ignora errori di cache: non bloccare il flusso
    }
  }

  /// Legge il flag onboarding da SharedPreferences
  Future<bool?> _getCachedOnboardingFlag(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('onboardingCompleted:$uid');
    } catch (_) {
      return null;
    }
  }

  /// Costruisce un profilo minimo dalla cache
  /// Usato quando Firestore non è raggiungibile ma abbiamo dati salvati
  PatientProfile _buildCachedProfile(
    String uid,
    bool onboardingCompleted,
  ) {
    return PatientProfile(
      uid: uid,
      onboardingCompleted: onboardingCompleted,
    );
  }
}
