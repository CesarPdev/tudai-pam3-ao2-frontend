import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/register_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _obscure = true;

  @override
  void dispose() {
    _emailFocus.dispose();
    _passFocus.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingrese su email';
    if (!v.contains('@') || !v.contains('.')) return 'Email inválido';
    return null;
  }

  String? _validatePass(String? v) {
    if (v == null || v.isEmpty) return 'Ingrese su contraseña';
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  void _goToPassword() => _passFocus.requestFocus();
  void _toggleObscure() => setState(() => _obscure = !_obscure);

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);

    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Usuario o contraseña incorrectos'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _goToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Usuario', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailCtrl,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _goToPassword(),
            decoration: const InputDecoration(hintText: 'Ingrese su email'),
            validator: _validateEmail,
          ),

          const SizedBox(height: 14),

          const Text('Contraseña', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passCtrl,
            focusNode: _passFocus,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            obscureText: _obscure,
            decoration: InputDecoration(
              hintText: 'Ingrese su contraseña',
              suffixIcon: IconButton(
                onPressed: _toggleObscure,
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
              ),
            ),
            validator: _validatePass,
          ),

          const SizedBox(height: 18),

          ElevatedButton(
            onPressed: isLoading ? null : _submit,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Iniciar sesión'),
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: isLoading ? null : _goToRegister,
            child: const Text('¿No tenés cuenta? Registrate'),
          ),
        ],
      ),
    );
  }
}
