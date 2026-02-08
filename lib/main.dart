import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:hotpot/providers/auth_provider.dart';
import 'package:hotpot/providers/menu_provider.dart';
import 'package:hotpot/providers/order_provider.dart';
import 'package:hotpot/providers/sales_provider.dart';
import 'package:hotpot/providers/cart_provider.dart';
import 'package:hotpot/models/user.dart';
import 'package:hotpot/screens/login_screen.dart';
import 'package:hotpot/screens/register_screen.dart';
import 'package:hotpot/screens/home_screen.dart';
import 'package:hotpot/screens/customer_menu_screen.dart';
import 'package:hotpot/screens/cart_screen.dart';
import 'package:hotpot/screens/customer_orders_screen.dart';
import 'package:hotpot/screens/cashier_orders_screen.dart';
import 'package:hotpot/screens/owner_menu_management_screen.dart';
import 'package:hotpot/screens/owner_sales_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'HOTPOT POS',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as User?;
            return HomeScreen(user: args);
          },
          '/customer/menu': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final user = args as User?;
            return CustomerMenuScreen(user: user);
          },
          '/cart': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final user = args as User?;
            return CartScreen(user: user);
          },
          '/customer/orders': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final user = args as User?;
            return CustomerOrdersScreen(user: user);
          },
          '/cashier/orders': (context) => const CashierOrdersScreen(),
          '/owner/menu': (context) => const OwnerMenuManagementScreen(),
          '/owner/sales': (context) => const OwnerSalesScreen(),
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(child: Text('Home Page')),
    );
  }
}
