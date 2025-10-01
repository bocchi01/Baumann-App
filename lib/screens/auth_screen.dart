import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _isRegisterMode = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(bool isRegister) async {
    final AuthState state = ref.read(authControllerProvider);
    if (state.isLoading) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    final AuthController controller = ref.read(authControllerProvider.notifier);
    if (isRegister) {
      await controller.registerWithEmail(email, password);
    } else {
      await controller.signInWithEmail(email, password);
    }
  }

  Future<void> _onRegisterPressed() async {
    if (!_isRegisterMode) {
      setState(() {
        _isRegisterMode = true;
      });
      ref.read(authControllerProvider.notifier).clearError();
      return;
    }
    await _handleSubmit(true);
  }

  void _resetToLoginMode() {
    setState(() {
      _isRegisterMode = false;
      _nameController.clear();
      _confirmPasswordController.clear();
    });
    ref.read(authControllerProvider.notifier).clearError();
  }

  @override
  Widget build(BuildContext context) {
    final AuthState authState = ref.watch(authControllerProvider);
    final AuthController authController =
        ref.read(authControllerProvider.notifier);
    final ThemeData theme = Theme.of(context);
    final TextStyle? inputTextStyle = theme.textTheme.bodyLarge;
    final Color cursorColor = theme.colorScheme.primary;
    final bool hasError = (authState.errorMessage ?? '').trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accedi o Registrati'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Bentornato!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Inserisci le tue credenziali per continuare oppure crea un nuovo account.',
                    textAlign: TextAlign.center,
                  ),
                  if (hasError) ...<Widget>[
                    const SizedBox(height: 16),
                    Material(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                authState.errorMessage!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : () => authController.clearError(),
                              icon: const Icon(Icons.close),
                              color: theme.colorScheme.onErrorContainer,
                              tooltip: 'Chiudi messaggio',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: AutofillGroup(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              if (_isRegisterMode) ...<Widget>[
                                TextFormField(
                                  controller: _nameController,
                                  autofocus: true,
                                  style: inputTextStyle,
                                  cursorColor: cursorColor,
                                  decoration: const InputDecoration(
                                    labelText: 'Nome',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  validator: (String? value) {
                                    if ((value ?? '').trim().isEmpty) {
                                      return 'Inserisci il tuo nome.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                              TextFormField(
                                controller: _emailController,
                                autofocus: !_isRegisterMode,
                                style: inputTextStyle,
                                cursorColor: cursorColor,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'nome@esempio.com',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const <String>[
                                  AutofillHints.email
                                ],
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.none,
                                onFieldSubmitted: (_) =>
                                    _passwordFocusNode.requestFocus(),
                                validator: (String? value) {
                                  final String trimmed = (value ?? '').trim();
                                  if (trimmed.isEmpty) {
                                    return 'Inserisci una email.';
                                  }
                                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                      .hasMatch(trimmed)) {
                                    return 'Inserisci una email valida.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
                                style: inputTextStyle,
                                cursorColor: cursorColor,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                                obscureText: true,
                                textInputAction: _isRegisterMode
                                    ? TextInputAction.next
                                    : TextInputAction.done,
                                autofillHints: const <String>[
                                  AutofillHints.password
                                ],
                                enableSuggestions: false,
                                onFieldSubmitted: (_) {
                                  if (_isRegisterMode) {
                                    _confirmPasswordFocusNode.requestFocus();
                                  } else {
                                    _handleSubmit(false);
                                  }
                                },
                                validator: (String? value) {
                                  if ((value ?? '').isEmpty) {
                                    return 'La password è obbligatoria.';
                                  }
                                  if ((value ?? '').length < 6) {
                                    return 'La password deve contenere almeno 6 caratteri.';
                                  }
                                  return null;
                                },
                              ),
                              if (_isRegisterMode) ...<Widget>[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  focusNode: _confirmPasswordFocusNode,
                                  style: inputTextStyle,
                                  cursorColor: cursorColor,
                                  decoration: const InputDecoration(
                                    labelText: 'Conferma Password',
                                    prefixIcon: Icon(Icons.lock_reset_outlined),
                                  ),
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  validator: (String? value) {
                                    if (!_isRegisterMode) {
                                      return null;
                                    }
                                    if ((value ?? '').isEmpty) {
                                      return 'Conferma la password.';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Le password non coincidono.';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => _handleSubmit(true),
                                ),
                              ],
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: authState.isLoading
                                      ? null
                                      : () => _handleSubmit(false),
                                  child: authState.isLoading && !_isRegisterMode
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Text('Accedi'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: authState.isLoading
                                      ? null
                                      : () => _onRegisterPressed(),
                                  child: authState.isLoading && _isRegisterMode
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : Text(_isRegisterMode
                                          ? 'Crea il tuo account'
                                          : 'Registrati'),
                                ),
                              ),
                              if (_isRegisterMode)
                                TextButton(
                                  onPressed: authState.isLoading
                                      ? null
                                      : _resetToLoginMode,
                                  child:
                                      const Text('Hai già un account? Accedi'),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  if (!_isRegisterMode) ...<Widget>[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: authState.isLoading ? null : () {},
                        icon: const Icon(Icons.g_mobiledata),
                        label: const Text('Accedi con Google'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: authState.isLoading ? null : () {},
                        icon: const Icon(Icons.apple),
                        label: const Text('Accedi con Apple'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
