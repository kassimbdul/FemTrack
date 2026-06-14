import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cycle_model.dart';
import '../models/symptom_model.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class DatabaseService {
  static final _db = SupabaseService.db;

  // ════════════════════════════════════════════════════════════
  // CYCLES
  // ════════════════════════════════════════════════════════════

  static Future<List<CycleModel>> getCycles(String userId) async {
    final response = await _db
        .from('cycles')
        .select()
        .eq('user_id', userId)
        .order('start_date', ascending: false);
    return (response as List).map((e) => CycleModel.fromMap(e)).toList();
  }

  static Future<void> addCycle(CycleModel cycle) async {
    await _db.from('cycles').insert(cycle.toMap());
  }

  static Future<void> updateCycle(CycleModel cycle) async {
    await _db.from('cycles').update(cycle.toMap()).eq('id', cycle.id);
  }

  static Future<void> deleteCycle(String cycleId) async {
    await _db.from('cycles').delete().eq('id', cycleId);
  }

  // ════════════════════════════════════════════════════════════
  // SYMPTOMS
  // ════════════════════════════════════════════════════════════

  static Future<List<SymptomModel>> getSymptoms(
    String userId, {
    DateTime? start,
    DateTime? end,
  }) async {
    var query = _db.from('symptoms').select().eq('user_id', userId);
    if (start != null) {
      query = query.gte('log_date', start.toIso8601String().split('T').first);
    }
    if (end != null) {
      query = query.lte('log_date', end.toIso8601String().split('T').first);
    }
    final response = await query.order('log_date', ascending: false);
    return (response as List).map((e) => SymptomModel.fromMap(e)).toList();
  }

  static Future<void> upsertSymptom(SymptomModel symptom) async {
    await _db.from('symptoms').upsert(
      symptom.toMap(),
      onConflict: 'user_id,log_date',
    );
  }

  // ════════════════════════════════════════════════════════════
  // EDUCATION CONTENT
  // ════════════════════════════════════════════════════════════

  static Future<List<Map<String, dynamic>>> getPublishedContent() async {
    final response = await _db
        .from('education_content')
        .select()
        .eq('is_published', true)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> getAllContent() async {
    final response = await _db
        .from('education_content')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> upsertContent(Map<String, dynamic> content) async {
    await _db.from('education_content').upsert(content);
  }

  static Future<void> deleteContent(String id) async {
    await _db
        .from('education_content')
        .update({'is_published': false}).eq('id', id);
  }

  // ════════════════════════════════════════════════════════════
  // ORDERS (sanitary pads)
  // ════════════════════════════════════════════════════════════

  static Future<void> createOrder(Map<String, dynamic> data) async {
    await _db.from('orders').insert(data);
  }

  static Future<List<Map<String, dynamic>>> getUserOrders(
      String userId) async {
    final response = await _db
        .from('orders')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> getAllOrders() async {
    final response = await _db
        .from('orders')
        .select('*, profiles(email, full_name)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> updateOrder(
      String orderId, Map<String, dynamic> data) async {
    await _db.from('orders').update(data).eq('id', orderId);
  }

  // ════════════════════════════════════════════════════════════
  // PAYMENTS (legacy – kept for backward compat)
  // ════════════════════════════════════════════════════════════

  static Future<List<Map<String, dynamic>>> getUserPayments(
      String userId) async {
    final response = await _db
        .from('payments')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> getAllPayments() async {
    final response = await _db
        .from('payments')
        .select('*, profiles(email, full_name)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // ════════════════════════════════════════════════════════════
  // ADMIN – USERS
  // ════════════════════════════════════════════════════════════

  static Future<List<UserModel>> getAllUsers() async {
    final response = await _db
        .from('profiles')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((e) => UserModel.fromMap(e)).toList();
  }

  static Future<UserModel?> getUserById(String userId) async {
    final response = await _db
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (response == null) return null;
    return UserModel.fromMap(response);
  }

  static Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    await _db.from('profiles').update(data).eq('id', userId);
  }

  // ════════════════════════════════════════════════════════════
  // ADMIN – DASHBOARD STATS
  // ════════════════════════════════════════════════════════════

  /// Returns aggregate counts for the admin dashboard.
  static Future<Map<String, dynamic>> getAdminStats() async {
    // Run queries in parallel for speed
    final results = await Future.wait([
      _db.from('profiles').select('id, is_active, role'),
      _db.from('cycles').select('id'),
      _db.from('orders').select('id, status, amount'),
    ]);

    final users  = results[0] as List;
    final cycles = results[1] as List;
    final orders = results[2] as List;

    // Exclude admin accounts from user stats
    final totalUsers  = users.where((u) => u['role'] != 'admin').length;
    final activeUsers = users
        .where((u) => u['is_active'] == true && u['role'] != 'admin')
        .length;
    final totalCycles = cycles.length;

    double totalRevenue = 0;
    int pendingOrders  = 0;
    int confirmedOrders = 0;
    int cancelledOrders = 0;

    for (final o in orders) {
      totalRevenue += (o['amount'] as num).toDouble();
      switch (o['status']) {
        case 'pending':
          pendingOrders++;
          break;
        case 'confirmed':
          confirmedOrders++;
          break;
        case 'cancelled':
          cancelledOrders++;
          break;
      }
    }

    return {
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
      'totalCycles': totalCycles,
      'totalRevenue': totalRevenue,
      'pendingOrders': pendingOrders,
      'confirmedOrders': confirmedOrders,
      'cancelledOrders': cancelledOrders,
      'totalOrders': orders.length,
    };
  }

  /// Returns monthly user registration counts for the last 6 months.
  static Future<List<int>> getMonthlyRegistrations() async {
    final now   = DateTime.now();
    final counts = List<int>.filled(6, 0);

    final response = await _db
        .from('profiles')
        .select('created_at')
        .gte('created_at',
            DateTime(now.year, now.month - 5, 1).toIso8601String());

    for (final row in response as List) {
      final date     = DateTime.parse(row['created_at'] as String);
      final monthAgo = now.month - date.month + (now.year - date.year) * 12;
      final idx      = 5 - monthAgo;
      if (idx >= 0 && idx < 6) counts[idx]++;
    }
    return counts;
  }

  // ════════════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ════════════════════════════════════════════════════════════

  static Future<void> createNotification(
      String userId, String title, String body) async {
    await _db.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'body': body,
    });
  }

  static Future<List<Map<String, dynamic>>> getNotifications(
      String userId) async {
    final response = await _db
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> markNotificationRead(String id) async {
    await _db.from('notifications').update({'is_read': true}).eq('id', id);
  }
}