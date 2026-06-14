// lib/models/user_model.dart
class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final DateTime? dateOfBirth;
  final String role;
  final int averageCycleLength;
  final int averagePeriodLength;
  final DateTime? lastPeriodDate;
  final bool isActive;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.dateOfBirth,
    this.role = 'user',
    this.averageCycleLength = 28,
    this.averagePeriodLength = 5,
    this.lastPeriodDate,
    this.isActive = true,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  String get displayName => fullName?.isNotEmpty == true ? fullName! : email;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: map['full_name'] as String?,
      dateOfBirth: map['date_of_birth'] != null
          ? DateTime.parse(map['date_of_birth'] as String)
          : null,
      role: map['role'] as String? ?? 'user',
      averageCycleLength: map['average_cycle_length'] as int? ?? 28,
      averagePeriodLength: map['average_period_length'] as int? ?? 5,
      lastPeriodDate: map['last_period_date'] != null
          ? DateTime.parse(map['last_period_date'] as String)
          : null,
      isActive: map['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'full_name': fullName,
        'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
        'average_cycle_length': averageCycleLength,
        'average_period_length': averagePeriodLength,
      };

  UserModel copyWith({
    String? fullName,
    DateTime? dateOfBirth,
    int? averageCycleLength,
    int? averagePeriodLength,
    DateTime? lastPeriodDate,
    bool? isActive,
  }) {
    return UserModel(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      role: role,
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
      averagePeriodLength: averagePeriodLength ?? this.averagePeriodLength,
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}