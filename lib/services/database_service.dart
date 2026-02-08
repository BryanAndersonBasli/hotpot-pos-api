import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:hotpot/models/user.dart';
import 'package:hotpot/models/menu_item.dart';
import 'package:hotpot/models/order.dart';
import 'package:hotpot/models/sale.dart';

class DatabaseService {
  static const String _dbName = 'hotpot.db';
  static const int _dbVersion = 3;

  static Database? _database;

  DatabaseService() {
    // Web support: kIsWeb is a compile-time constant
    // so unused code is eliminated for non-web platforms
  }

  Future<Database> get database async {
    if (kIsWeb) {
      throw Exception(
        'SQLite tidak didukung di web. Gunakan backend API atau platform lain.',
      );
    }
    _database ??= await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add table_number column to orders table
      await db.execute(
        'ALTER TABLE orders ADD COLUMN table_number INTEGER DEFAULT 0',
      );
    }
    if (oldVersion < 3) {
      // Add is_ready column to order_items table
      await db.execute(
        'ALTER TABLE order_items ADD COLUMN is_ready INTEGER DEFAULT 0',
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Menu items table
    await db.execute('''
      CREATE TABLE menu_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        category TEXT NOT NULL,
        image TEXT,
        is_available INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        customer_name TEXT NOT NULL,
        table_number INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL,
        payment_status TEXT NOT NULL,
        total_amount REAL NOT NULL,
        created_at TEXT NOT NULL,
        completed_at TEXT,
        FOREIGN KEY (customer_id) REFERENCES users (id)
      )
    ''');

    // Order items table
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        menu_item_id INTEGER NOT NULL,
        menu_item_name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        subtotal REAL NOT NULL,
        is_ready INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (order_id) REFERENCES orders (id),
        FOREIGN KEY (menu_item_id) REFERENCES menu_items (id)
      )
    ''');

    // Create default admin user
    await db.insert('users', {
      'username': 'owner',
      'password': 'owner123',
      'role': 'owner',
      'name': 'Owner',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Create default cashier user
    await db.insert('users', {
      'username': 'cashier',
      'password': 'cashier123',
      'role': 'cashier',
      'name': 'Kasir',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Create consumer users
    await db.insert('users', {
      'username': 'customer1',
      'password': 'customer123',
      'role': 'customer',
      'name': 'Konsumen 1',
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('users', {
      'username': 'customer2',
      'password': 'customer123',
      'role': 'customer',
      'name': 'Konsumen 2',
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('users', {
      'username': 'customer3',
      'password': 'customer123',
      'role': 'customer',
      'name': 'Konsumen 3',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Add sample menu items
    final sampleMenus = [
      // Soup
      {
        'name': 'Tom Yum Soup',
        'description': 'Sup tom yum pedas dengan udang dan jamur',
        'price': 45000.0,
        'category': 'soup',
        'is_available': 1,
      },
      {
        'name': 'Tom Kha Gai',
        'description': 'Sup ayam dengan santan',
        'price': 40000.0,
        'category': 'soup',
        'is_available': 1,
      },
      // Seafood
      {
        'name': 'Udang Fresh',
        'description': 'Udang segar pilihan',
        'price': 55000.0,
        'category': 'seafood',
        'is_available': 1,
      },
      {
        'name': 'Cumi-Cumi',
        'description': 'Cumi-cumi premium',
        'price': 50000.0,
        'category': 'seafood',
        'is_available': 1,
      },
      // Noodle
      {
        'name': 'Ramen',
        'description': 'Ramen dengan kuah gurih',
        'price': 35000.0,
        'category': 'noodle',
        'is_available': 1,
      },
      {
        'name': 'Pad Thai',
        'description': 'Mie goreng Thailand',
        'price': 30000.0,
        'category': 'noodle',
        'is_available': 1,
      },
      // Rice
      {
        'name': 'Nasi Goreng',
        'description': 'Nasi goreng spesial hotpot',
        'price': 25000.0,
        'category': 'rice',
        'is_available': 1,
      },
      {
        'name': 'Nasi Putih',
        'description': 'Nasi putih premium',
        'price': 15000.0,
        'category': 'rice',
        'is_available': 1,
      },
      // Drink
      {
        'name': 'Es Teh Manis',
        'description': 'Teh dingin manis',
        'price': 8000.0,
        'category': 'drink',
        'is_available': 1,
      },
      {
        'name': 'Es Jeruk',
        'description': 'Jeruk dingin segar',
        'price': 10000.0,
        'category': 'drink',
        'is_available': 1,
      },
    ];

    for (var menu in sampleMenus) {
      await db.insert('menu_items', {
        ...menu,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // ===== USER OPERATIONS =====
  Future<User?> getUserByUsernamePassword(
    String username,
    String password,
  ) async {
    try {
      final db = await database;
      final result = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
      );
      if (result.isEmpty) return null;
      return User.fromMap(result.first);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final result = await db.query('users');
    return result.map((e) => User.fromMap(e)).toList();
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    return db.insert('users', user.toMap());
  }

  // ===== MENU OPERATIONS =====
  Future<List<MenuItem>> getAllMenuItems() async {
    final db = await database;
    final result = await db.query(
      'menu_items',
      orderBy: 'category ASC, name ASC',
    );
    return result.map((e) => MenuItem.fromMap(e)).toList();
  }

  Future<List<MenuItem>> getMenuItemsByCategory(MenuCategory category) async {
    final db = await database;
    final result = await db.query(
      'menu_items',
      where: 'category = ? AND is_available = 1',
      whereArgs: [category.toString().split('.').last],
      orderBy: 'name ASC',
    );
    return result.map((e) => MenuItem.fromMap(e)).toList();
  }

  Future<int> insertMenuItem(MenuItem item) async {
    final db = await database;
    return db.insert('menu_items', item.toMap());
  }

  Future<int> updateMenuItem(MenuItem item) async {
    final db = await database;
    return db.update(
      'menu_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteMenuItem(int id) async {
    final db = await database;
    return db.delete('menu_items', where: 'id = ?', whereArgs: [id]);
  }

  // ===== ORDER OPERATIONS =====
  Future<int> insertOrder(Order order) async {
    final db = await database;
    final orderId = await db.insert('orders', order.toMap());

    // Insert order items
    for (var item in order.items) {
      await db.insert('order_items', {...item.toMap(), 'order_id': orderId});
    }

    return orderId;
  }

  Future<List<Order>> getAllOrders() async {
    final db = await database;
    final result = await db.query('orders', orderBy: 'created_at DESC');

    List<Order> orders = [];
    for (var orderMap in result) {
      final items = await _getOrderItems(orderMap['id'] as int);
      orders.add(Order.fromMap(orderMap, items: items));
    }
    return orders;
  }

  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    final db = await database;
    final result = await db.query(
      'orders',
      where: 'status = ?',
      whereArgs: [status.toString().split('.').last],
      orderBy: 'created_at DESC',
    );

    List<Order> orders = [];
    for (var orderMap in result) {
      final items = await _getOrderItems(orderMap['id'] as int);
      orders.add(Order.fromMap(orderMap, items: items));
    }
    return orders;
  }

  Future<List<Order>> getOrdersByCustomerId(int customerId) async {
    final db = await database;
    final result = await db.query(
      'orders',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'created_at DESC',
    );

    List<Order> orders = [];
    for (var orderMap in result) {
      final items = await _getOrderItems(orderMap['id'] as int);
      orders.add(Order.fromMap(orderMap, items: items));
    }
    return orders;
  }

  Future<List<OrderItem>> _getOrderItems(int orderId) async {
    final db = await database;
    final result = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    return result.map((e) => OrderItem.fromMap(e)).toList();
  }

  Future<int> updateOrderStatus(int orderId, OrderStatus status) async {
    final db = await database;
    final completedAt =
        status == OrderStatus.completed
            ? DateTime.now().toIso8601String()
            : null;

    return db.update(
      'orders',
      {
        'status': status.toString().split('.').last,
        'completed_at': completedAt,
      },
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<int> updatePaymentStatus(int orderId, PaymentStatus status) async {
    final db = await database;
    return db.update(
      'orders',
      {'payment_status': status.toString().split('.').last},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<int> updateItemReadyStatus(
    int orderId,
    int itemId,
    bool isReady,
  ) async {
    final db = await database;
    return db.update(
      'order_items',
      {'is_ready': isReady ? 1 : 0},
      where: 'order_id = ? AND id = ?',
      whereArgs: [orderId, itemId],
    );
  }

  Future<Order?> getOrderById(int orderId) async {
    final db = await database;
    final result = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [orderId],
    );
    if (result.isEmpty) return null;
    final items = await _getOrderItems(orderId);
    return Order.fromMap(result.first, items: items);
  }

  // ===== SALES REPORT =====
  Future<List<Order>> getOrdersByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.query(
      'orders',
      where:
          'created_at >= ? AND created_at < ? AND status = ? AND payment_status = ?',
      whereArgs: [
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
        'completed',
        'paid',
      ],
      orderBy: 'created_at DESC',
    );

    List<Order> orders = [];
    for (var orderMap in result) {
      final items = await _getOrderItems(orderMap['id'] as int);
      orders.add(Order.fromMap(orderMap, items: items));
    }
    return orders;
  }

  Future<SaleReport> getSaleReportForDate(DateTime date) async {
    final orders = await getOrdersByDate(date);

    int totalOrders = orders.length;
    double totalRevenue = orders.fold(
      0,
      (sum, order) => sum + order.totalAmount,
    );
    double averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;

    return SaleReport(
      date: date,
      totalOrders: totalOrders,
      totalRevenue: totalRevenue,
      averageOrderValue: averageOrderValue,
    );
  }

  Future<List<SaleReport>> getSaleReportRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    List<SaleReport> reports = [];

    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    ).add(const Duration(days: 1));

    while (current.isBefore(end)) {
      final report = await getSaleReportForDate(current);
      reports.add(report);
      current = current.add(const Duration(days: 1));
    }

    return reports;
  }

  // ===== DATABASE UTILITIES =====
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('order_items');
    await db.delete('orders');
    await db.delete('menu_items');
    await db.delete('users');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
