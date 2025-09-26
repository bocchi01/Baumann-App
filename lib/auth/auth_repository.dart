import 'dart:async';

import '../models/user_model.dart';

abstract class IAuthRepository {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> registerWithEmail(String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithApple();
  Future<UserModel?> getCurrentUser();
  Future<void> signOut();
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
