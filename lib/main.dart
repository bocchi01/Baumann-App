import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'navigation/app_router.dart';
import 'screens/auth_screen.dart';
import 'theme/theme.dart';
import 'utils/network_probe.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(
    const ProviderScope(
      child: _LocalNetworkProbeInitializer(child: PostureApp()),
    ),
  );
}

class PostureApp extends StatelessWidget {
  const PostureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Posture Coach',
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const AuthScreen(),
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

    // Trigger the probe right away and once more shortly after the first frame.
    ensureLocalNetworkPermission();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ensureLocalNetworkPermission();
      Timer(const Duration(seconds: 2), ensureLocalNetworkPermission);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
