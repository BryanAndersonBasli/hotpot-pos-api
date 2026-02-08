import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotpot/providers/auth_provider.dart';
import 'package:hotpot/providers/menu_provider.dart';
import 'package:hotpot/providers/order_provider.dart';
import 'package:hotpot/models/user.dart';

class HomeScreen extends StatefulWidget {
  final User? user;

  const HomeScreen({super.key, this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = widget.user ?? context.read<AuthProvider>().currentUser!;
    _loadInitialData();
  }

  void _loadInitialData() {
    context.read<MenuProvider>().loadMenuItems();
    context.read<OrderProvider>().loadAllOrders();
  }

  void _logout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Keluar'),
            content: const Text('Apakah Anda yakin ingin keluar?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: const Text('Keluar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('HOTPOT POS'),
          centerTitle: true,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  '${currentUser.name} (${currentUser.role.name})',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
            IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (currentUser.role == UserRole.customer) {
      return CustomerHomeScreen(currentUser: currentUser);
    } else if (currentUser.role == UserRole.cashier) {
      return const CashierHomeScreen();
    } else {
      return const OwnerHomeScreen();
    }
  }
}

class CustomerHomeScreen extends StatelessWidget {
  final User currentUser;

  const CustomerHomeScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu, size: 80, color: Colors.red),
          const SizedBox(height: 32),
          const Text(
            'Selamat Datang',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/customer/menu',
                arguments: currentUser,
              );
            },
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Pesan Menu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/customer/orders',
                arguments: currentUser,
              );
            },
            icon: const Icon(Icons.receipt),
            label: const Text('Lihat Pesanan'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class CashierHomeScreen extends StatelessWidget {
  const CashierHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.point_of_sale, size: 80, color: Colors.blue),
          const SizedBox(height: 32),
          const Text(
            'Dashboard Kasir',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/cashier/orders');
            },
            icon: const Icon(Icons.receipt_long),
            label: const Text('Kelola Pesanan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class OwnerHomeScreen extends StatelessWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.admin_panel_settings, size: 80, color: Colors.green),
          const SizedBox(height: 32),
          const Text(
            'Dashboard Pemilik',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/owner/menu');
            },
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Kelola Menu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/owner/sales');
            },
            icon: const Icon(Icons.analytics),
            label: const Text('Laporan Penjualan'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
