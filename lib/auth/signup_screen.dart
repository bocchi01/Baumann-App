import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../auth/patient_repository.dart';
import '../shared/ui/loading_error.dart';

/// Schermata di registrazione con validazione completa
/// Crea account Firebase e profilo Firestore iniziale
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Valida l'email con regex
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Form valido: email valida, password >= 8 caratteri, password match
  bool get _isFormValid {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    return _isValidEmail(email) &&
        password.length >= 8 &&
        password == confirmPassword;
  }

  /// Gestisce la creazione dell'account
  Future<void> _handleSignup() async {
    if (!_isFormValid || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Crea utente Firebase
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Crea profilo paziente su Firestore
      final repository = PatientRepository();
      await repository.upsertOnboardingFlag(
        uid,
        false, // Onboarding da completare
        email: email,
      );

      // AuthGate gestirà automaticamente il routing verso OnboardingScreen
      // quando rileva onboardingCompleted = false
    } on FirebaseAuthException catch (e) {
      // Gestione errori Firebase con messaggi in italiano
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Questa email è già registrata. Prova ad accedere.';
          break;
        case 'invalid-email':
          message = 'L\'email inserita non è valida';
          break;
        case 'weak-password':
          message = 'La password è troppo debole. Usa almeno 8 caratteri.';
          break;
        case 'network-request-failed':
          message =
              'Problema di rete. Controlla la connessione e riprova.';
          break;
        default:
          message = 'Errore Firebase: ${e.message ?? e.code}';
      }

      if (mounted) {
        await ErrorDisplay.showErrorDialog(context, message);
      }
    } catch (e) {
      if (mounted) {
        // Mostra errore dettagliato per debug
        final errorMessage = e.toString();
        String userMessage;
        
        if (errorMessage.contains('permission-denied') || 
            errorMessage.contains('PERMISSION_DENIED')) {
          userMessage = 'Errore permessi Firestore.\n\n'
              'Vai su Firebase Console → Firestore Database → Rules\n'
              'e imposta:\n\n'
              'rules_version = \'2\';\n'
              'service cloud.firestore {\n'
              '  match /databases/{database}/documents {\n'
              '    match /patients/{userId} {\n'
              '      allow read, write: if request.auth != null && request.auth.uid == userId;\n'
              '    }\n'
              '  }\n'
              '}';
        } else {
          userMessage = 'Errore durante la registrazione:\n\n$errorMessage';
        }
        
        await ErrorDisplay.showErrorDialog(context, userMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Mappa codici errore Firebase in messaggi italiani
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Questa email è già registrata.';
      case 'invalid-email':
        return 'Email non valida.';
      case 'weak-password':
        return 'Password troppo debole.';
      case 'network-request-failed':
        return 'Problema di rete. Controlla la connessione.';
      default:
        return 'Errore durante la registrazione. Riprova.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A84FF),
                  Color(0xFF0051D5),
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        // Back button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: const Icon(
                              CupertinoIcons.back,
                              color: CupertinoColors.white,
                              size: 32,
                            ),
                          ),
                        ),
                        // Titolo
                        const Text(
                          'Crea Account',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Inizia il tuo percorso verso una postura migliore',
                          style: TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        // Card Form
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: CupertinoColors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.black
                                    .withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Email
                              _buildTextField(
                                controller: _emailController,
                                placeholder: 'Email',
                                prefix: const Icon(
                                  CupertinoIcons.mail,
                                  color: Color(0xFF0A84FF),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 16),
                              // Password
                              _buildTextField(
                                controller: _passwordController,
                                placeholder: 'Password (min 8 caratteri)',
                                prefix: const Icon(
                                  CupertinoIcons.lock,
                                  color: Color(0xFF0A84FF),
                                ),
                                obscureText: _obscurePassword,
                                suffix: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  child: Icon(
                                    _obscurePassword
                                        ? CupertinoIcons.eye
                                        : CupertinoIcons.eye_slash,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 16),
                              // Conferma Password
                              _buildTextField(
                                controller: _confirmPasswordController,
                                placeholder: 'Conferma Password',
                                prefix: const Icon(
                                  CupertinoIcons.lock,
                                  color: Color(0xFF0A84FF),
                                ),
                                obscureText: _obscureConfirmPassword,
                                suffix: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                  child: Icon(
                                    _obscureConfirmPassword
                                        ? CupertinoIcons.eye
                                        : CupertinoIcons.eye_slash,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                              // Indicatore validazione password
                              if (_passwordController.text.isNotEmpty &&
                                  _confirmPasswordController.text.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      _passwordController.text ==
                                              _confirmPasswordController.text
                                          ? CupertinoIcons.checkmark_circle_fill
                                          : CupertinoIcons.xmark_circle_fill,
                                      size: 16,
                                      color: _passwordController.text ==
                                              _confirmPasswordController.text
                                          ? CupertinoColors.systemGreen
                                          : CupertinoColors.systemRed,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _passwordController.text ==
                                              _confirmPasswordController.text
                                          ? 'Le password corrispondono'
                                          : 'Le password non corrispondono',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _passwordController.text ==
                                                _confirmPasswordController.text
                                            ? CupertinoColors.systemGreen
                                            : CupertinoColors.systemRed,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 24),
                              // CTA Registrazione
                              SizedBox(
                                width: double.infinity,
                                child: CupertinoButton.filled(
                                  onPressed: _isFormValid && !_isLoading
                                      ? _handleSignup
                                      : null,
                                  disabledColor: CupertinoColors.systemGrey4,
                                  borderRadius: BorderRadius.circular(12),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: _isLoading
                                      ? const CupertinoActivityIndicator(
                                          color: CupertinoColors.white,
                                        )
                                      : const Text(
                                          'Crea Account',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Link a Login
                              CupertinoButton(
                                onPressed: _isLoading
                                    ? null
                                    : () => Navigator.of(context).pop(),
                                child: const Text(
                                  'Hai già un account? Accedi',
                                  style: TextStyle(
                                    color: Color(0xFF0A84FF),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    Widget? prefix,
    Widget? suffix,
    bool obscureText = false,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      prefix: prefix != null
          ? Padding(
              padding: const EdgeInsets.only(left: 12),
              child: prefix,
            )
          : null,
      suffix: suffix != null
          ? Padding(
              padding: const EdgeInsets.only(right: 8),
              child: suffix,
            )
          : null,
      obscureText: obscureText,
      keyboardType: keyboardType,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      style: const TextStyle(
        fontSize: 16,
        color: CupertinoColors.black,
      ),
      onChanged: onChanged,
    );
  }
}
