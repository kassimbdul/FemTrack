import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  bool  _obscure    = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth  = context.read<AuthProvider>();
    final error = await auth.signIn(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
      return;
    }
    Navigator.pushReplacementNamed(
        context, auth.isAdmin ? '/admin' : '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;
          if (isWide) return _WideLayout(formKey: _formKey, emailCtrl: _emailCtrl,
              passCtrl: _passCtrl, obscure: _obscure,
              onToggle: () => setState(() => _obscure = !_obscure),
              onLogin: auth.loading ? null : _login, loading: auth.loading);
          return _NarrowLayout(formKey: _formKey, emailCtrl: _emailCtrl,
              passCtrl: _passCtrl, obscure: _obscure,
              onToggle: () => setState(() => _obscure = !_obscure),
              onLogin: auth.loading ? null : _login, loading: auth.loading);
        },
      ),
    );
  }
}

// ── Wide (desktop) ──────────────────────────────────────────────────────────
class _WideLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl, passCtrl;
  final bool obscure, loading;
  final VoidCallback? onLogin, onToggle;
  const _WideLayout({required this.formKey, required this.emailCtrl,
      required this.passCtrl, required this.obscure, required this.loading,
      required this.onLogin, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left panel – brand
        Expanded(
          child: Container(
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: _BrandPanel(compact: false),
              ),
            ),
          ),
        ),
        // Right panel – form
        Expanded(
          child: Container(
            color: AppColors.surface,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(40),
                  child: _LoginForm(
                    formKey: formKey, emailCtrl: emailCtrl,
                    passCtrl: passCtrl, obscure: obscure,
                    loading: loading, onLogin: onLogin, onToggle: onToggle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Narrow (mobile) ─────────────────────────────────────────────────────────
class _NarrowLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl, passCtrl;
  final bool obscure, loading;
  final VoidCallback? onLogin, onToggle;
  const _NarrowLayout({required this.formKey, required this.emailCtrl,
      required this.passCtrl, required this.obscure, required this.loading,
      required this.onLogin, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            // Flexible brand panel – no fixed height
            child: const SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: _BrandPanel(compact: true),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: _LoginForm(
              formKey: formKey, emailCtrl: emailCtrl,
              passCtrl: passCtrl, obscure: obscure,
              loading: loading, onLogin: onLogin, onToggle: onToggle,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Brand panel ─────────────────────────────────────────────────────────────
class _BrandPanel extends StatelessWidget {
  final bool compact;
  const _BrandPanel({this.compact = false});

  @override
  Widget build(BuildContext context) {
    final double iconSize = compact ? 48.0 : 72.0;
    final double titleSize = compact ? 22.0 : 28.0;
    final double spacing = compact ? 12.0 : 20.0;
    final double smallSpacing = compact ? 6.0 : 8.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize, height: iconSize,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(compact ? 14 : 20),
          ),
          child: Icon(Icons.water_drop_rounded,
              color: Colors.white, size: iconSize * 0.55),
        ),
        SizedBox(height: spacing),
        Text('FemTrack',
            style: TextStyle(
                color: Colors.white,
                fontSize: titleSize,
                fontWeight: FontWeight.w800,
                letterSpacing: compact ? 1.5 : 2)),
        SizedBox(height: smallSpacing),
        Text('Menstrual Health Platform',
            style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: compact ? 12 : 14)),
        SizedBox(height: spacing),
        // Feature pills
        const _FeaturePill('Track your cycle with precision'),
        SizedBox(height: smallSpacing),
        const _FeaturePill('Health education & tips'),
        SizedBox(height: smallSpacing),
        const _FeaturePill('Smart period prediction'),
      ],
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final String text;
  const _FeaturePill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(text,
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ── Shared form ─────────────────────────────────────────────────────────────
class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl, passCtrl;
  final bool obscure, loading;
  final VoidCallback? onLogin, onToggle;
  const _LoginForm({required this.formKey, required this.emailCtrl,
      required this.passCtrl, required this.obscure, required this.loading,
      required this.onLogin, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text('Sign in to your account', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
                labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: passCtrl,
            obscureText: obscure,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: onToggle,
              ),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('Forgot Password?'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onLogin,
              child: loading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Sign In'),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text("Don't have an account? Sign Up"),
            ),
          ),
        ],
      ),
    );
  }
}