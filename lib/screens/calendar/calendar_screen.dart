import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../models/cycle_model.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/screen_with_nav.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedMonth = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
  final auth = context.read<AuthProvider>();
  if (auth.user != null) {
    context.read<CycleProvider>().loadCycles(auth.user!.id);
  }
});
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  Future<void> _logPeriod() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    final startCtrl = TextEditingController(
        text: DateFormat.yMd().format(_selectedDay ?? DateTime.now()));
    final endCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Period'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: startCtrl,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Start Date'),
              onTap: () async {
                final date = await showDatePicker(
                  context: ctx,
                  initialDate: _selectedDay ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)), // ✅ allow future
                );
                if (date != null) startCtrl.text = DateFormat.yMd().format(date);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: endCtrl,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'End Date'),
              onTap: () async {
                final date = await showDatePicker(
                  context: ctx,
                  initialDate: _selectedDay ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)), // ✅ allow future
                );
                if (date != null) endCtrl.text = DateFormat.yMd().format(date);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      final cycle = CycleModel(
        id: '', // auto-generated
        userId: auth.user!.id,
        startDate: DateFormat.yMd().parse(startCtrl.text),
        endDate:
            endCtrl.text.isNotEmpty ? DateFormat.yMd().parse(endCtrl.text) : null,
        createdAt: DateTime.now(),
      );
      await context.read<CycleProvider>().addCycle(cycle, auth.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cycleProv = context.watch<CycleProvider>();
    final actualDays = cycleProv.actualPeriodDays;
    final predictedDays = cycleProv.predictedPeriodDays;

    final daysInMonth = DateTimeRange(
      start: DateTime(_selectedMonth.year, _selectedMonth.month, 1),
      end: DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0),
    );

    return ScreenWithNav(
      title: 'Period Calendar',
      currentRoute: '/calendar',
      isAdmin: auth.isAdmin,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _logPeriod,
        icon: const Icon(Icons.add),
        label: const Text('Log Period'),
      ),
      body: Column(
        children: [
          // Month header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: _previousMonth,
                  icon: const Icon(Icons.chevron_left)),
              Text(
                DateFormat.yMMMM().format(_selectedMonth),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(Icons.chevron_right)),
            ],
          ),
          // Day labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(d,
                              style: Theme.of(context).textTheme.bodySmall),
                        ),
                      ))
                  .toList(),
            ),
          ),
          // Calendar grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount:
                  daysInMonth.end.difference(daysInMonth.start).inDays + 1,
              itemBuilder: (context, index) {
                final date = daysInMonth.start.add(Duration(days: index));
                final norm = DateTime(date.year, date.month, date.day);
                final isActual = actualDays.contains(norm);
                final isPredicted = predictedDays.contains(norm);
                final isSelected = _selectedDay != null &&
                    DateUtils.isSameDay(_selectedDay, date);

                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = date),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isActual
                          ? AppColors.periodDay
                          : isPredicted
                              ? AppColors.predictedDay
                              : isSelected
                                  ? AppColors.primaryLight
                                  : null,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isActual || isPredicted
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}