import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/common/screen_with_nav.dart';
import '../../core/constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _cycleLengthCtrl = TextEditingController();
  final _periodLengthCtrl = TextEditingController();
  DateTime? _dob;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameCtrl.text = user.fullName ?? '';
      _cycleLengthCtrl.text = user.averageCycleLength.toString();
      _periodLengthCtrl.text = user.averagePeriodLength.toString();
      _dob = user.dateOfBirth;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    await DatabaseService.updateUserProfile(auth.user!.id, {
      'full_name': _nameCtrl.text,
      'average_cycle_length': int.tryParse(_cycleLengthCtrl.text) ?? 28,
      'average_period_length': int.tryParse(_periodLengthCtrl.text) ?? 5,
      if (_dob != null) 'date_of_birth': DateFormat('yyyy-MM-dd').format(_dob!),
    });

    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      await auth.tryAutoLogin(); // refresh the user data
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    return ScreenWithNav(
      title: 'My Profile',
      currentRoute: '/profile',
      isAdmin: auth.isAdmin,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Read-only fields
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email', style: Theme.of(context).textTheme.bodySmall),
                      Text(user.email, style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 12),
                      Text('Role', style: Theme.of(context).textTheme.bodySmall),
                      Text(user.role, style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 12),
                      Text('Member since', style: Theme.of(context).textTheme.bodySmall),
                      Text(DateFormat.yMMMd().format(user.createdAt),
                          style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Editable fields
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dob ?? DateTime(2000),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _dob = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date of Birth'),
                  child: Text(_dob != null ? DateFormat.yMMMd().format(_dob!) : 'Tap to set'),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cycleLengthCtrl,
                      decoration: const InputDecoration(labelText: 'Avg Cycle (days)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _periodLengthCtrl,
                      decoration: const InputDecoration(labelText: 'Avg Period (days)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save Changes'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  await auth.signOut();
                  if (mounted) Navigator.pushReplacementNamed(context, '/login');
                },
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

