import 'package:flutter/material.dart';

class AppColors {
  // ── Primary palette (Teal) ──────────────────────────────────
  static const Color primary      = Color(0xFF00ACC1);
  static const Color primaryDark  = Color(0xFF007C91);
  static const Color primaryLight = Color(0xFFB2EBF2);

  // ── Navy (sidebar, headers) ─────────────────────────────────
  static const Color navy         = Color(0xFF0D2137);
  static const Color navyLight    = Color(0xFF1A3A5C);

  // ── Backgrounds ─────────────────────────────────────────────
  static const Color background   = Color(0xFFF0F7F9);
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color cardBg       = Color(0xFFE8F5F9);

  // ── Status colours ──────────────────────────────────────────
  static const Color success      = Color(0xFF26A69A);
  static const Color warning      = Color(0xFFFFC107);
  static const Color error        = Color(0xFFEF5350);
  static const Color pending      = Color(0xFFFF9800);
  static const Color inactive     = Color(0xFF90A4AE);

  // ── Text ────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF0D2137);
  static const Color textSecondary = Color(0xFF546E7A);
  static const Color textLight     = Color(0xFF90A4AE);
  static const Color textWhite     = Color(0xFFFFFFFF);

  // ── Calendar markers ────────────────────────────────────────
  static const Color periodDay    = Color(0xFF00ACC1);
  static const Color predictedDay = Color(0xFF80DEEA);
  static const Color ovulationDay = Color(0xFF26A69A);

  // ── Gradients ───────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00ACC1), Color(0xFF006064)],
  );

  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D2137), Color(0xFF1A3A5C)],
  );

  // ── Sidebar active item ─────────────────────────────────────
  static const Color sidebarActive     = Color(0xFF00ACC1);
  static const Color sidebarActiveText = Color(0xFFFFFFFF);
  static const Color sidebarText       = Color(0xFFB0BEC5);
}