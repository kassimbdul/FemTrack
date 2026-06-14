// lib/widgets/admin/admin_sidebar_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class AdminSidebarWidget extends StatelessWidget {
  final String currentRoute;
  const AdminSidebarWidget({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.navyGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 36, 20, 28),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.water_drop_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('FemTrack',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5)),
                    Text('Admin Panel',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),

          // ── Nav items ─────────────────────────────────────
          _AdminNavItem(icon: Icons.dashboard_outlined, label: 'Dashboard',
              route: '/admin', current: currentRoute),
          _AdminNavItem(icon: Icons.people_outline, label: 'Users',
              route: '/admin/users', current: currentRoute),
          _AdminNavItem(icon: Icons.payment_outlined, label: 'Payments',
              route: '/admin/payments', current: currentRoute),
          _AdminNavItem(icon: Icons.article_outlined, label: 'Content',
              route: '/admin/content', current: currentRoute),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Divider(color: Colors.white.withOpacity(0.12)),
          ),

          // Back to user app
          _AdminNavItem(icon: Icons.arrow_back_outlined, label: 'Back to App',
              route: '/dashboard', current: currentRoute),

          const Spacer(),

          // ── Logout ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () async {
                await context.read<AuthProvider>().signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.logout,
                        color: Colors.white.withOpacity(0.6), size: 20),
                    const SizedBox(width: 12),
                    Text('Logout',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String current;

  const _AdminNavItem(
      {required this.icon,
      required this.label,
      required this.route,
      required this.current});

  @override
  Widget build(BuildContext context) {
    final isActive = current == route;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isActive
            ? AppColors.primary.withOpacity(0.25)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => Navigator.pushReplacementNamed(context, route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(icon,
                    size: 20,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.sidebarText),
                const SizedBox(width: 12),
                Text(label,
                    style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : AppColors.sidebarText,
                        fontSize: 13,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}