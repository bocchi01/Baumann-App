import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../models/user_model.dart';
import '../services/data_uploader_service.dart';
import '../theme/theme.dart';
import 'auth_screen.dart';
import 'paywall_screen.dart';
import 'specialists_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ProfileState state = ref.watch(profileControllerProvider);
    final UserModel? user = state.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilo'),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: state.isLoading && user == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  children: <Widget>[
                    if (state.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          state.errorMessage!,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: Theme.of(context).colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    _SubscriptionStatusCard(
                      user: user,
                      onUpgrade: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<PaywallScreen>(
                            builder: (_) => const PaywallScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const _MasterclassSection(),
                    const SizedBox(height: 24),
                    const _ConsultationCard(),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _handleSeedUpload(context),
                      child: const Text('CARICA DATI DI PROVA'),
                    ),
                    const SizedBox(height: 24),
                    _LogoutSection(onLogout: () => _handleLogout(context, ref)),
                  ],
                ),
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
        MaterialPageRoute<AuthScreen>(
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
}

Future<void> _handleSeedUpload(BuildContext context) async {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(content: Text('Caricamento dati di prova in corso...')),
    );

  try {
    await DataUploaderService().uploadData();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Dati di prova caricati con successo.')),
      );
  } catch (error, stackTrace) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Errore nel caricamento: $error')),
      );
    debugPrint('Seed upload failed: $error\n$stackTrace');
  }
}

class _SubscriptionStatusCard extends StatelessWidget {
  const _SubscriptionStatusCard({
    required this.user,
    required this.onUpgrade,
  });

  final UserModel? user;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final String status = user?.subscriptionStatus ?? 'free';
    final bool isPremium = status == 'active_premium';
    final bool isTrial = status == 'active_trial';
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  isPremium ? Icons.verified_user : Icons.workspace_premium,
                  size: 36,
                  color: isPremium
                      ? AppTheme.baumannPrimaryBlue
                      : AppTheme.baumannAccentOrange,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    isPremium
                        ? 'Il Tuo Piano: Premium'
                        : 'Il Tuo Piano: ${isTrial ? 'Prova Gratuita' : 'Gratuito'}',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              isPremium
                  ? 'Hai accesso a tutti i contenuti esclusivi. Grazie per il tuo supporto!'
                  : 'Passa a Premium per sbloccare tutti i vantaggi personalizzati del tuo percorso.',
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.black.withValues(alpha: 0.7),
              ),
            ),
            if (!isPremium) ...<Widget>[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.baumannAccentOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: onUpgrade,
                  child: const Text('✨ FAI L\'UPGRADE'),
                ),
              ),
            ] else ...<Widget>[
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {},
                child: const Text('Gestisci Abbonamento'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MasterclassSection extends StatelessWidget {
  const _MasterclassSection();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.video_library_outlined,
                    color: AppTheme.baumannPrimaryBlue),
                const SizedBox(width: 12),
                Text(
                  'Masterclass Esclusive',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Accedi alle lezioni approfondite pensate dai nostri esperti per migliorare la tua postura giorno dopo giorno.',
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.black.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsultationCard extends StatelessWidget {
  const _ConsultationCard();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 1.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<SpecialistsScreen>(
              builder: (_) => const SpecialistsScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(
                Icons.calendar_month_outlined,
                color: AppTheme.baumannPrimaryBlue,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Prenota una Consulenza 1-a-1',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Scegli il professionista più adatto per una sessione personalizzata in videochiamata.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.black.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.baumannSecondaryBlue),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutSection extends StatelessWidget {
  const _LogoutSection({required this.onLogout});

  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Row(
              children: <Widget>[
                Icon(Icons.logout, color: Colors.redAccent),
                SizedBox(width: 12),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onLogout,
                child: const Text('Esci dal tuo account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
