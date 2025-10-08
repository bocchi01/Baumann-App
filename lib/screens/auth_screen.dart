import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Errore'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _validateForm() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Per favore compila tutti i campi richiesti');
      return false;
    }

    if (!_isValidEmail(email)) {
      _showErrorDialog('Per favore inserisci un indirizzo email valido');
      return false;
    }

    if (password.length < 6) {
      _showErrorDialog('La password deve contenere almeno 6 caratteri');
      return false;
    }

    if (_isRegisterMode) {
      final name = _nameController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      if (name.isEmpty) {
        _showErrorDialog('Per favore inserisci il tuo nome');
        return false;
      }

      if (password != confirmPassword) {
        _showErrorDialog('Le password non coincidono');
        return false;
      }
    }

    return true;
  }

  Future<void> _handleSubmit() async {
    final state = ref.read(authControllerProvider);
    if (state.isLoading) return;

    if (!_validateForm()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final controller = ref.read(authControllerProvider.notifier);
    if (_isRegisterMode) {
      await controller.registerWithEmail(email, password);
    } else {
      await controller.signInWithEmail(email, password);
    }
  }

  void _toggleMode() {
    setState(() {
      _isRegisterMode = !_isRegisterMode;
      if (!_isRegisterMode) {
        _nameController.clear();
        _confirmPasswordController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        _showErrorDialog(next.errorMessage!);
        ref.read(authControllerProvider.notifier).clearError();
      }
    });

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
                        // Title
                        Text(
                          _isRegisterMode
                              ? 'Inizia il Tuo Percorso'
                              : 'Bentornato',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isRegisterMode
                              ? 'Crea un account e inizia a prenderti cura della tua postura'
                              : 'Continua a prenderti cura della tua postura',
                          style: const TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        // Auth Card
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
                          child: _buildFormContent(authState),
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

  Widget _buildFormContent(AuthState authState) {
    return Column(
      children: [
        if (_isRegisterMode) ...[
          _buildTextField(
            controller: _nameController,
            placeholder: 'Nome',
            prefix: const Icon(CupertinoIcons.person, color: Color(0xFF0A84FF)),
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
        ],
        _buildTextField(
          controller: _emailController,
          placeholder: 'Email',
          prefix: const Icon(CupertinoIcons.mail, color: Color(0xFF0A84FF)),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          placeholder: 'Password',
          prefix: const Icon(CupertinoIcons.lock, color: Color(0xFF0A84FF)),
          obscureText: _obscurePassword,
          suffix: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            child: Icon(
              _obscurePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ),
        if (_isRegisterMode) ...[
          const SizedBox(height: 16),
          _buildTextField(
            controller: _confirmPasswordController,
            placeholder: 'Conferma Password',
            prefix: const Icon(CupertinoIcons.lock, color: Color(0xFF0A84FF)),
            obscureText: _obscureConfirmPassword,
            suffix: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              child: Icon(
                _obscureConfirmPassword
                    ? CupertinoIcons.eye
                    : CupertinoIcons.eye_slash,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        // Primary CTA
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            onPressed: authState.isLoading ? null : _handleSubmit,
            color: const Color(0xFF0A84FF),
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: authState.isLoading
                ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                : Text(
                    _isRegisterMode ? 'Inizia Ora' : 'Accedi',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        // Toggle Mode
        CupertinoButton(
          onPressed: authState.isLoading ? null : _toggleMode,
          child: Text(
            _isRegisterMode
                ? 'Hai già un account? Accedi'
                : 'Non hai un account? Registrati',
            style: const TextStyle(color: Color(0xFF0A84FF), fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    Widget? prefix,
    Widget? suffix,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
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
      textCapitalization: textCapitalization,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      style: const TextStyle(fontSize: 16, color: CupertinoColors.black),
    );
  }
}
