// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth  = context.read<AuthProvider>();
    final error = await auth.signUp(
      _emailCtrl.text.trim(), _passCtrl.text, _nameCtrl.text.trim());
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error));
      return;
    }
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              // Left brand panel (only on wide screens)
              if (constraints.maxWidth >= 800)
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.water_drop_rounded, size: 64, color: Colors.white),
                            SizedBox(height: 16),
                            Text('Join FemTrack',
                                style: TextStyle(color: Colors.white, fontSize: 26,
                                    fontWeight: FontWeight.w800)),
                            SizedBox(height: 8),
                            Text('Start tracking your health journey today.',
                                style: TextStyle(color: Colors.white70, fontSize: 15),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              // Form panel
              Expanded(
                child: Container(
                  color: AppColors.surface,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(36),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (constraints.maxWidth < 800)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: const Icon(Icons.arrow_back),
                                  ),
                                ),
                              Text('Create Account',
                                  style: Theme.of(context).textTheme.headlineMedium),
                              const SizedBox(height: 4),
                              Text('Fill in your details to get started',
                                  style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 28),
                              TextFormField(
                                controller: _nameCtrl,
                                decoration: const InputDecoration(
                                    labelText: 'Full Name',
                                    prefixIcon: Icon(Icons.person_outline)),
                                validator: (v) =>
                                    v?.isEmpty == true ? 'Required' : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email_outlined)),
                                validator: (v) =>
                                    v?.isEmpty == true ? 'Required' : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passCtrl,
                                obscureText: _obscure,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscure
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                validator: (v) => v != null && v.length < 6
                                    ? 'Minimum 6 characters'
                                    : null,
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: auth.loading ? null : _register,
                                  child: auth.loading
                                      ? const SizedBox(width: 20, height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2, color: Colors.white))
                                      : const Text('Create Account'),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Already have an account? Sign In'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}