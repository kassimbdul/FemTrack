import '../../models/cycle_model.dart';

class CycleDateUtils {
  /// Returns the average cycle length from a list of cycles.
  /// Falls back to 28 if insufficient data.
  static int calculateAverageCycleLength(List<CycleModel> cycles) {
    if (cycles.length < 2) return 28;
    final sorted = List<CycleModel>.from(cycles)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    int total = 0;
    for (int i = 1; i < sorted.length; i++) {
      total += sorted[i].startDate.difference(sorted[i - 1].startDate).inDays;
    }
    return (total / (sorted.length - 1)).round().clamp(21, 45);
  }

  /// Returns predicted next period start date or null if no cycles exist.
  static DateTime? predictNextPeriod(List<CycleModel> cycles, int avgCycleLength) {
    if (cycles.isEmpty) return null;
    final last = cycles.reduce((a, b) => a.startDate.isAfter(b.startDate) ? a : b);
    return last.startDate.add(Duration(days: avgCycleLength));
  }

  /// Returns predicted ovulation date (approx. 14 days before next period).
  static DateTime? predictOvulation(DateTime? nextPeriod) {
    if (nextPeriod == null) return null;
    return nextPeriod.subtract(const Duration(days: 14));
  }

  /// Days until next period. Negative means period has started.
  static int daysUntilNextPeriod(DateTime? nextPeriodDate) {
    if (nextPeriodDate == null) return -99;
    return nextPeriodDate.difference(DateTime.now()).inDays;
  }

  /// Returns Set of all period days (actual) from cycle records.
  static Set<DateTime> getActualPeriodDays(List<CycleModel> cycles, int defaultPeriodLength) {
    final days = <DateTime>{};
    for (final c in cycles) {
      final length = c.periodLength ?? defaultPeriodLength;
      for (int i = 0; i < length; i++) {
        final day = c.startDate.add(Duration(days: i));
        days.add(DateTime(day.year, day.month, day.day));
      }
    }
    return days;
  }

  /// Returns Set of predicted period days for next cycle.
  static Set<DateTime> getPredictedPeriodDays(
      DateTime? nextPeriod, int periodLength) {
    if (nextPeriod == null) return {};
    final days = <DateTime>{};
    for (int i = 0; i < periodLength; i++) {
      final d = nextPeriod.add(Duration(days: i));
      days.add(DateTime(d.year, d.month, d.day));
    }
    return days;
  }

  /// Normalises a DateTime to midnight (removes time component).
  static DateTime normalise(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}