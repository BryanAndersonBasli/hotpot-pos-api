import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotpot/providers/order_provider.dart';
import 'package:hotpot/models/user.dart';

class CustomerOrdersScreen extends StatefulWidget {
  final User? user;

  const CustomerOrdersScreen({super.key, this.user});

  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    context.read<OrderProvider>().loadAllOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Saya'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadOrders();
        },
        child: Consumer<OrderProvider>(
          builder: (context, orderProvider, _) {
            final myOrders =
                orderProvider.allOrders
                    .where(
                      (order) => order.customerId == (widget.user?.id ?? 0),
                    )
                    .toList();

            if (myOrders.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Belum ada pesanan', style: TextStyle(fontSize: 16)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: myOrders.length,
              itemBuilder: (context, index) {
                final order = myOrders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ExpansionTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Order #${order.id}'),
                        Chip(
                          label: Text(
                            order.status.name.toUpperCase(),
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: _getStatusColor(order.status),
                        ),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp ${order.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          order.createdAt.toString().split('.')[0],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Item Pesanan:',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ...order.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.menuItemName} x ${item.quantity}',
                                      ),
                                    ),
                                    Text(
                                      'Rp ${item.subtotal.toStringAsFixed(0)}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Payment Status:'),
                                Chip(
                                  label: Text(order.paymentStatus.name),
                                  backgroundColor:
                                      order.paymentStatus.name == 'paid'
                                          ? Colors.green
                                          : Colors.orange,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(dynamic status) {
    final statusName = status.toString().split('.').last;
    switch (statusName) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
