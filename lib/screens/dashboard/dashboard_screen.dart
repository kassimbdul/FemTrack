// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/common/screen_with_nav.dart';
import '../../models/symptom_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _dailyTip;
  SymptomModel? _todaySymptom;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;
    await context.read<CycleProvider>().loadCycles(auth.user!.id);

    // Load today's symptom
    final today = DateTime.now();
    final symptoms = await DatabaseService.getSymptoms(
      auth.user!.id,
      start: DateTime(today.year, today.month, today.day),
      end: DateTime(today.year, today.month, today.day),
    );
    if (!mounted) return;
    setState(() => _todaySymptom = symptoms.isNotEmpty ? symptoms.first : null);

    // Load a random health tip
    final content = await DatabaseService.getPublishedContent();
    if (!mounted) return;
    if (content.isNotEmpty) {
      content.shuffle();
      setState(() => _dailyTip = content.first['content'] as String?);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth      = context.watch<AuthProvider>();
    final cycleProv = context.watch<CycleProvider>();
    final next      = cycleProv.nextPeriodDate;
    final daysLeft  = cycleProv.daysUntilNextPeriod;

    return ScreenWithNav(
      title: 'Dashboard',
      currentRoute: '/dashboard',
      isAdmin: auth.isAdmin,
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Greeting ─────────────────────────────────
                  Text(
                    'Hello, ${auth.user?.displayName.split(' ').first ?? 'there'} 👋',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(DateFormat.yMMMMEEEEd().format(DateTime.now()),
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 20),

                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(children: [
                            _NextPeriodCard(next: next, daysLeft: daysLeft,
                                avgCycle: cycleProv.averageCycleLength),
                            const SizedBox(height: 16),
                            _CycleSummaryCard(cycleProv: cycleProv),
                            const SizedBox(height: 16),
                            _SymptomsCard(symptom: _todaySymptom,
                                onAdd: () => Navigator.pushNamed(context, '/symptom')),
                          ]),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: Column(children: [
                            _QuickActions(context),
                            const SizedBox(height: 16),
                            if (_dailyTip != null) _DailyTipCard(tip: _dailyTip!),
                          ]),
                        ),
                      ],
                    )
                  else ...[
                    _NextPeriodCard(next: next, daysLeft: daysLeft,
                        avgCycle: cycleProv.averageCycleLength),
                    const SizedBox(height: 16),
                    _CycleSummaryCard(cycleProv: cycleProv),
                    const SizedBox(height: 16),
                    _SymptomsCard(symptom: _todaySymptom,
                        onAdd: () => Navigator.pushNamed(context, '/symptom')),
                    const SizedBox(height: 16),
                    _QuickActions(context),
                    if (_dailyTip != null) ...[
                      const SizedBox(height: 16),
                      _DailyTipCard(tip: _dailyTip!),
                    ],
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Next Period card ──────────────────────────────────────────────────────────
class _NextPeriodCard extends StatelessWidget {
  final DateTime? next;
  final int daysLeft;
  final int avgCycle;

  const _NextPeriodCard(
      {required this.next, required this.daysLeft, required this.avgCycle});

  @override
  Widget build(BuildContext context) {
    final isPeriodActive = daysLeft <= 0 && daysLeft > -7;
    final label = next == null
        ? 'Log your first period'
        : isPeriodActive
            ? 'Period is active'
            : 'Next Period';
    final value = next == null
        ? 'No data yet'
        : isPeriodActive
            ? 'Started ${-daysLeft} days ago'
            : '$daysLeft Days Left';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Cycle: $avgCycle days',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800)),
          if (next != null) ...[
            const SizedBox(height: 4),
            Text(
              'Expected on ${DateFormat.yMMMd().format(next!)}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Cycle summary card ────────────────────────────────────────────────────────
class _CycleSummaryCard extends StatelessWidget {
  final CycleProvider cycleProv;
  const _CycleSummaryCard({required this.cycleProv});

  @override
  Widget build(BuildContext context) {
    final lastDate = cycleProv.cycles.isNotEmpty
        ? DateFormat.yMMMd().format(cycleProv.cycles.first.startDate)
        : '—';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E7EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cycle Summary',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'Last Period',
                  value: lastDate,
                  icon: Icons.water_drop_outlined,
                  iconColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryItem(
                  label: 'Cycle Length',
                  value: '${cycleProv.averageCycleLength} days',
                  icon: Icons.loop,
                  iconColor: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryItem(
                  label: 'Logged Cycles',
                  value: '${cycleProv.cycles.length}',
                  icon: Icons.history,
                  iconColor: AppColors.pending,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color iconColor;

  const _SummaryItem(
      {required this.label, required this.value,
       required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.textPrimary),
            textAlign: TextAlign.center),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textSecondary),
            textAlign: TextAlign.center),
      ],
    );
  }
}

// ── Today's symptoms card ─────────────────────────────────────────────────────
class _SymptomsCard extends StatelessWidget {
  final SymptomModel? symptom;
  final VoidCallback onAdd;

  const _SymptomsCard({required this.symptom, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E7EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Today's Symptoms",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const Spacer(),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '+ Log',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (symptom == null)
            const Text('No symptoms logged today.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
          else
            Row(
              children: [
                _SymptomChip(label: 'Cramps', value: symptom!.cramps ?? '—',
                    icon: Icons.bolt_outlined, color: AppColors.error),
                const SizedBox(width: 8),
                _SymptomChip(label: 'Mood', value: symptom!.mood ?? '—',
                    icon: Icons.sentiment_satisfied_alt, color: AppColors.success),
                const SizedBox(width: 8),
                _SymptomChip(label: 'Flow', value: symptom!.flow ?? '—',
                    icon: Icons.water_drop_outlined, color: AppColors.primary),
              ],
            ),
        ],
      ),
    );
  }
}

class _SymptomChip extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _SymptomChip(
      {required this.label, required this.value,
       required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(value.capitalize(),
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ── Quick actions ─────────────────────────────────────────────────────────────
Widget _QuickActions(BuildContext context) {
  return Row(
    children: [
      _QuickBtn(
        icon: Icons.calendar_month_outlined,
        label: 'Calendar',
        color: AppColors.primary,
        onTap: () => Navigator.pushNamed(context, '/calendar'),
      ),
      const SizedBox(width: 10),
      _QuickBtn(
        icon: Icons.edit_note_outlined,
        label: 'Symptoms',
        color: AppColors.success,
        onTap: () => Navigator.pushNamed(context, '/symptom'),
      ),
      const SizedBox(width: 10),
      _QuickBtn(
        icon: Icons.menu_book_outlined,
        label: 'Education',
        color: AppColors.pending,
        onTap: () => Navigator.pushNamed(context, '/education'),
      ),
    ],
  );
}

class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickBtn(
      {required this.icon, required this.label,
       required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E7EA)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Daily tip card ────────────────────────────────────────────────────────────
class _DailyTipCard extends StatelessWidget {
  final String tip;
  const _DailyTipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.lightbulb_outline,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Health Tip',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.primary)),
                const SizedBox(height: 4),
                Text(
                  tip.length > 140 ? '${tip.substring(0, 140)}…' : tip,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── String extension ──────────────────────────────────────────────────────────
extension _StringExt on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}