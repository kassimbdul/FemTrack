// lib/screens/admin/admin_payments_screen.dart
import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../widgets/common/screen_with_nav.dart';

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
              return Card(
                child: ListTile(
                  title: Text('${o['quantity']} pack(s) - ${o['amount']} SLL'),
                  subtitle: Text('${o['location']}\n${o['contact_phone']}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Chip(label: Text(o['payment_method'])),
                      Text(o['status']),
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