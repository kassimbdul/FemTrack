// lib/router/app_router.dart
import 'package:fem_track/screens/calendar/symptom_screen.dart';
import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/education/education_screen.dart';
import '../screens/education/article_detail_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/payment/payment_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/manage_users_screen.dart';
import '../screens/admin/manage_content_screen.dart';
import '../screens/admin/admin_payments_screen.dart';
import '../screens/calendar/symptom_history_screen.dart';
import '../screens/admin/admin_user_detail_screen.dart';
import '../screens/payment/orders_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case '/calendar':
        return MaterialPageRoute(builder: (_) => const CalendarScreen());
      case '/education':
        return MaterialPageRoute(builder: (_) => const EducationScreen());
      case '/education/detail':
        final article = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            builder: (_) => ArticleDetailScreen(article: article));
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/payment':
        return MaterialPageRoute(builder: (_) => const PaymentScreen());
      case '/admin':
        return MaterialPageRoute(builder: (_) => const AdminDashboard());
      case '/admin/users':
        return MaterialPageRoute(builder: (_) => const ManageUsersScreen());
      case '/admin/content':
        return MaterialPageRoute(builder: (_) => const ManageContentScreen());
      case '/admin/payments':
        return MaterialPageRoute(builder: (_) => const AdminPaymentsScreen());
      case '/orders':
        return MaterialPageRoute(builder: (_) => const OrdersScreen());
      case '/symptom':
        return MaterialPageRoute(builder: (_) => const SymptomScreen());
      case '/symptom-history':
        return MaterialPageRoute(builder: (_) => const SymptomHistoryScreen());
      case '/admin/user-detail':
        final userId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => AdminUserDetailScreen(userId: userId));
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
} 