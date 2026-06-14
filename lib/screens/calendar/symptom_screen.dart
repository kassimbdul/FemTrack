import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../models/symptom_model.dart';
import '../../widgets/common/screen_with_nav.dart';
import '../../core/constants/app_colors.dart';

class SymptomScreen extends StatefulWidget {
  const SymptomScreen({super.key});

  @override
  State<SymptomScreen> createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String _cramps = 'none';
  String _mood = 'happy';
  String _flow = 'none';
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    final symptom = SymptomModel(
      id: '', // auto-generated
      userId: auth.user!.id,
      logDate: _selectedDate,
      cramps: _cramps,
      mood: _mood,
      flow: _flow,
      notes: _notesCtrl.text,
      createdAt: DateTime.now(),
    );

    await context.read<CycleProvider>().upsertSymptom(symptom, auth.user!.id);
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Symptom saved')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return ScreenWithNav(
      title: 'Log Symptom',
      currentRoute: '/symptom',
      isAdmin: auth.isAdmin,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Record your symptoms', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              // Date picker
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat.yMMMd().format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _cramps,
                items: ['none', 'mild', 'moderate', 'severe']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _cramps = v!),
                decoration: const InputDecoration(labelText: 'Cramps'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _mood,
                items: ['happy', 'calm', 'sad', 'anxious', 'irritable']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _mood = v!),
                decoration: const InputDecoration(labelText: 'Mood'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _flow,
                items: ['none', 'light', 'medium', 'heavy']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _flow = v!),
                decoration: const InputDecoration(labelText: 'Flow'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save Symptom'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}