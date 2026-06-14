// lib/widgets/common/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final route = ModalRoute.of(context)?.settings.name ?? '';

    return Drawer(
      backgroundColor: AppColors.navy,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
            decoration: const BoxDecoration(gradient: AppColors.navyGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.water_drop_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 10),
                    const Text('CYCLECARE',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(auth.user?.displayName ?? '',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                Text(auth.user?.email ?? '',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6), fontSize: 12)),
              ],
            ),
          ),

          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerItem(icon: Icons.dashboard_outlined, label: 'Dashboard',
                    route: '/dashboard', current: route),
                _DrawerItem(icon: Icons.calendar_month_outlined, label: 'Calendar',
                    route: '/calendar', current: route),
                _DrawerItem(icon: Icons.menu_book_outlined, label: 'Resources',
                    route: '/education', current: route),
                _DrawerItem(icon: Icons.payment_outlined, label: 'Payments',
                    route: '/payment', current: route),
                _DrawerItem(icon: Icons.person_outline, label: 'Profile',
                    route: '/profile', current: route),
                if (auth.isAdmin) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Divider(color: Colors.white.withOpacity(0.12)),
                  ),
                  _DrawerItem(icon: Icons.admin_panel_settings_outlined,
                      label: 'Admin Panel', route: '/admin', current: route),
                ],
              ],
            ),
          ),

          // Logout
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListTile(
              leading: Icon(Icons.logout, color: Colors.white.withOpacity(0.6), size: 20),
              title: Text('Logout',
                  style: TextStyle(color: Colors.white.withOpacity(0.6))),
              onTap: () async {
                Navigator.pop(context);
                await auth.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String current;

  const _DrawerItem(
      {required this.icon, required this.label,
       required this.route, required this.current});

  @override
  Widget build(BuildContext context) {
    final isActive = current == route;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(icon, color: isActive ? AppColors.primary : AppColors.sidebarText, size: 20),
        title: Text(label,
            style: TextStyle(
                color: isActive ? Colors.white : AppColors.sidebarText,
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
        tileColor: isActive ? AppColors.primary.withOpacity(0.2) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () {
          Navigator.pop(context); // close drawer
          Navigator.pushReplacementNamed(context, route);
        },
      ),
    );
  }
}