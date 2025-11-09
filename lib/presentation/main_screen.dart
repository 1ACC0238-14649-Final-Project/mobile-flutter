import 'package:flutter/material.dart';
import '../gigs/presentation/my_gigs_screen.dart';
import '../gigs/presentation/create_gig_screen.dart';
import '../pulls/presentation/my_pulls_screen.dart';
import '../user/presentation/profile_screen.dart';

enum MainTab { home, create, pulls, profile }

class MainScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const MainScreen({super.key, required this.onLogout});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  MainTab _currentTab = MainTab.home;

  void _onTabTapped(MainTab tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  Widget _buildCurrentScreen() {
    switch (_currentTab) {
      case MainTab.home:
        return const MyGigsScreen();
      case MainTab.create:
        return CreateGigScreen(
          onGigCreated: () {
            // Después de crear un gig, volver a home
            setState(() => _currentTab = MainTab.home);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gig creado exitosamente')),
            );
          },
          onBack: () {
            // Volver a home si presiona back
            setState(() => _currentTab = MainTab.home);
          },
        );
      case MainTab.pulls:
        return const MyPullsScreen();
      case MainTab.profile:
        return ProfileScreen(onLogout: widget.onLogout);
    }
  }

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
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

