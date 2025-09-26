import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import 'auth_repository.dart';

/// Real Firebase Authentication implementation
class FirebaseAuthRepository implements IAuthRepository {
  FirebaseAuthRepository() : _auth = FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    }
  }

  @override
  Future<UserModel> registerWithEmail(String email, String password) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebaseUser(credential.user!, isNewUser: true);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    // TODO: Implement Google Sign-In with google_sign_in package
    throw UnimplementedError('Google Sign-In sarà implementato prossimamente');
  }

  @override
  Future<UserModel> signInWithApple() async {
    // TODO: Implement Apple Sign-In with sign_in_with_apple package  
    throw UnimplementedError('Apple Sign-In sarà implementato prossimamente');
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _userFromFirebaseUser(firebaseUser);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Converts Firebase User to our UserModel
  UserModel _userFromFirebaseUser(User user, {bool isNewUser = false}) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? _extractNameFromEmail(user.email ?? ''),
      subscriptionStatus: isNewUser ? 'active_trial' : 'free',
      trialStartDate: isNewUser ? DateTime.now() : null,
    );
  }

  /// Extracts a reasonable display name from email
  String _extractNameFromEmail(String email) {
    if (email.isEmpty) return 'Utente';
    final String username = email.split('@').first;
    // Capitalize first letter if possible
    return username.isNotEmpty 
        ? '${username[0].toUpperCase()}${username.substring(1)}'
        : 'Utente';
  }

  /// Translates Firebase error codes to Italian messages
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Nessun utente trovato con questa email.';
      case 'wrong-password':
        return 'Password non corretta.';
      case 'email-already-in-use':
        return 'Esiste già un account con questa email.';
      case 'weak-password':
        return 'La password è troppo debole. Deve contenere almeno 6 caratteri.';
      case 'invalid-email':
        return 'Formato email non valido.';
      case 'invalid-credential':
        return 'Credenziali non valide. Verifica email e password.';
      case 'user-disabled':
        return 'Questo account è stato disabilitato.';
      case 'too-many-requests':
        return 'Troppi tentativi falliti. Riprova più tardi.';
      case 'operation-not-allowed':
        return 'Operazione non consentita. Contatta il supporto.';
      case 'keychain-error':
        return 'Accesso al portachiavi negato. Su macOS apri Runner in Xcode, assegna il tuo Team e assicurati che la capacità "Keychain Sharing" sia attiva, poi ricompila.';
      case 'network-request-failed':
        return 'Errore di connessione. Verifica la tua connessione internet.';
      default:
        return 'Errore di autenticazione: $errorCode';
    }
  }
}