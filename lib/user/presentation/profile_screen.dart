import 'package:flutter/material.dart';
import '../data/repository/user_repository.dart';
import '../domain/model/user.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback? onAddPull;

  const ProfileScreen({
    super.key,
    required this.onLogout,
    this.onAddPull,
  });

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
        appBar: AppBar(
          title: const Text('Perfil', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1E3A5F),
          centerTitle: true,
        ),
        body: Center(child: Text(error!)),
      );
    }

    final u = me;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A5F),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  (u?.image ?? '').isNotEmpty
                      ? CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(u!.image!),
                  )
                      : const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(height: 12),
                  Text(u?.name ?? '-', style: Theme.of(context).textTheme.titleLarge),
                  if ((u?.lastname ?? '').isNotEmpty)
                    Text(
                      u!.lastname!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  const SizedBox(height: 8),
                  Text(u?.email ?? ''),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _buildCard(
              title: "More",
              child: InkWell(
                onTap: _logout,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.logout, size: 24, color: Colors.red),
                      const SizedBox(width: 12),
                      Text(
                        "Log Out",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: Colors.red),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildCard(
              title: "My Account",
              child: InkWell(
                onTap: () {
                  // TODO: Navigate to edit screen
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline, size: 24),
                      const SizedBox(width: 8),
                      const Icon(Icons.settings_outlined, size: 20),
                      const SizedBox(width: 12),
                      const Text(
                        "Edit Personal Information",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildCard(
              title: "Settings",
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.language, size: 24),
                      const SizedBox(width: 12),
                      const Text("Language", style: TextStyle(fontSize: 16)),
                      const Spacer(),
                      Text(
                        "English",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildCard(
              title: "Briefcase",
              child: InkWell(
                onTap: () => widget.onAddPull?.call(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.work_outline, size: 24),
                      const SizedBox(width: 12),
                      const Text("Add +", style: TextStyle(fontSize: 16)),
                      const Spacer(),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
