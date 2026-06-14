import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/common/screen_with_nav.dart';
import '../../core/constants/app_colors.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthProvider>().user?.id;
    if (userId != null) {
      _ordersFuture = DatabaseService.getUserOrders(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return ScreenWithNav(
      title: 'My Orders',
      currentRoute: '/orders',
      isAdmin: auth.isAdmin,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(
              child: Text('You haven\'t placed any orders yet.',
                  style: TextStyle(color: AppColors.textSecondary)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final o = orders[index];
              final status = o['status'] as String? ?? 'pending';
              final adminNote = o['admin_note'] as String?;
              final deliveryTime = o['delivery_time'] as String?;

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
                          Text('${o['quantity']} ${o['product'] ?? 'packs'}',
                              style: Theme.of(context).textTheme.titleMedium),
                          const Spacer(),
                          Chip(
                            label: Text(status,
                                style: const TextStyle(color: Colors.white, fontSize: 12)),
                            backgroundColor: status == 'pending'
                                ? AppColors.pending
                                : status == 'confirmed'
                                    ? AppColors.success
                                    : AppColors.error,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Amount: ${o['amount']} SLL'),
                      Text('Method: ${o['payment_method']}'),
                      Text('Phone: ${o['contact_phone']}'),
                      Text('Location: ${o['location']}'),
                      if (deliveryTime != null) ...[
                        const Divider(),
                        Text('📦 Delivery: $deliveryTime',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                      if (adminNote != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline, size: 16, color: AppColors.navy),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(adminNote,
                                    style: const TextStyle(fontStyle: FontStyle.italic)),
                              ),
                            ],
                          ),
                        ),
                      ],
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