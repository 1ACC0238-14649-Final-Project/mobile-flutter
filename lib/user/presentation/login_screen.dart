import 'package:flutter/material.dart';
import '../../common/ui_state.dart';
import '../../common/resource.dart';
import '../data/repository/user_repository.dart';
import '../domain/model/user.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoggedIn;
  final VoidCallback onGoToRegister;
  const LoginScreen({super.key, required this.onLoggedIn, required this.onGoToRegister});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final repo = UserRepository();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool obscure = true;
  UIState<Resource<User>> state = UIState.idle();

  Future<void> _login() async {
    setState(() => state = UIState.loadingState());
    try {
      final user = await repo.login(email: emailCtrl.text.trim(), password: passCtrl.text);
      setState(() => state = UIState.dataState(Success(user)));
      widget.onLoggedIn();
    } catch (e, st) {
      setState(() => state = UIState.dataState(ErrorRes<User>(e, st)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = state.loading;
    final res = state.data;

    String? errText;
    if (res is ErrorRes<User>) errText = res.error.toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
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
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isLoading ? null : _login,
                  icon: const Icon(Icons.lock_open),
                  label: Text(isLoading ? 'Autenticando...' : 'Ingresar'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: isLoading ? null : widget.onGoToRegister,
                child: const Text('Crear cuenta'),
              ),
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
