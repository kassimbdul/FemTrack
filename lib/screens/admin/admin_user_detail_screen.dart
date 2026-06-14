import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../models/cycle_model.dart';
import '../../models/symptom_model.dart';
import '../../services/database_service.dart';
import '../../widgets/common/screen_with_nav.dart';

class AdminUserDetailScreen extends StatefulWidget {
  final String userId;
  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  UserModel? _user;
  List<CycleModel> _cycles = [];
  List<SymptomModel> _symptoms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final users = await DatabaseService.getAllUsers();
    _user = users.firstWhere((u) => u.id == widget.userId);
    _cycles = await DatabaseService.getCycles(widget.userId);
    _symptoms = await DatabaseService.getSymptoms(widget.userId);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_user == null) {
      return const Scaffold(body: Center(child: Text('User not found')));
    }

    return ScreenWithNav(
      title: 'User Profile',
      currentRoute: '/admin/user-detail',
      isAdmin: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_user!.displayName, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text('Email: ${_user!.email}'),
                    Text('Role: ${_user!.role}'),
                    Text('Joined: ${DateFormat.yMMMd().format(_user!.createdAt)}'),
                    Text('Avg Cycle: ${_user!.averageCycleLength} days'),
                    Text('Avg Period: ${_user!.averagePeriodLength} days'),
                    if (_user!.dateOfBirth != null)
                      Text('DOB: ${DateFormat.yMMMd().format(_user!.dateOfBirth!)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Cycles (${_cycles.length})', style: Theme.of(context).textTheme.titleMedium),
            if (_cycles.isNotEmpty)
              ..._cycles.take(3).map((c) => ListTile(
                    dense: true,
                    title: Text('${DateFormat.yMMMd().format(c.startDate)} - ${c.endDate != null ? DateFormat.yMMMd().format(c.endDate!) : 'ongoing'}'),
                    subtitle: Text('Cycle length: ${c.cycleLength ?? '?'} days'),
                  )),
            const Divider(),
            Text('Symptom History (${_symptoms.length})', style: Theme.of(context).textTheme.titleMedium),
            if (_symptoms.isNotEmpty)
              ..._symptoms.take(3).map((s) => ListTile(
                    dense: true,
                    title: Text(DateFormat.yMMMd().format(s.logDate)),
                    subtitle: Text('Mood: ${s.mood}, Cramps: ${s.cramps}, Flow: ${s.flow}'),
                    trailing: s.notes != null ? const Icon(Icons.note) : null,
                  )),
          ],
        ),
      ),
    );
  }
}