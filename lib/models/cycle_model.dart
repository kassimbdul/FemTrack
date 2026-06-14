// lib/models/cycle_model.dart
class CycleModel {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime? endDate;
  final int? cycleLength;
  final int? periodLength;
  final String? notes;
  final DateTime createdAt;

  CycleModel({
    required this.id,
    required this.userId,
    required this.startDate,
    this.endDate,
    this.cycleLength,
    this.periodLength,
    this.notes,
    required this.createdAt,
  });

  factory CycleModel.fromMap(Map<String, dynamic> map) {
    return CycleModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'] as String)
          : null,
      cycleLength: map['cycle_length'] as int?,
      periodLength: map['period_length'] as int?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'start_date': startDate.toIso8601String().split('T').first,
        'end_date': endDate?.toIso8601String().split('T').first,
        'cycle_length': cycleLength,
        'period_length': periodLength,
        'notes': notes,
      };
}