// lib/services/database_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cycle_model.dart';
import '../models/symptom_model.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class DatabaseService {
  static final _db = SupabaseService.db;

  // ── Cycles ──────────────────────────────────────────────────
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

  // ── Symptoms ────────────────────────────────────────────────
  static Future<List<SymptomModel>> getSymptoms(String userId,
      {DateTime? start, DateTime? end}) async {
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
    await _db.from('symptoms').upsert(symptom.toMap());
  }

  // ── Education ───────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getPublishedContent() async {
    final response = await _db
        .from('education_content')
        .select()
        .eq('is_published', true)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> getAllContent() async {
    // admin only
    final response = await _db
        .from('education_content')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> upsertContent(Map<String, dynamic> content) async {
    await _db.from('education_content').upsert(content);
  }

  // ── Payments ────────────────────────────────────────────────
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

  // ── Admin – Users ──────────────────────────────────────────
  static Future<List<UserModel>> getAllUsers() async {
    final response = await _db
        .from('profiles')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((e) => UserModel.fromMap(e)).toList();
  }

  static Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    await _db.from('profiles').update(data).eq('id', userId);
  }

  // ── Orders (new) ──────────────────────────────────────────
  static Future<void> createOrder(Map<String, dynamic> order) async {
    await _db.from('orders').insert(order);
  }

  static Future<void> updateOrder(String orderId, Map<String, dynamic> data) async {
    await _db.from('orders').update(data).eq('id', orderId);
  }

  static Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
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

  static Future<void> createNotification(String userId, String title, String body) async {
  await _db.from('notifications').insert({
    'user_id': userId,
    'title': title,
    'body': body,
  });
}

static Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
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