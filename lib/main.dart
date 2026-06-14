import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cycle_provider.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FemTrackLoadingApp());
}

/// Shows a loading spinner while initializing, then switches to the real app.
class FemTrackLoadingApp extends StatefulWidget {
  const FemTrackLoadingApp({super.key});

  @override
  State<FemTrackLoadingApp> createState() => _FemTrackLoadingAppState();
}

class _FemTrackLoadingAppState extends State<FemTrackLoadingApp> {
  String? _errorMessage;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // 1. Load environment variables
      await dotenv.load(fileName: '.env.local');

      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (supabaseUrl == null || supabaseUrl.isEmpty ||
          supabaseKey == null || supabaseKey.isEmpty) {
        throw Exception('Missing SUABASE_URL or SUABASE_ANON_KEY in .env.local');
      }

      // 2. Initialize Supabase
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
      );

      // 3. Success — show the real app
      if (mounted) {
        setState(() => _ready = true);
      }
    } catch (e, stack) {
      debugPrint('Initialization error: $e\n$stack');
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Error screen
    if (_errorMessage != null) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red.shade50,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to start FemTrack',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(_errorMessage!, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Loading screen
    if (!_ready) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFFF0F7F9),
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Success — real app
    return const FemTrackApp();
  }
}

/// The actual FemTrack application
class FemTrackApp extends StatelessWidget {
  const FemTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CycleProvider()),
      ],
      child: MaterialApp(
        title: 'FemTrack',
        theme: AppTheme.theme,
        initialRoute: '/login',
        onGenerateRoute: AppRouter.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}