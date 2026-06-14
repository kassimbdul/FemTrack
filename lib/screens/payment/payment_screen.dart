import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/common/screen_with_nav.dart';
import '../../core/constants/app_colors.dart';

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
  String _productType = 'standard'; // 'standard' = 35 SLL, 'premium' = 45 SLL
  bool _submitting = false;

  double get _pricePerPack => _productType == 'premium' ? 45.0 : 35.0;
  double get _total => (int.tryParse(_quantityCtrl.text) ?? 1) * _pricePerPack;

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final auth = context.read<AuthProvider>();
    final userId = auth.user?.id;
    if (userId == null) return;

    await DatabaseService.createOrder({
      'user_id': userId,
      'product': _productType == 'premium' ? 'Premium Pack' : 'Standard Pack',
      'quantity': int.tryParse(_quantityCtrl.text) ?? 1,
      'amount': _total,
      'payment_method': _methodCtrl.text,
      'account_number': _accountCtrl.text,
      'location': _locationCtrl.text,
      'contact_phone': _phoneCtrl.text,
    });

    setState(() => _submitting = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order submitted! Amount will be deducted from your account.')),
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
              Text('Order Sanitary Pads', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Choose your product. Amount will be deducted from your mobile money immediately.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
              const SizedBox(height: 24),
              // Product type
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Standard Pack\n35 SLL/pack'),
                      value: 'standard',
                      groupValue: _productType,
                      onChanged: (v) => setState(() => _productType = v!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Premium Pack\n45 SLL/pack'),
                      value: 'premium',
                      groupValue: _productType,
                      onChanged: (v) => setState(() => _productType = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _methodCtrl.text,
                items: const [
                  DropdownMenuItem(value: 'orangemoney', child: Text('Orange Money')),
                  DropdownMenuItem(value: 'afrimoney', child: Text('AfriMoney')),
                ],
                onChanged: (val) => _methodCtrl.text = val!,
                decoration: const InputDecoration(labelText: 'Payment Method'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _accountCtrl,
                decoration: const InputDecoration(labelText: 'Mobile Money Account Number'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Contact Phone (for delivery)'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(labelText: 'Delivery Location'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Number of packs'),
                validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter valid quantity' : null,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Total: ${_total.toStringAsFixed(0)} SLL',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitting ? null : _submitOrder,
                child: _submitting
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Submit Order'),
              ),
              const SizedBox(height: 12),
              // ── View orders button ─────────────────
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/orders'),
                icon: const Icon(Icons.receipt_long),
                label: const Text('My Orders'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}