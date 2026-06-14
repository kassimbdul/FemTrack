import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../widgets/common/screen_with_nav.dart';
import '../../core/constants/app_colors.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = DatabaseService.getAllOrders();
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus,
      {String? adminNote, String? deliveryTime}) async {
    await DatabaseService.updateOrder(orderId, {
      'status': newStatus,
      if (adminNote != null) 'admin_note': adminNote,
      if (deliveryTime != null) 'delivery_time': deliveryTime,
    });
    // TODO: insert notification for user about the order update
    setState(() {
      _ordersFuture = DatabaseService.getAllOrders();
    });
  }

  void _showAcceptDialog(String orderId) {
    final timeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Accept Order'),
        content: TextField(
          controller: timeCtrl,
          decoration: const InputDecoration(labelText: 'Delivery time / note'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateOrderStatus(orderId, 'confirmed',
                  deliveryTime: timeCtrl.text);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(String orderId) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Order'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(labelText: 'Reason for rejection'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateOrderStatus(orderId, 'cancelled',
                  adminNote: reasonCtrl.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWithNav(
      title: 'Orders & Payments',
      currentRoute: '/admin/payments',
      isAdmin: true,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) return const Center(child: Text('No orders'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final o = orders[index];
              final status = o['status'] as String? ?? 'pending';
              final isPending = status == 'pending';
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${o['quantity']} ${o['product'] ?? 'packs'}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          Chip(
                            label: Text(status,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                            backgroundColor: status == 'pending'
                                ? AppColors.pending
                                : status == 'confirmed'
                                    ? AppColors.success
                                    : AppColors.error,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                          '${o['amount']} SLL  ·  ${o['payment_method']}'),
                      Text('Account: ${o['account_number']}'),
                      Text('Phone: ${o['contact_phone']}'),
                      Text('Location: ${o['location']}'),
                      if (o['admin_note'] != null) ...[
                        const Divider(),
                        Text('Admin note: ${o['admin_note']}',
                            style: const TextStyle(fontStyle: FontStyle.italic)),
                      ],
                      if (o['delivery_time'] != null)
                        Text('Delivery time: ${o['delivery_time']}'),
                      if (isPending)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _showAcceptDialog(o['id']),
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text('Accept'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    foregroundColor: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () => _showRejectDialog(o['id']),
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('Reject'),
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}