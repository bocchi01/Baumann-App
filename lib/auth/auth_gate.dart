import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../auth/patient_repository.dart';
import '../models/patient_profile.dart';
import '../shared/ui/loading_error.dart';
import 'login_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../screens/main_screen.dart';

/// Gate che gestisce il routing basato sullo stato di autenticazione
/// e sul completamento dell'onboarding dell'utente
///
/// Stati:
/// - null (non autenticato) → LoginScreen
/// - User (autenticato) → fetch profile da Firestore:
///   - onboardingCompleted == false → OnboardingScreen
///   - onboardingCompleted == true → MainScreen
///   - errore/timeout → ErrorDisplay con retry e logout
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading: ancora in attesa del primo evento dello stream
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(child: LoadingIndicator(message: 'Caricamento...')),
          );
        }

        // Errore nello stream (raro)
        if (snapshot.hasError) {
          return CupertinoPageScaffold(
            child: Center(
              child: ErrorDisplay(
                message: 'Errore durante il controllo dell\'autenticazione.',
                onRetry: () {
                  // Forza rebuild
                  (context as Element).markNeedsBuild();
                },
              ),
            ),
          );
        }

        final user = snapshot.data;

        // Utente non autenticato → LoginScreen
        if (user == null) {
          return const LoginScreen();
        }

        // Utente autenticato → verifica profilo e onboarding
        // Deleghiamo a _ProfileLoader (con FutureBuilder)
        return _ProfileLoader(user: user);
      },
    );
  }
}

/// Widget interno che carica il profilo utente e gestisce il routing
class _ProfileLoader extends StatefulWidget {
  final User user;

  const _ProfileLoader({required this.user});

  @override
  State<_ProfileLoader> createState() => _ProfileLoaderState();
}

class _ProfileLoaderState extends State<_ProfileLoader> {
  late Future<PatientProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    print('🔄 AuthGate: Caricamento profilo per ${widget.user.uid}');
    _profileFuture = PatientRepository().getProfile(widget.user.uid).then((profile) {
      print('✅ AuthGate: Profilo caricato - onboardingCompleted: ${profile.onboardingCompleted}');
      return profile;
    }).catchError((e) {
      print('❌ AuthGate: Errore caricamento profilo: $e');
      throw e;
    });
  }

  // Metodo pubblico per forzare il reload del profilo
  void refreshProfile() {
    print('🔄 AuthGate: Refresh forzato del profilo');
    setState(() {
      _loadProfile();
    });
  }

  void _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // AuthGate rileverà il cambio e mostrerà LoginScreen
    } catch (e) {
      if (mounted) {
        ErrorDisplay.showErrorDialog(
          context,
          'Errore durante il logout. Riprova.',
        );
      }
    }
  }

  void _handleRetry() {
    setState(() {
      _loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PatientProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(
              child: LoadingIndicator(message: 'Caricamento profilo...'),
            ),
          );
        }

        // Errore
        if (snapshot.hasError) {
          return CupertinoPageScaffold(
            child: SafeArea(
              child: Column(
                children: [
                  // Errore principale
                  Expanded(
                    child: ErrorDisplay(
                      message: snapshot.error.toString().contains('timeout')
                          ? 'Tempo scaduto durante il caricamento del profilo. '
                                'Controlla la connessione e riprova.'
                          : 'Errore durante il caricamento del profilo.',
                      onRetry: _handleRetry,
                    ),
                  ),
                  // Pulsante logout
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CupertinoButton(
                      onPressed: _handleLogout,
                      child: const Text(
                        'Esci dall\'account',
                        style: TextStyle(color: CupertinoColors.destructiveRed),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final profile = snapshot.data;

        // Profilo non trovato (caso improbabile se l'utente è appena registrato)
        if (profile == null) {
          // Crea profilo base e vai all'onboarding
          return const OnboardingScreen();
        }

        // Profilo trovato: routing basato su onboardingCompleted
        if (!profile.onboardingCompleted) {
          return const OnboardingScreen();
        }

        // Onboarding completato → MainScreen
        return const MainScreen();
      },
    );
  }
}
