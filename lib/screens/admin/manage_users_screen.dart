import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
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
    final auth = context.watch<AuthProvider>();
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
              final isCurrentAdmin = auth.user?.id == user.id;
              final isAdminUser = user.isAdmin;
              return Card(
                child: ListTile(
                  title: Row(
                    children: [
                      Text(user.displayName),
                      if (isAdminUser) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('ADMIN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(user.email),
                  trailing: isAdminUser || isCurrentAdmin
                      ? null
                      : Switch(
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
                  onTap: () => Navigator.pushNamed(context, '/admin/user-detail', arguments: user.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}