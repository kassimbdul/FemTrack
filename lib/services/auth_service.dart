// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class AuthService {
  static final _client = SupabaseService.client;

  /// Sign up with email and password, returns the new user
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName ?? ''},
    );
    return response;
  }

  /// Sign in, returns the session
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  /// Get the current authenticated user's profile from DB
  static Future<UserModel?> getCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    return UserModel.fromMap(data);
  }

  /// Checks if the current user is admin by looking at the profiles table
  static Future<bool> isCurrentUserAdmin() async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    final data = await _client
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single();
    return data['role'] == 'admin';
  }
}