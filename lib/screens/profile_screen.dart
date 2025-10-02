import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_screen.dart';

/// Mantiene la compatibilità con eventuali riferimenti esistenti al
/// `ProfileScreen`, reindirizzando alla nuova schermata delle impostazioni.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SettingsScreen();
  }
}
