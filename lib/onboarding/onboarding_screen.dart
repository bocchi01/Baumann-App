import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../auth/patient_repository.dart';
import '../screens/main_screen.dart';
import '../shared/ui/loading_error.dart';

/// Schermata onboarding (stub)
/// In futuro: questionario completo su tempo disponibile, preferenze, ecc.
/// Per ora: semplice conferma per settare onboardingCompleted = true
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _isLoading = false;

  Future<void> _completeOnboarding() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('❌ OnboardingScreen: Nessun utente autenticato');
      return;
    }

    print('🔄 OnboardingScreen: Inizio completamento onboarding per ${user.uid}');
    setState(() => _isLoading = true);

    try {
      final repository = PatientRepository();
      await repository.upsertOnboardingFlag(user.uid, true);
      
      print('✅ OnboardingScreen: Flag onboarding aggiornato con successo');
      
      // WORKAROUND: AuthGate usa un FutureBuilder che non si aggiorna automaticamente
      // quando il profilo Firestore cambia. Quindi navighiamo direttamente a MainScreen.
      print('🚀 OnboardingScreen: Onboarding completato, navigazione a MainScreen');
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (_) => const MainScreen()),
          (route) => false, // Rimuove tutte le route precedenti
        );
      }
    } catch (e) {
      print('❌ OnboardingScreen: Errore durante completamento: $e');
      if (mounted) {
        await ErrorDisplay.showErrorDialog(
          context,
          'Errore durante la configurazione:\n\n$e',
          onRetry: _completeOnboarding,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Icona o illustrazione
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A84FF).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.person_badge_plus,
                  size: 60,
                  color: Color(0xFF0A84FF),
                ),
              ),
              const SizedBox(height: 32),
              // Titolo
              const Text(
                'Benvenuto!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
              const SizedBox(height: 16),
              // Descrizione
              const Text(
                'Definisci le tue preferenze per iniziare il percorso verso una postura migliore',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: CupertinoColors.secondaryLabel,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),
              // CTA primaria
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: _isLoading ? null : _completeOnboarding,
                  disabledColor: CupertinoColors.systemGrey4,
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _isLoading
                      ? const CupertinoActivityIndicator(
                          color: CupertinoColors.white,
                        )
                      : const Text(
                          'Inizia il tuo percorso',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Nota rassicurante
              const Text(
                'Potrai personalizzare il tuo percorso in qualsiasi momento',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.tertiaryLabel,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
