// lib/main.dart
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
      // ── Step 1: Try build-time values (production / Vercel) ──────────────
      //  These are baked in at compile time via:
      //  flutter build web --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=xxx
      String supabaseUrl  = const String.fromEnvironment('SUPABASE_URL');
      String supabaseKey  = const String.fromEnvironment('SUPABASE_ANON_KEY');

      // ── Step 2: Fall back to .env.local (local development only) ─────────
      //  .env.local is in .gitignore, so this block is skipped on Vercel.
      //  Wrapped in try/catch so a missing file never crashes the app.
      if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
        try {
          await dotenv.load(fileName: '.env.local');
          supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
          supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
        } catch (_) {
          // .env.local absent (expected in production) — carry on.
          debugPrint('FemTrack: .env.local not found, '
              'relying on --dart-define build values.');
        }
      }

      if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
        throw Exception(
          'Supabase credentials not found.\n\n'
          'LOCAL: add SUPABASE_URL and SUPABASE_ANON_KEY to your .env.local file.\n'
          'VERCEL: add those variables in the Vercel dashboard and set your build '
          'command to:\n'
          '  flutter build web --release '
          '--dart-define=SUPABASE_URL=\$SUPABASE_URL '
          '--dart-define=SUPABASE_ANON_KEY=\$SUPABASE_ANON_KEY',
        );
      }

      // ── Step 3: Initialise Supabase ───────────────────────────────────────
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

      if (mounted) setState(() => _ready = true);
    } catch (e, stack) {
      debugPrint('FemTrack init error: $e\n$stack');
      if (mounted) setState(() => _errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFFFFF0F0),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 72, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to start FemTrack',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(_errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!_ready) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFFF0F7F9),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF00ACC1)),
                SizedBox(height: 16),
                Text('Starting FemTrack…',
                    style: TextStyle(color: Color(0xFF546E7A))),
              ],
            ),
          ),
        ),
      );
    }

    return const FemTrackApp();
  }
}

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