import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

abstract class IAuthRepository {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> registerWithEmail(String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithApple();
  Future<UserModel?> getCurrentUser();
  Future<void> signOut();
}

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
      return _userFromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    // TODO: Implement Google Sign-In with google_sign_in package
    throw UnimplementedError('Google Sign-In not implemented yet');
  }

  @override
  Future<UserModel> signInWithApple() async {
    // TODO: Implement Apple Sign-In with sign_in_with_apple package
    throw UnimplementedError('Apple Sign-In not implemented yet');
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

  UserModel _userFromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? 'User',
      subscriptionStatus: 'free', // Default status, can be updated from Firestore
    );
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Nessun utente trovato con questa email.';
      case 'wrong-password':
        return 'Password non corretta.';
      case 'email-already-in-use':
        return 'Esiste già un account con questa email.';
      case 'weak-password':
        return 'La password è troppo debole.';
      case 'invalid-email':
        return 'Email non valida.';
      default:
        return 'Errore di autenticazione: $errorCode';
    }
  }
}

class MockAuthRepository implements IAuthRepository {
  MockAuthRepository();

  final Map<String, _MockUser> _users = <String, _MockUser>{
    'test@test.com': const _MockUser(
      user: UserModel(
        id: '123',
        email: 'test@test.com',
        name: 'Test User',
        subscriptionStatus: 'free',
      ),
      password: 'password',
    ),
  };
  UserModel? _currentUser;

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    final _MockUser? entry = _users[email];
    if (entry == null || entry.password != password) {
      throw Exception('Credenziali non valide.');
    }
    _currentUser = entry.user;
    return entry.user;
  }

  @override
  Future<UserModel> registerWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    final UserModel user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: 'Nuovo Utente',
      subscriptionStatus: 'active_trial',
      trialStartDate: DateTime.now(),
    );

    _users[email] = _MockUser(user: user, password: password);
    _currentUser = user;
    return user;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 2));
    const String email = 'google.user@test.com';
    final UserModel user = UserModel(
      id: 'google_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: 'Google User',
      subscriptionStatus: 'active_trial',
    );
    _users[email] = _MockUser(user: user, password: 'oauth');
    _currentUser = user;
    return user;
  }

  @override
  Future<UserModel> signInWithApple() async {
    await Future.delayed(const Duration(seconds: 2));
    const String email = 'apple.user@test.com';
    final UserModel user = UserModel(
      id: 'apple_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: 'Apple User',
      subscriptionStatus: 'active_standard',
    );
    _users[email] = _MockUser(user: user, password: 'oauth');
    _currentUser = user;
    return user;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }
}

class _MockUser {
  const _MockUser({required this.user, required this.password});

  final UserModel user;
  final String password;
}
