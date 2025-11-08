import 'package:flutter/material.dart';
import '../../common/ui_state.dart';
import '../../common/resource.dart';
import '../data/repository/user_repository.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegistered;
  final VoidCallback onBackToLogin;
  const RegisterScreen({super.key, required this.onRegistered, required this.onBackToLogin});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final repo = UserRepository();

  final nameCtrl = TextEditingController();
  final lastnameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final roleCtrl = TextEditingController();
  final imageCtrl = TextEditingController();

  bool obscure = true;
  UIState<Resource<void>> state = UIState.idle();

  Future<void> _signUp() async {
    setState(() => state = UIState.loadingState());
    try {
      await repo.register(
        name: nameCtrl.text.trim(),
        lastname: lastnameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
        role: roleCtrl.text.trim().isEmpty ? null : roleCtrl.text.trim(),
        image: imageCtrl.text.trim().isEmpty ? null : imageCtrl.text.trim(),
      );
      setState(() => state = UIState.dataState(const Success(null)));
      widget.onRegistered();
    } catch (e, st) {
      setState(() => state = UIState.dataState(ErrorRes<void>(e, st)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = state.loading;
    final res = state.data;

    String? errText;
    if (res is ErrorRes<void>) errText = res.error.toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
              const SizedBox(height: 12),
              TextField(controller: lastnameCtrl, decoration: const InputDecoration(labelText: 'Apellido')),
              const SizedBox(height: 12),
              TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => obscure = !obscure),
                    icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(controller: roleCtrl, decoration: const InputDecoration(labelText: 'Role (opcional)')),
              const SizedBox(height: 12),
              TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'Image (URL/base64 opcional)')),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isLoading ? null : _signUp,
                  icon: const Icon(Icons.person_add),
                  label: Text(isLoading ? 'Registrando...' : 'Registrar'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: isLoading ? null : widget.onBackToLogin, child: const Text('Ya tengo cuenta')),
              if (errText != null) ...[
                const SizedBox(height: 12),
                Text(errText, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
