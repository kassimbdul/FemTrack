



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/common/screen_with_nav.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _methodCtrl = TextEditingController(text: 'orangemoney');
  final _accountCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '1');
  bool _submitting = false;

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    final auth = context.read<AuthProvider>();
    final userId = auth.user?.id;
    if (userId == null) return;

    await DatabaseService.createOrder({
      'user_id': userId,
      'product': 'pad',
      'quantity': int.tryParse(_quantityCtrl.text) ?? 1,
      'amount': (int.tryParse(_quantityCtrl.text) ?? 1) * 10.0, // 10 SLL per pack
      'payment_method': _methodCtrl.text,
      'account_number': _accountCtrl.text,
      'location': _locationCtrl.text,
      'contact_phone': _phoneCtrl.text,
    });

    setState(() => _submitting = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order submitted! You will be contacted soon.')),
      );
      _accountCtrl.clear();
      _locationCtrl.clear();
      _phoneCtrl.clear();
      _quantityCtrl.text = '1';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return ScreenWithNav(
      title: 'Request Pads',
      currentRoute: '/payment',
      isAdmin: auth.isAdmin,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Order Sanitary Pads',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Pay with Orange Money or AfriMoney. We will deliver to your location.',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _methodCtrl.text,
                items: const [
                  DropdownMenuItem(value: 'orangemoney', child: Text('Orange Money')),
                  DropdownMenuItem(value: 'afrimoney', child: Text('AfriMoney')),
                ],
                onChanged: (val) => _methodCtrl.text = val!,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _accountCtrl,
                decoration: const InputDecoration(
                  labelText: 'Mobile Money Account Number',
                  hintText: 'e.g., 076xxxxxxx',
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone (if different)',
                  hintText: 'We will call this number upon arrival',
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Delivery Location',
                  hintText: 'Street, landmark, area',
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Number of packs',
                ),
                validator: (v) =>
                    (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter a valid number' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitting ? null : _submitOrder,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Submit Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}