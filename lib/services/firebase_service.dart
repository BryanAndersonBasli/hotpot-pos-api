import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:hotpot/models/user.dart' as user_model;
import 'package:hotpot/models/menu_item.dart';
import 'package:hotpot/models/order.dart' as order_model;
import 'package:hotpot/models/sale.dart' as sale_model;

class FirebaseService {
  static final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== AUTH METHODS ====================

  /// Register user dengan Firebase Auth
  Future<bool> registerUser({
    required String email,
    required String password,
    required String username,
    required String name,
    required String role,
  }) async {
    try {
      // Create Firebase Auth user
      fb_auth.UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save additional user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'username': username,
        'name': name,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  /// Login user dengan Firebase Auth
  Future<user_model.User?> loginUser(String email, String password) async {
    try {
      fb_auth.UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      // Get user data from Firestore
      DocumentSnapshot doc =
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return user_model.User(
          username: data['username'] ?? '',
          password: '', // Don't store password in memory
          role: _getRoleFromString(data['role'] ?? 'customer'),
          name: data['name'] ?? '',
        );
      }
      return null;
    } on fb_auth.FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }

  /// Logout user
  Future<void> logoutUser() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  /// Get current user
  user_model.User? getCurrentUser() {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      // Return a basic user object
      return user_model.User(
        username: firebaseUser.email ?? '',
        password: '',
        role: user_model.UserRole.customer,
        name: firebaseUser.displayName ?? '',
      );
    }
    return null;
  }

  // ==================== MENU ITEMS METHODS ====================

  /// Add menu item
  Future<bool> addMenuItem(MenuItem item) async {
    try {
      await _firestore.collection('menu_items').add({
        'name': item.name,
        'description': item.description,
        'price': item.price,
        'category': item.category.toString(),
        'image': item.image,
        'is_available': item.isAvailable,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } on FirebaseException catch (e) {
      print('Firebase Error adding menu: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('Error adding menu item: $e');
      return false;
    }
  }

  /// Get all menu items
  Future<List<MenuItem>> getMenuItems() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('menu_items').get();
      print(
        '[FirebaseService.getMenuItems] Found ${snapshot.docs.length} documents',
      );

      final items =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final categoryStr = data['category'] ?? '';
            final category = _getCategoryFromString(categoryStr);
            print(
              '[FirebaseService.getMenuItems] Item: ${data['name']}, Raw category: $categoryStr, Parsed: ${category.toString()}',
            );

            return MenuItem(
              id: int.tryParse(doc.id) ?? 0,
              docId: doc.id, // Store Firebase document ID
              name: data['name'] ?? '',
              description: data['description'] ?? '',
              price: (data['price'] ?? 0).toDouble(),
              category: category,
              image: data['image'],
              isAvailable: data['is_available'] ?? true,
            );
          }).toList();

      print(
        '[FirebaseService.getMenuItems] Returning ${items.length} parsed items',
      );
      return items;
    } catch (e) {
      print('Error getting menu items: $e');
      return [];
    }
  }

  /// Update menu item
  Future<bool> updateMenuItem(String docId, MenuItem item) async {
    try {
      await _firestore.collection('menu_items').doc(docId).update({
        'name': item.name,
        'description': item.description,
        'price': item.price,
        'category': item.category.toString(),
        'image': item.image,
        'is_available': item.isAvailable,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating menu item: $e');
      return false;
    }
  }

  /// Delete menu item
  Future<bool> deleteMenuItem(String docId) async {
    try {
      await _firestore.collection('menu_items').doc(docId).delete();
      return true;
    } catch (e) {
      print('Error deleting menu item: $e');
      return false;
    }
  }

  // ==================== ORDERS METHODS ====================

  /// Create new order
  Future<String?> createOrder(order_model.Order order) async {
    try {
      // First, create order document to get the auto-generated ID
      DocumentReference docRef = await _firestore.collection('orders').add({
        'order_id': 0, // Placeholder, will be updated with doc ID
        'customer_id': order.customerId,
        'customer_name': order.customerName,
        'table_number': order.tableNumber,
        'status': order.status.toString(),
        'payment_status': order.paymentStatus.toString(),
        'total_amount': order.totalAmount,
        'created_at': DateTime.now().toIso8601String(),
        'completed_at': order.completedAt,
      });

      final docId = docRef.id;
      print(
        '[FirebaseService.createOrder] Order document created with ID: $docId',
      );

      // Update order with its document ID
      await docRef.update({'order_id': docId});

      // Add order items
      for (var item in order.items) {
        await docRef.collection('items').add({
          'menu_item_id': item.menuItemId,
          'menu_item_name': item.menuItemName,
          'price': item.price,
          'quantity': item.quantity,
          'subtotal': item.subtotal,
          'is_ready': item.isReady,
        });
      }

      return docId;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  /// Get all orders
  Future<List<order_model.Order>> getOrders() async {
    try {
      print('[FirebaseService.getOrders] Fetching all orders from Firebase');
      QuerySnapshot snapshot =
          await _firestore
              .collection('orders')
              .orderBy('created_at', descending: true)
              .get();

      print(
        '[FirebaseService.getOrders] Found ${snapshot.docs.length} order documents',
      );

      List<order_model.Order> orders = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final itemsSnapshot = await doc.reference.collection('items').get();

        // Use order_id from Firestore field (which is the document ID stored as string)
        final orderId = data['order_id'] as String? ?? doc.id;
        print(
          '[FirebaseService.getOrders] Processing order: $orderId, Status: ${data['status']}, Payment: ${data['payment_status']}',
        );

        orders.add(
          order_model.Order(
            id: orderId,
            customerId: data['customer_id'] ?? 0,
            customerName: data['customer_name'] ?? '',
            tableNumber: data['table_number'] ?? 0,
            status: _getOrderStatusFromString(data['status'] ?? ''),
            paymentStatus: _getPaymentStatusFromString(
              data['payment_status'] ?? '',
            ),
            totalAmount: (data['total_amount'] ?? 0).toDouble(),
            items:
                itemsSnapshot.docs.map((itemDoc) {
                  final itemData = itemDoc.data();
                  return order_model.OrderItem(
                    id: int.tryParse(itemDoc.id) ?? 0,
                    docId: itemDoc.id,
                    orderId: 0, // Not used anymore
                    menuItemId: itemData['menu_item_id'] ?? 0,
                    menuItemName: itemData['menu_item_name'] ?? '',
                    price: (itemData['price'] ?? 0).toDouble(),
                    quantity: itemData['quantity'] ?? 0,
                    subtotal: (itemData['subtotal'] ?? 0).toDouble(),
                    isReady: itemData['is_ready'] ?? false,
                  );
                }).toList(),
            createdAt: DateTime.parse(data['created_at'] ?? '2024-01-01'),
            completedAt:
                data['completed_at'] != null
                    ? DateTime.parse(data['completed_at'])
                    : null,
          ),
        );
      }
      print(
        '[FirebaseService.getOrders] Total orders loaded: ${orders.length}',
      );
      return orders;
    } catch (e) {
      print('Error getting orders: $e');
      return [];
    }
  }

  /// Update order
  Future<bool> updateOrder(String docId, order_model.Order order) async {
    try {
      await _firestore.collection('orders').doc(docId).update({
        'status': order.status.toString(),
        'payment_status': order.paymentStatus.toString(),
        'total_amount': order.totalAmount,
        'completed_at': order.completedAt,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating order: $e');
      return false;
    }
  }

  /// Update order status by order ID (now String)
  Future<bool> updateOrderStatus(
    String orderId,
    order_model.OrderStatus status,
  ) async {
    try {
      print(
        '[FirebaseService.updateOrderStatus] Updating order $orderId to ${status.toString()}',
      );
      // Order ID is now the Firebase document ID (string)
      await _firestore.collection('orders').doc(orderId).update({
        'status': status.toString(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      print(
        '[FirebaseService.updateOrderStatus] Successfully updated order $orderId',
      );
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  /// Update payment status by order ID (now String)
  Future<bool> updatePaymentStatus(
    String orderId,
    order_model.PaymentStatus status,
  ) async {
    try {
      print(
        '[FirebaseService.updatePaymentStatus] Updating order $orderId payment to ${status.toString()}',
      );
      // Order ID is now the Firebase document ID (string)
      await _firestore.collection('orders').doc(orderId).update({
        'payment_status': status.toString(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      print(
        '[FirebaseService.updatePaymentStatus] Successfully updated payment for order $orderId',
      );
      return true;
    } catch (e) {
      print('Error updating payment status: $e');
      return false;
    }
  }

  /// Update item ready status
  Future<bool> updateItemReadyStatus(
    String orderId,
    String? itemDocId,
    bool isReady,
  ) async {
    try {
      // itemDocId is the Firebase document ID of the item
      if (itemDocId == null || itemDocId.isEmpty) {
        print('Invalid item doc ID');
        return false;
      }

      print(
        '[FirebaseService.updateItemReadyStatus] Updating item $itemDocId in order $orderId to isReady=$isReady',
      );

      // Order ID is now the Firebase document ID (string)
      await _firestore
          .collection('orders')
          .doc(orderId)
          .collection('items')
          .doc(itemDocId)
          .update({'is_ready': isReady});

      print(
        '[FirebaseService.updateItemReadyStatus] Successfully updated item ready status',
      );
      return true;
    } catch (e) {
      print('Error updating item ready status: $e');
      return false;
    }
  }

  // ==================== SALES METHODS ====================

  /// Record sale
  Future<bool> recordSale(sale_model.Sale sale) async {
    try {
      print(
        '[FirebaseService.recordSale] Starting - Sale for order #${sale.orderId}',
      );
      print(
        '[FirebaseService.recordSale] Customer: ${sale.customerName}, Amount: ${sale.totalAmount}',
      );

      final docRef = await _firestore.collection('sales').add({
        'order_id': sale.orderId,
        'customer_name': sale.customerName,
        'total_amount': sale.totalAmount,
        'payment_method': sale.paymentMethod,
        'created_at': DateTime.now().toIso8601String(),
      });

      print(
        '[FirebaseService.recordSale] SUCCESS - Document created with ID: ${docRef.id}',
      );
      return true;
    } catch (e) {
      print('[FirebaseService.recordSale] ERROR: $e');
      return false;
    }
  }

  /// Get sales
  Future<List<sale_model.Sale>> getSales({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('sales');

      if (startDate != null) {
        // Convert to start of day to include all sales from start date
        final startOfDay = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        );
        query = query.where(
          'created_at',
          isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
        );
        print(
          '[FirebaseService.getSales] Filtering from: ${startOfDay.toIso8601String()}',
        );
      }
      if (endDate != null) {
        // Convert to end of day to include all sales from end date
        final endOfDay = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
        );
        query = query.where(
          'created_at',
          isLessThanOrEqualTo: endOfDay.toIso8601String(),
        );
        print(
          '[FirebaseService.getSales] Filtering to: ${endOfDay.toIso8601String()}',
        );
      }

      print('[FirebaseService.getSales] Executing query for sales collection');
      QuerySnapshot snapshot =
          await query.orderBy('created_at', descending: true).get();
      print(
        '[FirebaseService.getSales] Query returned ${snapshot.docs.length} documents',
      );

      final sales =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final sale = sale_model.Sale(
              id: int.tryParse(doc.id) ?? 0,
              orderId: data['order_id'] ?? 0,
              customerName: data['customer_name'] ?? '',
              totalAmount: (data['total_amount'] ?? 0).toDouble(),
              paymentMethod: data['payment_method'] ?? 'cash',
              createdAt:
                  DateTime.tryParse(
                    data['created_at'] as String? ?? '2024-01-01',
                  ) ??
                  DateTime.now(),
            );
            print(
              '[FirebaseService.getSales] Loaded sale: OrderID=${sale.orderId}, Customer=${sale.customerName}, Amount=${sale.totalAmount}, Date=${sale.createdAt}',
            );
            return sale;
          }).toList();
      print('[FirebaseService.getSales] Total sales returned: ${sales.length}');
      return sales;
    } catch (e) {
      print('Error getting sales: $e');
      return [];
    }
  }

  // ==================== HELPER METHODS ====================

  user_model.UserRole _getRoleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return user_model.UserRole.owner;
      case 'cashier':
        return user_model.UserRole.cashier;
      default:
        return user_model.UserRole.customer;
    }
  }

  MenuCategory _getCategoryFromString(String category) {
    try {
      // Handle both formats: 'broth' or 'MenuCategory.broth'
      String normalizedCategory = category;
      if (category.contains('.')) {
        normalizedCategory = category.split('.').last;
      }

      return MenuCategory.values.firstWhere(
        (e) => e.toString().split('.').last == normalizedCategory,
        orElse: () => MenuCategory.beef,
      );
    } catch (e) {
      print('[MenuCategory] Error parsing category: $category, error: $e');
      return MenuCategory.beef;
    }
  }

  order_model.OrderStatus _getOrderStatusFromString(String status) {
    try {
      return order_model.OrderStatus.values.firstWhere(
        (e) => e.toString() == status,
        orElse: () => order_model.OrderStatus.pending,
      );
    } catch (e) {
      return order_model.OrderStatus.pending;
    }
  }

  order_model.PaymentStatus _getPaymentStatusFromString(String status) {
    try {
      return order_model.PaymentStatus.values.firstWhere(
        (e) => e.toString() == status,
        orElse: () => order_model.PaymentStatus.unpaid,
      );
    } catch (e) {
      return order_model.PaymentStatus.unpaid;
    }
  }

  /// Stream of menu items (real-time updates)
  Stream<List<MenuItem>> getMenuItemsStream() {
    return _firestore.collection('menu_items').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return MenuItem(
          id: int.tryParse(doc.id) ?? 0,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          category: _getCategoryFromString(data['category'] ?? ''),
          image: data['image'],
          isAvailable: data['is_available'] ?? true,
        );
      }).toList();
    });
  }

  /// Stream of orders (real-time updates)
  Stream<List<order_model.Order>> getOrdersStream() {
    return _firestore
        .collection('orders')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            final orderId = data['order_id'] as String? ?? doc.id;
            return order_model.Order(
              id: orderId,
              customerId: data['customer_id'] ?? 0,
              customerName: data['customer_name'] ?? '',
              tableNumber: data['table_number'] ?? 0,
              status: _getOrderStatusFromString(data['status'] ?? ''),
              paymentStatus: _getPaymentStatusFromString(
                data['payment_status'] ?? '',
              ),
              totalAmount: (data['total_amount'] ?? 0).toDouble(),
              items: [],
              createdAt: DateTime.parse(data['created_at'] ?? '2024-01-01'),
              completedAt:
                  data['completed_at'] != null
                      ? DateTime.parse(data['completed_at'])
                      : null,
            );
          }).toList();
        });
  }

  /// Get order items by order ID
  Future<List?> getOrderItems(String orderId) async {
    try {
      print(
        '[FirebaseService.getOrderItems] Fetching items for order: $orderId',
      );

      final itemsSnapshot =
          await _firestore
              .collection('orders')
              .doc(orderId)
              .collection('items')
              .get();

      final items =
          itemsSnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'menuItemId': data['menu_item_id'] ?? 0,
              'menuItemName': data['menu_item_name'] ?? '',
              'price': (data['price'] ?? 0).toDouble(),
              'quantity': data['quantity'] ?? 0,
              'subtotal': (data['subtotal'] ?? 0).toDouble(),
              'isReady': data['is_ready'] ?? false,
            };
          }).toList();

      print('[FirebaseService.getOrderItems] Retrieved ${items.length} items');
      return items;
    } catch (e) {
      print('Error getting order items: $e');
      return null;
    }
  }

  /// Seed Firebase dengan menu items default jika collection kosong
  Future<bool> seedMenuItemsIfEmpty() async {
    try {
      // Check if menu_items collection already has data
      QuerySnapshot snapshot =
          await _firestore.collection('menu_items').limit(1).get();

      if (snapshot.docs.isNotEmpty) {
        // Double check - verify if existing items have correct category format
        final firstItem = snapshot.docs.first.data() as Map<String, dynamic>;
        final category = firstItem['category'] as String? ?? '';

        // If category contains 'MenuCategory.' it's old format, need to reset
        if (category.contains('MenuCategory.')) {
          print(
            '[FirebaseService.seedMenuItemsIfEmpty] Found old category format, clearing and re-seeding...',
          );
          await _firestore.collection('menu_items').get().then((snapshot) {
            for (var doc in snapshot.docs) {
              doc.reference.delete();
            }
          });
        } else {
          print(
            '[FirebaseService.seedMenuItemsIfEmpty] Menu items already exist with correct format, skipping seed',
          );
          return true;
        }
      }

      print('[FirebaseService.seedMenuItemsIfEmpty] Seeding menu items...');

      final defaultMenuItems = [
        // ===== KUAH HOTPOT =====
        {
          'name': 'Kuah Original',
          'description': 'Kuah asli yang nikmat dengan aromaterapi menyegarkan',
          'price': 35000,
          'category': 'broth',
          'is_available': true,
        },
        {
          'name': 'Kuah Pedas',
          'description': 'Kuah panas dengan cabai pilihan level 3',
          'price': 35000,
          'category': 'broth',
          'is_available': true,
        },
        {
          'name': 'Kuah Tom Yum',
          'description': 'Kuah asam pedas dengan serai dan jeruk nipis',
          'price': 40000,
          'category': 'broth',
          'is_available': true,
        },
        {
          'name': 'Kuah Ayam Putih',
          'description': 'Kuah dari kaldu ayam berkualitas premium',
          'price': 38000,
          'category': 'broth',
          'is_available': true,
        },

        // ===== DAGING SAPI =====
        {
          'name': 'Wagyu Premium',
          'description': 'Daging wagyu asli Jepang dengan marbling sempurna',
          'price': 185000,
          'category': 'beef',
          'is_available': true,
        },
        {
          'name': 'Beef Sliced US',
          'description': 'Irisan daging sapi premium dari Amerika',
          'price': 125000,
          'category': 'beef',
          'is_available': true,
        },
        {
          'name': 'Sirloin Potongan',
          'description': 'Potongan sirloin tebal empuk berkualitas tinggi',
          'price': 95000,
          'category': 'beef',
          'is_available': true,
        },

        // ===== AYAM =====
        {
          'name': 'Ayam Premium Slice',
          'description': 'Irisan daging ayam premium yang lembut',
          'price': 65000,
          'category': 'chicken',
          'is_available': true,
        },
        {
          'name': 'Chicken Balls',
          'description': 'Bola daging ayam homemade empuk lezat',
          'price': 55000,
          'category': 'chicken',
          'is_available': true,
        },

        // ===== HASIL LAUT =====
        {
          'name': 'Udang Jumbo',
          'description': 'Udang raksasa segar premium import',
          'price': 95000,
          'category': 'seafood',
          'is_available': true,
        },
        {
          'name': 'Cumi-Cumi Premium',
          'description': 'Cumi-cumi pilihan dengan tekstur lembut',
          'price': 85000,
          'category': 'seafood',
          'is_available': true,
        },
        {
          'name': 'Ikan Salmon',
          'description': 'Fillet salmon Norwegia berkualitas A',
          'price': 125000,
          'category': 'seafood',
          'is_available': true,
        },

        // ===== SAYURAN =====
        {
          'name': 'Sayuran Hijau Segar',
          'description': 'Campuran selada, kangkung, dan bayam organik',
          'price': 28000,
          'category': 'vegetable',
          'is_available': true,
        },
        {
          'name': 'Jamur Campuran',
          'description': 'Jamur shiitake, enoki, dan oyster pilihan',
          'price': 35000,
          'category': 'vegetable',
          'is_available': true,
        },

        // ===== TAHU =====
        {
          'name': 'Tahu Premium',
          'description': 'Tahu lembut premium asli Jepang',
          'price': 25000,
          'category': 'tofu',
          'is_available': true,
        },
        {
          'name': 'Telur Puyuh',
          'description': 'Telur puyuh segar premium',
          'price': 18000,
          'category': 'tofu',
          'is_available': true,
        },

        // ===== MIE =====
        {
          'name': 'Ramen Jepang',
          'description': 'Mie ramen dengan kualitas terbaik',
          'price': 35000,
          'category': 'noodle',
          'is_available': true,
        },
        {
          'name': 'Udon Premium',
          'description': 'Mie udon tebal dan kenyal',
          'price': 32000,
          'category': 'noodle',
          'is_available': true,
        },

        // ===== NASI =====
        {
          'name': 'Nasi Putih Premium',
          'description': 'Nasi putih pilihan berkualitas tinggi',
          'price': 15000,
          'category': 'rice',
          'is_available': true,
        },
        {
          'name': 'Nasi Goreng Khusus',
          'description': 'Nasi goreng dengan bahan premium',
          'price': 28000,
          'category': 'rice',
          'is_available': true,
        },

        // ===== MINUMAN =====
        {
          'name': 'Es Teh Manis',
          'description': 'Teh dingin manis segar',
          'price': 8000,
          'category': 'drink',
          'is_available': true,
        },
        {
          'name': 'Es Jeruk',
          'description': 'Jeruk dingin segar',
          'price': 10000,
          'category': 'drink',
          'is_available': true,
        },
        {
          'name': 'Kopi Premium',
          'description': 'Kopi premium pilihan',
          'price': 15000,
          'category': 'drink',
          'is_available': true,
        },

        // ===== DESSERT =====
        {
          'name': 'Mochi Ice Cream',
          'description': 'Mochi lembut dengan isi es krim premium',
          'price': 22000,
          'category': 'dessert',
          'is_available': true,
        },
        {
          'name': 'Tiramisu Premium',
          'description': 'Tiramisu lezat dengan resep Italy',
          'price': 28000,
          'category': 'dessert',
          'is_available': true,
        },

        // ===== TAMBAHAN BROTH =====
        {
          'name': 'Kuah Belekan Signature',
          'description': 'Kuah belekan khas dengan sambal rajungan',
          'price': 42000,
          'category': 'broth',
          'is_available': true,
        },

        // ===== TAMBAHAN BEEF =====
        {
          'name': 'Beef Marbling Grade A',
          'description': 'Daging sapi premium dengan marbling sempurna',
          'price': 145000,
          'category': 'beef',
          'is_available': true,
        },
        {
          'name': 'Tenderloin Slice Premium',
          'description': 'Irisan tenderloin premium lembut',
          'price': 155000,
          'category': 'beef',
          'is_available': true,
        },

        // ===== TAMBAHAN CHICKEN =====
        {
          'name': 'Chicken Meatballs',
          'description': 'Bola daging ayam dengan rempah pilihan',
          'price': 58000,
          'category': 'chicken',
          'is_available': true,
        },
        {
          'name': 'Chicken Skin Crispy',
          'description': 'Kulit ayam dengan tekstur renyah',
          'price': 42000,
          'category': 'chicken',
          'is_available': true,
        },

        // ===== TAMBAHAN SEAFOOD =====
        {
          'name': 'Scallops Premium',
          'description': 'Kerang scallop premium dari Jepang',
          'price': 105000,
          'category': 'seafood',
          'is_available': true,
        },
        {
          'name': 'Fish Cake Homemade',
          'description': 'Kue ikan homemade dengan bahan premium',
          'price': 65000,
          'category': 'seafood',
          'is_available': true,
        },

        // ===== TAMBAHAN VEGETABLE =====
        {
          'name': 'Corn & Broccoli',
          'description': 'Jagung manis dan brokoli segar organik',
          'price': 30000,
          'category': 'vegetable',
          'is_available': true,
        },
        {
          'name': 'Mixed Mushroom Deluxe',
          'description': 'Campuran 5 jenis jamur premium pilihan',
          'price': 42000,
          'category': 'vegetable',
          'is_available': true,
        },
        {
          'name': 'Leafy Green Mix',
          'description': 'Campuran sayuran hijau segar organik',
          'price': 32000,
          'category': 'vegetable',
          'is_available': true,
        },

        // ===== TAMBAHAN TOFU =====
        {
          'name': 'Silken Tofu Premium',
          'description': 'Tahu sutra super lembut premium import',
          'price': 28000,
          'category': 'tofu',
          'is_available': true,
        },
        {
          'name': 'Fried Tofu Pockets',
          'description': 'Kantong tahu goreng krispy premium',
          'price': 22000,
          'category': 'tofu',
          'is_available': true,
        },
        {
          'name': 'Quail Egg Cooked',
          'description': 'Telur puyuh rebus setengah matang',
          'price': 20000,
          'category': 'tofu',
          'is_available': true,
        },

        // ===== TAMBAHAN NOODLE =====
        {
          'name': 'Rice Noodle Thin',
          'description': 'Mi beras halus untuk hotpot premium',
          'price': 28000,
          'category': 'noodle',
          'is_available': true,
        },
        {
          'name': 'Egg Noodle Premium',
          'description': 'Mi telur premium dengan telur ayam organik',
          'price': 30000,
          'category': 'noodle',
          'is_available': true,
        },
        {
          'name': 'Vermicelli Noodle',
          'description': 'Mi bihun premium untuk hotpot',
          'price': 25000,
          'category': 'noodle',
          'is_available': true,
        },

        // ===== TAMBAHAN RICE =====
        {
          'name': 'Jasmine Rice Premium',
          'description': 'Nasi wangi premium berkualitas tinggi',
          'price': 18000,
          'category': 'rice',
          'is_available': true,
        },
        {
          'name': 'Chicken Fried Rice',
          'description': 'Nasi goreng ayam dengan bahan premium',
          'price': 32000,
          'category': 'rice',
          'is_available': true,
        },
        {
          'name': 'Seafood Fried Rice',
          'description': 'Nasi goreng hasil laut pilihan',
          'price': 35000,
          'category': 'rice',
          'is_available': true,
        },

        // ===== TAMBAHAN DRINK =====
        {
          'name': 'Fresh Lemongrass Tea',
          'description': 'Teh serai segar dengan madu alami',
          'price': 12000,
          'category': 'drink',
          'is_available': true,
        },
        {
          'name': 'Mango Juice Fresh',
          'description': 'Jus mangga segar premium',
          'price': 14000,
          'category': 'drink',
          'is_available': true,
        },
        {
          'name': 'Thai Iced Tea',
          'description': 'Teh Thailand dingin dengan susu kental',
          'price': 16000,
          'category': 'drink',
          'is_available': true,
        },

        // ===== TAMBAHAN DESSERT =====
        {
          'name': 'Chocolate Mousse',
          'description': 'Mousse cokelat premium dengan topping',
          'price': 32000,
          'category': 'dessert',
          'is_available': true,
        },
        {
          'name': 'Mango Sticky Rice',
          'description': 'Mangga dengan nasi ketan premium',
          'price': 28000,
          'category': 'dessert',
          'is_available': true,
        },
      ];

      // Add all menu items to Firebase
      int count = 0;
      for (var item in defaultMenuItems) {
        await _firestore.collection('menu_items').add({
          'name': item['name'],
          'description': item['description'],
          'price': item['price'],
          'category': item['category'],
          'image': null,
          'is_available': item['is_available'],
          'created_at': DateTime.now().toIso8601String(),
        });
        count++;
      }

      print(
        '[FirebaseService.seedMenuItemsIfEmpty] Successfully seeded $count menu items',
      );
      return true;
    } catch (e) {
      print('Error seeding menu items: $e');
      return false;
    }
  }
}
