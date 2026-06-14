// lib/screens/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../widgets/common/screen_with_nav.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _userCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final users = await DatabaseService.getAllUsers();
    setState(() => _userCount = users.length);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWithNav(
      title: 'Admin Dashboard',
      currentRoute: '/admin',
      isAdmin: true,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, Admin',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.people, size: 40),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Users',
                            style: Theme.of(context).textTheme.titleMedium),
                        Text('$_userCount',
                            style: Theme.of(context).textTheme.headlineLarge),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.manage_accounts),
              title: const Text('Manage Users'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/admin/users'),
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Manage Content'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/admin/content'),
            ),
          ],
        ),
      ),
    );
  }
}