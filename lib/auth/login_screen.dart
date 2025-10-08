import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../shared/ui/loading_error.dart';
import 'signup_screen.dart';

/// Schermata di login con email/password e provider Apple/Google
/// Gestisce errori Firebase con messaggi in italiano
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isAppleAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkAppleSignInAvailability();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Controlla se Sign in with Apple è disponibile (solo iOS 13+)
  Future<void> _checkAppleSignInAvailability() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final isAvailable = await SignInWithApple.isAvailable();
      if (mounted) {
        setState(() => _isAppleAvailable = isAvailable);
      }
    }
  }

  /// Valida email
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Form valido: email valida e password >= 8 caratteri
  bool get _isFormValid {
    return _isValidEmail(_emailController.text.trim()) &&
        _passwordController.text.length >= 8;
  }

  /// Login con email/password
  Future<void> _handleEmailLogin() async {
    if (!_isFormValid || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // AuthGate gestirà il routing automaticamente
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ErrorDisplay.showErrorDialog(context, _mapFirebaseError(e.code));
      }
    } catch (e) {
      if (mounted) {
        ErrorDisplay.showErrorDialog(
          context,
          'Errore imprevisto durante l\'accesso. Riprova.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Login con Google (google_sign_in v7.x API con Firebase)
  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // Autentica l'utente con Google (triggera il flusso di sign-in)
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      if (googleUser == null) {
        // Utente ha annullato
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Ottieni i dettagli auth dalla richiesta
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Crea credenziale Firebase
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Login con Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);
      // AuthGate gestirà il routing automaticamente
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ErrorDisplay.showErrorDialog(context, _mapFirebaseError(e.code));
      }
    } catch (e) {
      if (mounted) {
        ErrorDisplay.showErrorDialog(
          context,
          'Errore durante l\'accesso con Google. Riprova.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Login con Apple
  Future<void> _handleAppleSignIn() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      // AuthGate gestirà il routing
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        // Utente ha annullato, non mostrare errore
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      if (mounted) {
        ErrorDisplay.showErrorDialog(
          context,
          'Errore durante l\'accesso con Apple. Riprova.',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ErrorDisplay.showErrorDialog(context, _mapFirebaseError(e.code));
      }
    } catch (e) {
      if (mounted) {
        ErrorDisplay.showErrorDialog(
          context,
          'Errore durante l\'accesso con Apple. Riprova.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Password dimenticata
  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !_isValidEmail(email)) {
      ErrorDisplay.showErrorDialog(
        context,
        'Inserisci un\'email valida per reimpostare la password',
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Email Inviata'),
            content: Text(
              'Abbiamo inviato le istruzioni per reimpostare la password a $email',
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ErrorDisplay.showErrorDialog(context, _mapFirebaseError(e.code));
      }
    }
  }

  /// Mappa codici errore Firebase in messaggi italiani
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email o password non corretti. Controlla e riprova.';
      case 'user-disabled':
        return 'Questo account è stato disabilitato.';
      case 'too-many-requests':
        return 'Troppi tentativi. Riprova tra qualche minuto.';
      case 'email-already-in-use':
        return 'Questa email è già registrata.';
      case 'account-exists-with-different-credential':
        return 'Account già collegato con un altro metodo di accesso.';
      case 'invalid-email':
        return 'Email non valida.';
      case 'operation-not-allowed':
        return 'Operazione non consentita.';
      case 'weak-password':
        return 'Password troppo debole.';
      case 'network-request-failed':
        return 'Problema di rete. Controlla la connessione e riprova.';
      default:
        return 'Errore durante l\'accesso. Riprova.';
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
                colors: [Color(0xFF0A84FF), Color(0xFF0051D5)],
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
                        // Titolo
                        const Text(
                          'Bentornato',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Continua a prenderti cura della tua postura',
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
                                color: CupertinoColors.black.withValues(
                                  alpha: 0.1,
                                ),
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
                                placeholder: 'Password',
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
                              const SizedBox(height: 8),
                              // Password dimenticata
                              Align(
                                alignment: Alignment.centerRight,
                                child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: _isLoading
                                      ? null
                                      : _handleForgotPassword,
                                  child: const Text(
                                    'Password dimenticata?',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF0A84FF),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // CTA Login
                              SizedBox(
                                width: double.infinity,
                                child: CupertinoButton.filled(
                                  onPressed: _isFormValid && !_isLoading
                                      ? _handleEmailLogin
                                      : null,
                                  disabledColor: CupertinoColors.systemGrey4,
                                  borderRadius: BorderRadius.circular(12),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: _isLoading
                                      ? const CupertinoActivityIndicator(
                                          color: CupertinoColors.white,
                                        )
                                      : const Text(
                                          'Accedi',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Link Registrazione
                              CupertinoButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        Navigator.of(context).push(
                                          CupertinoPageRoute(
                                            builder: (context) =>
                                                const SignupScreen(),
                                          ),
                                        );
                                      },
                                child: const Text(
                                  'Non hai un account? Registrati',
                                  style: TextStyle(
                                    color: Color(0xFF0A84FF),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              // Divider Social
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: CupertinoColors.systemGrey4,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'oppure',
                                      style: TextStyle(
                                        color: CupertinoColors.systemGrey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: CupertinoColors.systemGrey4,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Google Sign In
                              _buildSocialButton(
                                label: 'Continua con Google',
                                icon: CupertinoIcons.globe,
                                onPressed: _isLoading
                                    ? null
                                    : _handleGoogleSignIn,
                              ),
                              // Apple Sign In (solo se disponibile)
                              if (_isAppleAvailable) ...[
                                const SizedBox(height: 12),
                                _buildSocialButton(
                                  label: 'Continua con Apple',
                                  icon: CupertinoIcons.device_phone_portrait,
                                  onPressed: _isLoading
                                      ? null
                                      : _handleAppleSignIn,
                                ),
                              ],
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
          ? Padding(padding: const EdgeInsets.only(left: 12), child: prefix)
          : null,
      suffix: suffix != null
          ? Padding(padding: const EdgeInsets.only(right: 8), child: suffix)
          : null,
      obscureText: obscureText,
      keyboardType: keyboardType,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      style: const TextStyle(fontSize: 16, color: CupertinoColors.black),
      onChanged: onChanged,
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        onPressed: onPressed,
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: CupertinoColors.label, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: CupertinoColors.label,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
