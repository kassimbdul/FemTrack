// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Single Supabase client shared across the whole app
  static SupabaseClient get client => Supabase.instance.client;

  // Alias used by DatabaseService
  static SupabaseClient get db => Supabase.instance.client;

  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}