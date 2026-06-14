// lib/widgets/common/screen_with_nav.dart
//
// Drop-in replacement for Scaffold.  Each screen calls:
//
//   return ScreenWithNav(
//     title:        'Dashboard',
//     currentRoute: '/dashboard',
//     body:         <your content>,
//   );
//
// • width ≥ 800 px → persistent sidebar + desktop top-bar  (no hamburger)
// • width < 800 px → AppBar + hamburger → Drawer            (mobile)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'user_sidebar.dart';
import 'app_drawer.dart';
import '../admin/admin_sidebar_widget.dart';
import '../admin/admin_drawer.dart';

const double kSidebarBreakpoint = 800;

class ScreenWithNav extends StatelessWidget {
  final String title;
  final String currentRoute;
  final Widget body;
  final bool isAdmin;
  final Widget? floatingActionButton;

  const ScreenWithNav({
    super.key,
    required this.title,
    required this.currentRoute,
    required this.body,
    this.isAdmin = false,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= kSidebarBreakpoint;

        if (isWide) {
          // ── Desktop layout ──────────────────────────────────
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Row(
              children: [
                // Persistent sidebar
                SizedBox(
                  width: 230,
                  child: isAdmin
                      ? AdminSidebarWidget(currentRoute: currentRoute)
                      : UserSidebarWidget(currentRoute: currentRoute),
                ),
                // Main content
                Expanded(
                  child: Column(
                    children: [
                      _DesktopTopBar(title: title),
                      Expanded(
                        child: ClipRect(child: body),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: floatingActionButton,
          );
        }

        // ── Mobile layout ────────────────────────────────────
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(title),
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: const Color(0xFFE0E7EA)),
            ),
          ),
          drawer: isAdmin ? const AdminDrawer() : const AppDrawer(),
          body: body,
          floatingActionButton: floatingActionButton,
        );
      },
    );
  }
}

// ── Desktop top bar ──────────────────────────────────────────────────────────
class _DesktopTopBar extends StatelessWidget {
  final String title;
  const _DesktopTopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final initial =
        (auth.user?.displayName.isNotEmpty == true)
            ? auth.user!.displayName[0].toUpperCase()
            : 'U';

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E7EA))),
      ),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.textSecondary),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 4),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: Text(initial,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(auth.user?.displayName ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
              Text(auth.isAdmin ? 'Administrator' : 'Member',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}