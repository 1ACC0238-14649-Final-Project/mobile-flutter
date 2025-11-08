import 'package:flutter/material.dart';
import '../data/repository/user_repository.dart';
import '../domain/model/user.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const ProfileScreen({super.key, required this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final repo = UserRepository();
  User? me;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final cached = await repo.getCachedUser();
      if (cached == null) {
        setState(() {
          loading = false;
          error = 'No session.';
        });
        return;
      }
      setState(() => me = cached);
      final refreshed = await repo.refreshMe();
      setState(() {
        me = refreshed;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  Future<void> _logout() async {
    await repo.logout();
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: Center(child: Text(error!)),
      );
    }
    final u = me;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if ((u?.image ?? '').isNotEmpty)
              CircleAvatar(radius: 36, backgroundImage: NetworkImage(u!.image!))
            else
              const CircleAvatar(radius: 36, child: Icon(Icons.person)),
            const SizedBox(height: 12),
            Text(u?.name ?? '-', style: Theme.of(context).textTheme.titleLarge),
            if ((u?.lastname ?? '').isNotEmpty) Text(u!.lastname!, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(u?.email ?? ''),
            const SizedBox(height: 8),
            Text((u?.role ?? '').isEmpty ? '—' : (u!.role!)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
