// lib/widgets/common/user_sidebar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class UserSidebarWidget extends StatelessWidget {
  final String currentRoute;
  const UserSidebarWidget({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

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
                    Text('FemTrack',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5)),
                    Text('Health Platform',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),

          // ── Nav items ─────────────────────────────────────
          _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard',
              route: '/dashboard', current: currentRoute),
          _NavItem(icon: Icons.calendar_month_outlined, label: 'Calendar',
              route: '/calendar', current: currentRoute),
          _NavItem(icon: Icons.menu_book_outlined, label: 'Resources',
              route: '/education', current: currentRoute),
          _NavItem(icon: Icons.payment_outlined, label: 'Payments',
              route: '/payment', current: currentRoute),
          _NavItem(icon: Icons.person_outline, label: 'Profile',
              route: '/profile', current: currentRoute),

          if (auth.isAdmin) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Divider(color: Colors.white.withOpacity(0.12)),
            ),
            _NavItem(icon: Icons.admin_panel_settings_outlined,
                label: 'Admin Panel', route: '/admin', current: currentRoute),
          ],

          const Spacer(),

          // ── Logout ───────────────────────────────────────
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String current;

  const _NavItem(
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
        color: isActive ? AppColors.primary.withOpacity(0.25) : Colors.transparent,
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
                    color: isActive ? AppColors.primary : AppColors.sidebarText),
                const SizedBox(width: 12),
                Text(label,
                    style: TextStyle(
                        color:
                            isActive ? Colors.white : AppColors.sidebarText,
                        fontSize: 13,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal)),
                if (isActive) ...[
                  const Spacer(),
                  Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}