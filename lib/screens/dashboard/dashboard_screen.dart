import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/screen_with_nav.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      context.read<CycleProvider>().loadCycles(auth.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cycleProv = context.watch<CycleProvider>();
    final nextPeriod = cycleProv.nextPeriodDate;
    final daysLeft = cycleProv.daysUntilNextPeriod;

    return ScreenWithNav(
      title: 'Dashboard',
      currentRoute: '/dashboard',
      isAdmin: auth.isAdmin,
      body: auth.user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello, ${auth.user!.displayName}',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 24),
                  // Next period card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.calendar_today, size: 40,
                              color: AppColors.periodDay),
                          const SizedBox(height: 8),
                          Text(
                            nextPeriod != null
                                ? 'Next period in $daysLeft days'
                                : 'No cycle data yet',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (nextPeriod != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Estimated: ${DateFormat.yMMMd().format(nextPeriod)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Quick actions
                  Row(
                    children: [
                      _QuickAction(
                        icon: Icons.edit_calendar,
                        label: 'Log Period',
                        onTap: () =>
                            Navigator.pushNamed(context, '/calendar'),
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        icon: Icons.note_add,
                        label: 'Symptom',
                        onTap: () =>
                            Navigator.pushNamed(context, '/symptom'),  // ✅ fixed route
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        icon: Icons.school,
                        label: 'Education',
                        onTap: () =>
                            Navigator.pushNamed(context, '/education'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Your Cycle Stats',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                              label: 'Avg Cycle',
                              value: '${cycleProv.averageCycleLength} days'),
                          _StatItem(label: 'Avg Period', value: '5 days'),
                          _StatItem(
                              label: 'Cycles',
                              value: '${cycleProv.cycles.length}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E7EA)),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}