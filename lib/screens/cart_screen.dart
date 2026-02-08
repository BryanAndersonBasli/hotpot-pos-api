import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotpot/providers/cart_provider.dart';
import 'package:hotpot/providers/order_provider.dart';
import 'package:hotpot/models/user.dart';
import 'package:hotpot/models/order.dart';

class CartScreen extends StatefulWidget {
  final User? user;

  const CartScreen({super.key, this.user});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang Belanja'), centerTitle: true),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: Image.asset(
                      'assets/keranjang.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.shopping_cart_outlined,
                          size: 80,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Keranjang kosong',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    final cartKey = item.docId ?? 'item_${item.menuItemId}';
                    return Dismissible(
                      key: Key(cartKey),
                      onDismissed: (direction) {
                        cart.removeItem(cartKey);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Item dihapus')),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Rp ${item.price.toStringAsFixed(0)} x ${item.quantity}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Rp ${item.subtotal.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 20),
                                    onPressed: () {
                                      final cartKey =
                                          item.docId ??
                                          'item_${item.menuItemId}';
                                      cart.updateQuantity(
                                        cartKey,
                                        item.quantity - 1,
                                      );
                                    },
                                  ),
                                  Text(item.quantity.toString()),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 20),
                                    onPressed: () {
                                      final cartKey =
                                          item.docId ??
                                          'item_${item.menuItemId}';
                                      cart.updateQuantity(
                                        cartKey,
                                        item.quantity + 1,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rp ${cart.totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => cart.clearCart(),
                            child: const Text('Bersihkan'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isProcessing ? null : _checkout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child:
                                _isProcessing
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : const Text(
                                      'Pesan',
                                      style: TextStyle(color: Colors.white),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _checkout() async {
    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    if (cart.items.isEmpty) return;

    // Ask for table number
    String? customerName = widget.user?.name ?? 'Guest';
    int? customerId = widget.user?.id ?? 0;
    int? tableNumber = 0;

    // Show dialog to get table number
    final tableController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Masukkan Nomor Meja'),
            content: TextField(
              controller: tableController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Nomor meja (1-99)',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (tableController.text.isNotEmpty) {
                    Navigator.pop(context, tableController.text);
                  }
                },
                child: const Text('Lanjut'),
              ),
            ],
          ),
    );

    if (result == null || result.isEmpty) return;

    try {
      tableNumber = int.parse(result);
      if (tableNumber < 1 || tableNumber > 99) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nomor meja harus antara 1-99')),
        );
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nomor meja yang valid')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final orderItems =
          cart.items
              .map(
                (item) => OrderItem(
                  orderId: 0,
                  menuItemId: item.menuItemId ?? 0,
                  menuItemName: item.name,
                  price: item.price,
                  quantity: item.quantity,
                  subtotal: item.subtotal,
                ),
              )
              .toList();

      final order = Order(
        customerId: customerId,
        customerName: customerName,
        tableNumber: tableNumber,
        items: orderItems,
        totalAmount: cart.totalPrice,
        status: OrderStatus.pending,
        paymentStatus: PaymentStatus.unpaid,
      );

      final success = await orderProvider.createOrder(order);

      if (mounted) {
        if (success) {
          cart.clearCart();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Pesanan berhasil dikirim! Tunggu konfirmasi kasir',
              ),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal membuat pesanan')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
