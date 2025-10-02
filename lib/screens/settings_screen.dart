import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';
import '../theme/theme.dart';
import 'auth_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: <Widget>[
            const _SectionHeader(label: 'Account'),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Modifica Profilo'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showPlaceholder(context, 'Modifica Profilo'),
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Cambia Password'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showPlaceholder(context, 'Cambia Password'),
            ),
            const SizedBox(height: 28),
            const _SectionHeader(label: 'Impostazioni App'),
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Notifiche'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showPlaceholder(context, 'Notifiche'),
            ),
            ListTile(
              leading: const Icon(Icons.tune_rounded),
              title: const Text('Preferenze'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showPlaceholder(context, 'Preferenze'),
            ),
            const SizedBox(height: 36),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout'),
              style: FilledButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppTheme.baumannPrimaryBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              onPressed: () => _handleLogout(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final bool success =
        await ref.read(authControllerProvider.notifier).signOut();

    if (!context.mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const AuthScreen(),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      final String message = ref.read(authControllerProvider).errorMessage ??
          'Impossibile completare il logout.';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(message)),
        );
    }
  }

  void _showPlaceholder(BuildContext context, String action) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('La sezione "$action" sarà presto disponibile.'),
        ),
      );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
