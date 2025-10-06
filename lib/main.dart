import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'navigation/app_router.dart';
import 'screens/auth_wrapper.dart';
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
          debugPrint(
            '[Bootstrap] Firebase initialized in '
            '${stopwatch.elapsedMilliseconds}ms',
          );
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
    final AsyncValue<void> firebaseInit = ref.watch(
      firebaseInitializationProvider,
    );

    return CupertinoApp(
      title: 'Posture Coach',
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.cupertinoThemeData,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[Locale('en'), Locale('it')],
      builder: (BuildContext context, Widget? child) {
        if (child == null) {
          return const SizedBox.shrink();
        }
        return Theme(
          data: AppTheme.themeData,
          child: Material(type: MaterialType.transparency, child: child),
        );
      },
      home: firebaseInit.when(
        data: (_) => const AuthWrapper(),
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
    return const CupertinoPageScaffold(
      child: Center(child: CupertinoActivityIndicator()),
    );
  }
}

class _FirebaseErrorScreen extends StatelessWidget {
  const _FirebaseErrorScreen({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final CupertinoThemeData theme = CupertinoTheme.of(context);
    final TextStyle baseStyle = theme.textTheme.textStyle;

    return CupertinoPageScaffold(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                CupertinoIcons.exclamationmark_circle,
                size: 48,
                color: theme.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Impossibile inizializzare l\'app',
                style: baseStyle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.baumannPrimaryBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: baseStyle.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CupertinoButton.filled(
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
