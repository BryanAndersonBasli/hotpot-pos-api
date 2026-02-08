import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotpot/providers/order_provider.dart';
import 'package:hotpot/providers/sales_provider.dart';
import 'package:hotpot/models/order.dart';
import 'package:hotpot/services/print_service.dart';

class CashierOrdersScreen extends StatefulWidget {
  const CashierOrdersScreen({super.key});

  @override
  State<CashierOrdersScreen> createState() => _CashierOrdersScreenState();
}

class _CashierOrdersScreenState extends State<CashierOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
  }

  void _loadOrders() {
    context.read<OrderProvider>().loadAllOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan - Kasir'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending', icon: Icon(Icons.pending_actions)),
            Tab(text: 'Processing', icon: Icon(Icons.autorenew)),
            Tab(text: 'Completed', icon: Icon(Icons.check_circle)),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadOrders();
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOrderList(OrderStatus.pending),
            _buildOrderList(OrderStatus.processing),
            _buildOrderList(OrderStatus.completed),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(OrderStatus status) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        late List<Order> orders;

        if (status == OrderStatus.pending) {
          orders = orderProvider.pendingOrders;
        } else if (status == OrderStatus.processing) {
          orders = orderProvider.processingOrders;
        } else {
          orders = orderProvider.completedOrders;
        }

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Tidak ada pesanan'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _buildOrderCard(order, context, orderProvider);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(
    Order order,
    BuildContext context,
    OrderProvider orderProvider,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Meja #${order.tableNumber}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                Chip(
                  label: Text(order.status.name.toUpperCase()),
                  backgroundColor: _getStatusColor(order.status),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Order items with ready status toggle for processing orders
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.menuItemName} x ${item.quantity}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              decoration:
                                  item.isReady
                                      ? TextDecoration.lineThrough
                                      : null,
                              color: item.isReady ? Colors.grey : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (order.status == OrderStatus.processing)
                      Checkbox(
                        value: item.isReady,
                        onChanged: (value) {
                          orderProvider.updateItemReadyStatus(
                            order.id!,
                            item.docId,
                            value ?? false,
                          );
                        },
                      )
                    else
                      Text(
                        'Rp ${item.subtotal.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: Rp ${order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Chip(
                  label: Text(order.paymentStatus.name),
                  backgroundColor:
                      order.paymentStatus == PaymentStatus.paid
                          ? Colors.green[100]
                          : Colors.orange[100],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons
            _buildActionButtons(order, context, orderProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    Order order,
    BuildContext context,
    OrderProvider orderProvider,
  ) {
    if (order.status == OrderStatus.pending) {
      // Pending tab: Accept payment and move to processing
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _startProcessing(order, orderProvider),
              child: const Text('Mulai Proses'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _approvePayment(order, orderProvider),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                'Terima Bayar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      );
    } else if (order.status == OrderStatus.processing) {
      // Processing tab: Show complete button only if all items ready
      final allReady = orderProvider.allItemsReady(order);
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed:
                  allReady ? () => _completeOrder(order, orderProvider) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: allReady ? Colors.green : Colors.grey,
              ),
              child: Text(
                allReady ? 'Selesai Proses' : 'Tunggu Item Siap',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => PrintService.printOrderReceipt(order),
            color: Colors.blue,
          ),
        ],
      );
    } else {
      // Completed tab: Show payment status and mark as paid/unpaid
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed:
                  order.paymentStatus == PaymentStatus.unpaid
                      ? () => _markAsPaid(order, orderProvider)
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    order.paymentStatus == PaymentStatus.paid
                        ? Colors.green
                        : Colors.orange,
              ),
              child: Text(
                order.paymentStatus == PaymentStatus.paid
                    ? 'Sudah Bayar ✓'
                    : 'Tandai Bayar',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => PrintService.printOrderReceipt(order),
            color: Colors.blue,
          ),
        ],
      );
    }
  }

  void _approvePayment(Order order, OrderProvider orderProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Pembayaran'),
            content: Text(
              'Terima pembayaran sebesar Rp ${order.totalAmount.toStringAsFixed(0)}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  print(
                    '[Cashier._approvePayment] Starting payment approval for order #${order.id}',
                  );
                  print(
                    '[Cashier._approvePayment] Current status: ${order.status}, Payment: ${order.paymentStatus}',
                  );

                  // Update payment status to paid
                  print(
                    '[Cashier._approvePayment] Updating payment status to PAID',
                  );
                  await orderProvider.updatePaymentStatus(
                    order.id!,
                    PaymentStatus.paid,
                  );
                  print('[Cashier._approvePayment] Payment status updated');

                  // Record the sale (order is completed and now paid)
                  if (order.status == OrderStatus.completed) {
                    print(
                      '[Cashier._approvePayment] Order is completed, recording sale',
                    );
                    final updatedOrder = order.copyWith(
                      paymentStatus: PaymentStatus.paid,
                    );
                    print(
                      '[Cashier._approvePayment] Updated order: status=${updatedOrder.status}, payment=${updatedOrder.paymentStatus}',
                    );
                    final recordResult = await context
                        .read<SalesProvider>()
                        .recordSale(updatedOrder);
                    print(
                      '[Cashier._approvePayment] recordSale returned: $recordResult',
                    );
                  } else {
                    print(
                      '[Cashier._approvePayment] Order status is ${order.status}, not completed - skipping recordSale',
                    );
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pembayaran diterima')),
                    );
                  }
                },
                child: const Text('Terima'),
              ),
            ],
          ),
    );
  }

  void _startProcessing(Order order, OrderProvider orderProvider) async {
    await orderProvider.updateOrderStatus(order.id!, OrderStatus.processing);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pesanan sedang diproses')));
      // Auto-navigate to Processing tab
      _tabController.animateTo(1);
    }
  }

  void _completeOrder(Order order, OrderProvider orderProvider) async {
    await orderProvider.updateOrderStatus(order.id!, OrderStatus.completed);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pesanan selesai')));
    }
  }

  void _markAsPaid(Order order, OrderProvider orderProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Pembayaran'),
            content: Text(
              'Tandai pembayaran Rp ${order.totalAmount.toStringAsFixed(0)} sudah diterima?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Update payment status to paid
                  await orderProvider.updatePaymentStatus(
                    order.id!,
                    PaymentStatus.paid,
                  );

                  // Record the sale (order is completed and now paid)
                  if (order.status == OrderStatus.completed) {
                    print(
                      '[Cashier._markAsPaid] Recording sale for order #${order.id}',
                    );
                    final updatedOrder = order.copyWith(
                      paymentStatus: PaymentStatus.paid,
                    );
                    await context.read<SalesProvider>().recordSale(
                      updatedOrder,
                    );
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pembayaran tercatat')),
                    );
                  }
                },
                child: const Text('Ya, Sudah Bayar'),
              ),
            ],
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
      default:
        return Colors.grey;
    }
  }
}
