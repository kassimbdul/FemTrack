// lib/providers/cycle_provider.dart
import 'package:flutter/material.dart';
import '../models/cycle_model.dart';
import '../models/symptom_model.dart';
import '../core/utils/date_utils.dart';
import '../services/database_service.dart';
import '../providers/auth_provider.dart';

class CycleProvider extends ChangeNotifier {
  List<CycleModel> _cycles = [];
  List<SymptomModel> _symptoms = [];
  bool _loading = false;

  List<CycleModel> get cycles => _cycles;
  List<SymptomModel> get symptoms => _symptoms;
  bool get loading => _loading;

  int get averageCycleLength =>
      CycleDateUtils.calculateAverageCycleLength(_cycles);

  DateTime? get nextPeriodDate =>
      CycleDateUtils.predictNextPeriod(_cycles, averageCycleLength);

  int get daysUntilNextPeriod =>
      CycleDateUtils.daysUntilNextPeriod(nextPeriodDate);

  Set<DateTime> get actualPeriodDays =>
      CycleDateUtils.getActualPeriodDays(_cycles, 5);

  Set<DateTime> get predictedPeriodDays =>
      CycleDateUtils.getPredictedPeriodDays(nextPeriodDate, 5);

  Future<void> loadCycles(String userId) async {
    _loading = true;
    notifyListeners();
    _cycles = await DatabaseService.getCycles(userId);
    _loading = false;
    notifyListeners();
  }

  Future<void> addCycle(CycleModel cycle, String userId) async {
    await DatabaseService.addCycle(cycle);
    await loadCycles(userId);
  }

  Future<void> deleteCycle(String cycleId, String userId) async {
    await DatabaseService.deleteCycle(cycleId);
    await loadCycles(userId);
  }

  Future<void> loadSymptoms(String userId,
      {DateTime? start, DateTime? end}) async {
    _loading = true;
    notifyListeners();
    _symptoms = await DatabaseService.getSymptoms(userId, start: start, end: end);
    _loading = false;
    notifyListeners();
  }

  Future<void> upsertSymptom(SymptomModel symptom, String userId) async {
    await DatabaseService.upsertSymptom(symptom);
    await loadSymptoms(userId);
  }
}