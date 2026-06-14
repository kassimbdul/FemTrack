import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../widgets/common/screen_with_nav.dart';
import '../../core/constants/app_colors.dart';

class SymptomHistoryScreen extends StatefulWidget {
  const SymptomHistoryScreen({super.key});

  @override
  State<SymptomHistoryScreen> createState() => _SymptomHistoryScreenState();
}

class _SymptomHistoryScreenState extends State<SymptomHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid calling provider during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        context.read<CycleProvider>().loadSymptoms(auth.user!.id);
      }
    });
  }

  IconData _moodIcon(String? mood) {
    switch (mood) {
      case 'happy':   return Icons.sentiment_satisfied;
      case 'calm':    return Icons.sentiment_neutral;
      case 'sad':     return Icons.sentiment_dissatisfied;
      case 'anxious': return Icons.sentiment_very_dissatisfied;
      case 'irritable': return Icons.sentiment_very_dissatisfied;
      default:        return Icons.sentiment_satisfied;
    }
  }

  Color _flowColor(String? flow) {
    switch (flow) {
      case 'none':   return Colors.grey;
      case 'light':  return AppColors.primaryLight;
      case 'medium': return AppColors.primary;
      case 'heavy':  return AppColors.periodDay;
      default:       return Colors.grey;
    }
  }

  String _crampText(String? cramps) {
    switch (cramps) {
      case 'none':     return 'No cramps';
      case 'mild':     return 'Mild cramps';
      case 'moderate': return 'Moderate cramps';
      case 'severe':   return 'Severe cramps';
      default:         return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cycleProv = context.watch<CycleProvider>();
    final symptoms = cycleProv.symptoms;

    return ScreenWithNav(
      title: 'My Symptom History',
      currentRoute: '/symptom-history',
      isAdmin: auth.isAdmin,
      body: symptoms.isEmpty
          ? const Center(
              child: Text(
                  'No symptoms recorded yet.\nTap + to add your first entry.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: symptoms.length,
              itemBuilder: (context, index) {
                final s = symptoms[index];
                final flowColor = _flowColor(s.flow);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(DateFormat.yMMMd().format(s.logDate),
                                style: Theme.of(context).textTheme.titleMedium),
                            const Spacer(),
                            // Flow indicator as a colored circle
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: flowColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(s.flow ?? 'none',
                                style: TextStyle(color: flowColor)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(_moodIcon(s.mood),
                                color: AppColors.navy, size: 20),
                            const SizedBox(width: 8),
                            Text(s.mood ?? 'happy',
                                style: Theme.of(context).textTheme.bodyLarge),
                            const SizedBox(width: 16),
                            Text(_crampText(s.cramps)),
                          ],
                        ),
                        if (s.notes != null && s.notes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(s.notes!,
                                style: const TextStyle(
                                    fontStyle: FontStyle.italic)),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}