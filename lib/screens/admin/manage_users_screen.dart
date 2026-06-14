// lib/screens/admin/manage_users_screen.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/database_service.dart';
import '../../widgets/common/screen_with_nav.dart';
import '../../core/constants/app_colors.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  late Future<List<UserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = DatabaseService.getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWithNav(
      title: 'Manage Users',
      currentRoute: '/admin/users',
      isAdmin: true,
      body: FutureBuilder<List<UserModel>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                child: ListTile(
                  title: Text(user.displayName),
                  subtitle: Text(user.email),
                  trailing: Switch(
                    value: user.isActive,
                    onChanged: (value) async {
                      await DatabaseService.updateUserProfile(user.id, {
                        'is_active': value,
                      });
                      setState(() {
                        _usersFuture = DatabaseService.getAllUsers();
                      });
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}