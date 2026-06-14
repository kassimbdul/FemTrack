// lib/providers/auth_provider.dart
import 'package:fem_track/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _loading = false;

  UserModel? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  Future<String?> signIn(String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      await AuthService.signIn(email: email, password: password);
      await _loadProfile();
      return null; // success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String?> signUp(
      String email, String password, String? fullName) async {
    _loading = true;
    notifyListeners();
    try {
      await AuthService.signUp(
          email: email, password: password, fullName: fullName);
      await _loadProfile();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await SupabaseService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    _user = await AuthService.getCurrentProfile();
    notifyListeners();
  }

  /// Call on app start to check persisted session
  Future<void> tryAutoLogin() async {
    final currentUser = SupabaseService.client.auth.currentUser;
    if (currentUser != null) {
      await _loadProfile();
    }
  }
}