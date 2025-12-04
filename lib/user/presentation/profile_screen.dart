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

      // Intentamos refrescar datos del servidor
      try {
        final refreshed = await repo.refreshMe();
        if (mounted) {
          setState(() {
            me = refreshed;
            loading = false;
          });
        }
      } catch (_) {
        // Si falla el refresh, nos quedamos con el caché y quitamos loading
        if (mounted) setState(() => loading = false);
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          error = e.toString();
        });
      }
    }
  }

  Future<void> _logout() async {
    await repo.logout();
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Estado de Carga
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. Estado de Error
    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
          backgroundColor: const Color(0xFF1E3A5F),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _load,
                child: const Text("Reintentar"),
              )
            ],
          ),
        ),
      );
    }

    final u = me;
    final fullName = '${u?.name ?? ''} ${u?.lastname ?? ''}'.trim();
    final displayName = fullName.isEmpty ? 'Usuario' : fullName;
    final role = (u?.role ?? '').isEmpty ? 'User' : u!.role!;
    final email = u?.email ?? 'No email';
    final image = u?.image;

    // 3. UI Principal
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB), // Fondo gris muy suave
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER PERSONALIZADO
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Fondo Azul Curvo
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E3A5F),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, right: 16),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {
                            // TODO: Navegar a configuración
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Avatar Flotante
                Positioned(
                  bottom: -50,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: (image != null && image.isNotEmpty)
                          ? NetworkImage(image)
                          : null,
                      child: (image == null || image.isEmpty)
                          ? Text(
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 32, color: Color(0xFF1E3A5F)),
                      )
                          : null,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60), // Espacio para el avatar flotante

            // INFORMACIÓN BÁSICA
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A5F),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A5F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                role.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF1E3A5F),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ESTADÍSTICAS (Placeholder visual para mejorar el diseño)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem("Gigs", "12"),
                  _buildDivider(),
                  _buildStatItem("Rating", "4.8"),
                  _buildDivider(),
                  _buildStatItem("Reviews", "35"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // LISTA DE DETALLES Y ACCIONES
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.email_outlined,
                    title: "Email",
                    value: email,
                  ),
                  const Divider(height: 1, indent: 60, endIndent: 20),
                  _buildProfileTile(
                    icon: Icons.badge_outlined,
                    title: "User ID",
                    value: "ID: 48293", // Puedes usar u?.token.hashCode o similar si quieres algo dinámico
                  ),
                  const Divider(height: 1, indent: 60, endIndent: 20),
                  _buildProfileTile(
                    icon: Icons.phone_outlined,
                    title: "Phone",
                    value: "+51 999 999 999", // Placeholder
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // BOTÓN CERRAR SESIÓN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                    side: BorderSide(color: Colors.redAccent.withOpacity(0.2)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text("Cerrar sesión", style: TextStyle(fontSize: 16)),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A5F),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildProfileTile({required IconData icon, required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1E3A5F), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}