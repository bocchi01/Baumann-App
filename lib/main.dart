import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'navigation/app_router.dart';
import 'screens/auth_screen.dart';
import 'theme/theme.dart';
import 'utils/network_probe.dart';

final FutureProvider<void> firebaseInitializationProvider =
    FutureProvider<void>((Ref ref) {
  return Future<void>(() async {
    final Stopwatch? stopwatch = kDebugMode ? (Stopwatch()..start()) : null;

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (stopwatch != null) {
      stopwatch.stop();
      debugPrint('[Bootstrap] Firebase initialized in '
          '${stopwatch.elapsedMilliseconds}ms');
    }
  });
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: _LocalNetworkProbeInitializer(child: PostureApp()),
    ),
  );
}

class PostureApp extends ConsumerWidget {
  const PostureApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<void> firebaseInit =
        ref.watch(firebaseInitializationProvider);

    return MaterialApp(
      title: 'Posture Coach',
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: firebaseInit.when(
        data: (_) => const AuthScreen(),
        loading: () => const _FirebaseLoadingScreen(),
        error: (Object error, StackTrace stackTrace) => _FirebaseErrorScreen(
          error: error,
          onRetry: () => ref.invalidate(firebaseInitializationProvider),
        ),
      ),
    );
  }
}

class _FirebaseLoadingScreen extends StatelessWidget {
  const _FirebaseLoadingScreen();

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint('[Bootstrap] Rendering Firebase loading screen.');
    }
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _FirebaseErrorScreen extends StatelessWidget {
  const _FirebaseErrorScreen({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Impossibile inizializzare l\'app',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Riprova'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocalNetworkProbeInitializer extends StatefulWidget {
  const _LocalNetworkProbeInitializer({required this.child});

  final Widget child;

  @override
  State<_LocalNetworkProbeInitializer> createState() =>
      _LocalNetworkProbeInitializerState();
}

class _LocalNetworkProbeInitializerState
    extends State<_LocalNetworkProbeInitializer> {
  @override
  void initState() {
    super.initState();

    // Trigger the probe once after the first frame so it doesn't block startup.
    if (kDebugMode) {
      debugPrint('[Bootstrap] Scheduling local network probe post-frame.');
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) {
        debugPrint('[Bootstrap] Local network probe starting.');
      }
      ensureLocalNetworkPermission();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
