import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_screen.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final User? user = snapshot.data;
        if (user == null) {
          return const AuthScreen();
        }

        return _ProfileDecisionGate(userId: user.uid);
      },
    );
  }
}

class _ProfileDecisionGate extends ConsumerWidget {
  const _ProfileDecisionGate({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DocumentSnapshot<Map<String, dynamic>>?> profileSnap =
        ref.watch(_profileLoaderProvider(userId));

    return profileSnap.when(
      data: (DocumentSnapshot<Map<String, dynamic>>? doc) {
        final Map<String, dynamic>? data = doc?.data();
        final String? assignedPathId =
            data != null ? data['assignedPathId'] as String? : null;

        if (assignedPathId == null || assignedPathId.isEmpty) {
          return const OnboardingScreen();
        }

        return const MainScreen();
      },
      error: (Object error, StackTrace stackTrace) => _ErrorScreen(
        message: error.toString(),
        onRetry: () => ref.invalidate(_profileLoaderProvider(userId)),
      ),
      loading: () => const _LoadingScreen(),
    );
  }
}

final _profileLoaderProvider = FutureProvider.autoDispose
    .family<DocumentSnapshot<Map<String, dynamic>>?, String>(
  (Ref ref, String userId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
      return snapshot;
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        return null;
      }
      rethrow;
    }
  },
);

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.error_outline,
                  color: Colors.redAccent, size: 42),
              const SizedBox(height: 16),
              Text(
                'Si è verificato un errore durante il caricamento del profilo.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Riprova'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
