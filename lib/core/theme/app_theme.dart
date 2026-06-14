// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.navy,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 14, color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 13, color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCFD8DC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCFD8DC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE0E7EA)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFE0E7EA), thickness: 1),
    );
  }
}