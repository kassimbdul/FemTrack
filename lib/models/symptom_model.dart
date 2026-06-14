// lib/models/symptom_model.dart
class SymptomModel {
  final String id;
  final String userId;
  final DateTime logDate;
  final String? cramps;  // none / mild / moderate / severe
  final String? mood;    // happy / calm / sad / anxious / irritable
  final String? flow;    // none / light / medium / heavy
  final String? notes;
  final DateTime createdAt;

  SymptomModel({
    required this.id,
    required this.userId,
    required this.logDate,
    this.cramps,
    this.mood,
    this.flow,
    this.notes,
    required this.createdAt,
  });

  factory SymptomModel.fromMap(Map<String, dynamic> map) {
    return SymptomModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      logDate: DateTime.parse(map['log_date'] as String),
      cramps: map['cramps'] as String?,
      mood: map['mood'] as String?,
      flow: map['flow'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'log_date': logDate.toIso8601String().split('T').first,
        'cramps': cramps,
        'mood': mood,
        'flow': flow,
        'notes': notes,
      };
}