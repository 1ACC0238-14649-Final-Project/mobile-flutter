import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../gigs/presentation/gig_viewmodel.dart';
import '../gigs/presentation/seller_mygigs_screen.dart';
import '../gigs/presentation/create_gig_screen.dart';
import '../pulls/presentation/my_pulls_screen.dart';
import '../user/presentation/profile_screen.dart';
import '../user/data/repository/user_repository.dart';

enum MainTab { home, create, pulls, profile }

class MainScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const MainScreen({super.key, required this.onLogout});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  MainTab _currentTab = MainTab.home;

  // ----------------------------------------------------------
  // Obtiene sellerId REAL desde el JWT token
  // ----------------------------------------------------------
  Future<int> _loadSellerId() async {
    final repo = UserRepository();
    final user = await repo.getCachedUser();

    if (user == null) throw Exception("No user session");

    return _extractUserIdFromJWT(user.token);
  }

  int _extractUserIdFromJWT(String token) {
    final parts = token.split('.');

    if (parts.length != 3) return 0;

    final payload = parts[1];

    /// Corrige padding del Base64URL
    String normalized = payload;
    final remainder = payload.length % 4;
    if (remainder > 0) {
      normalized = payload.padRight(payload.length + (4 - remainder), '=');
    }

    Uint8List decodedBytes = base64Url.decode(normalized);
    final jsonData = jsonDecode(utf8.decode(decodedBytes));

    const sid =
        "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/sid";

    return int.tryParse(jsonData[sid].toString()) ?? 0;
  }

  // ----------------------------------------------------------
  // Construcción dinámica por tab
  // ----------------------------------------------------------
  void _onTabTapped(MainTab tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  Widget _buildCurrentScreen() {
    switch (_currentTab) {
    // ======================================
    // HOME: Seller My Gigs (VER GIGS CREADOS)
    // ======================================
      case MainTab.home:
        return FutureBuilder<int>(
          future: _loadSellerId(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final sellerId = snapshot.data!;
            final vm = GigViewModel()..loadMyGigs(sellerId);

            return SellerMyGigsScreen(vm: vm);
          },
        );

    // ======================================
    // CREATE NEW GIG
    // ======================================
      case MainTab.create:
        return CreateGigScreen(
          onGigCreated: () {
            setState(() => _currentTab = MainTab.home);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gig creado exitosamente')),
            );
          },
          onBack: () {
            setState(() => _currentTab = MainTab.home);
          },
        );

    // ======================================
    // PULLS
    // ======================================
      case MainTab.pulls:
        return const MyPullsScreen();

    // ======================================
    // PROFILE
    // ======================================
      case MainTab.profile:
        return ProfileScreen(onLogout: widget.onLogout);
    }
  }

  // ----------------------------------------------------------
  // UI principal
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentScreen(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: 'Home',
                  tab: MainTab.home,
                  isSelected: _currentTab == MainTab.home,
                ),
                _buildNavItem(
                  icon: Icons.add_circle_outline,
                  label: 'Create',
                  tab: MainTab.create,
                  isSelected: _currentTab == MainTab.create,
                ),
                _buildNavItem(
                  icon: Icons.favorite_outline,
                  label: 'Pulls',
                  tab: MainTab.pulls,
                  isSelected: _currentTab == MainTab.pulls,
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  tab: MainTab.profile,
                  isSelected: _currentTab == MainTab.profile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // Item de navegación inferior
  // ----------------------------------------------------------
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required MainTab tab,
    required bool isSelected,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(tab),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
