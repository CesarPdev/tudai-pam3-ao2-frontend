import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});
  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  final _nombreFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmPassFocus = FocusNode();

  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nombreFocus.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _confirmPassFocus.dispose();
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  String? _validateNombre(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingrese su nombre';
    return null;
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

  String? _validateConfirmPass(String? v) {
    if (v == null || v.isEmpty) return 'Confirme su contraseña';
    if (v != _passCtrl.text) return 'Las contraseñas no coinciden';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      _emailCtrl.text.trim(),
      _passCtrl.text,
      nombre: _nombreCtrl.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      // Si el registro + login automático fue exitoso, el AuthGate
      // navegará automáticamente a ContactsScreen por el watch en main.dart.
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Error al registrarse.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
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
          // Nombre
          const Text('Nombre', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nombreCtrl,
            focusNode: _nombreFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
            decoration: const InputDecoration(hintText: 'Su nombre completo'),
            validator: _validateNombre,
          ),

          const SizedBox(height: 14),

          // Email
          const Text('Email', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailCtrl,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _passFocus.requestFocus(),
            decoration: const InputDecoration(hintText: 'ejemplo@mail.com'),
            validator: _validateEmail,
          ),

          const SizedBox(height: 14),

          // Contraseña
          const Text('Contraseña', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passCtrl,
            focusNode: _passFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _confirmPassFocus.requestFocus(),
            obscureText: _obscurePass,
            decoration: InputDecoration(
              hintText: 'Mínimo 6 caracteres',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
                icon: Icon(_obscurePass ? Icons.visibility : Icons.visibility_off),
              ),
            ),
            validator: _validatePass,
          ),

          const SizedBox(height: 14),

          // Confirmar contraseña
          const Text('Confirmar contraseña', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _confirmPassCtrl,
            focusNode: _confirmPassFocus,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              hintText: 'Repita su contraseña',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
              ),
            ),
            validator: _validateConfirmPass,
          ),

          const SizedBox(height: 22),

          ElevatedButton(
            onPressed: isLoading ? null : _submit,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Crear cuenta'),
          ),
        ],
      ),
    );
  }
}
