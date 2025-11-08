import 'package:flutter/material.dart';
import '../user/presentation/login_screen.dart';
import '../user/presentation/register_screen.dart';
import '../user/presentation/profile_screen.dart';
import '../user/data/repository/user_repository.dart';

class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

enum RouteKey { login, register, profile }

class _AppNavigationState extends State<AppNavigation> {
  RouteKey route = RouteKey.login;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final repo = UserRepository();
    final u = await repo.getCachedUser();
    if (u != null) {
      setState(() => route = RouteKey.profile);
    } else {
      setState(() => route = RouteKey.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (route) {
      case RouteKey.login:
        return LoginScreen(
          onLoggedIn: () => setState(() => route = RouteKey.profile),
          onGoToRegister: () => setState(() => route = RouteKey.register),
        );
      case RouteKey.register:
        return RegisterScreen(
          onRegistered: () => setState(() => route = RouteKey.login),
          onBackToLogin: () => setState(() => route = RouteKey.login),
        );
      case RouteKey.profile:
        return ProfileScreen(onLogout: () => setState(() => route = RouteKey.login));
    }
  }
}
