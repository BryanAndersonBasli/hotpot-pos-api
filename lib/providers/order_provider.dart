import 'package:flutter/foundation.dart';
import 'package:hotpot/models/order.dart';
import 'package:hotpot/services/database_service.dart';
import 'package:hotpot/services/firebase_service.dart';

class OrderProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final FirebaseService _firebaseService = FirebaseService();

  List<Order> _allOrders = [];
  List<Order> _pendingOrders = [];
  List<Order> _processingOrders = [];
  List<Order> _completedOrders = [];

  bool get _isWeb => kIsWeb;

  List<Order> get allOrders => _allOrders;
  List<Order> get pendingOrders => _pendingOrders;
  List<Order> get processingOrders => _processingOrders;
  List<Order> get completedOrders => _completedOrders;

  Future<void> loadAllOrders() async {
    try {
      List<Order> orders = [];

      // Try Firebase first
      try {
        orders = await _firebaseService.getOrders();
        print('[Orders] Loaded ${orders.length} orders from Firebase');
      } catch (e) {
        print('[Orders] Firebase error: $e');
      }

      if (_isWeb) {
        // For web: ONLY use Firebase orders
        _allOrders = orders;
        _pendingOrders =
            _allOrders.where((o) => o.status == OrderStatus.pending).toList();
        _processingOrders =
            _allOrders
                .where((o) => o.status == OrderStatus.processing)
                .toList();
        _completedOrders =
            _allOrders.where((o) => o.status == OrderStatus.completed).toList();
      } else {
        // Try database
        if (orders.isEmpty) {
          try {
            orders = await _db.getAllOrders();
          } catch (e) {
            print('[Orders] Database error: $e');
          }
        }
        _allOrders = orders;
        _pendingOrders = await _db.getOrdersByStatus(OrderStatus.pending);
        _processingOrders = await _db.getOrdersByStatus(OrderStatus.processing);
        _completedOrders = await _db.getOrdersByStatus(OrderStatus.completed);
      }
      notifyListeners();
    } catch (e) {
      print('Error loading orders: $e');
    }
  }

  Future<bool> createOrder(Order order) async {
    try {
      if (_isWeb) {
        // Web: ONLY save to Firebase for persistence
        final firebaseOrderId = await _firebaseService.createOrder(order);
        if (firebaseOrderId == null) {
          print('Error: Firebase returned null order ID');
          return false;
        }
      } else {
        await _db.insertOrder(order);
      }
      await loadAllOrders();
      return true;
    } catch (e) {
      print('Error creating order: $e');
      return false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      if (_isWeb) {
        // Web: Update Firebase then reload
        await _firebaseService.updateOrderStatus(orderId, status);
      } else {
        // Mobile: Not implemented for now
        print(
          '[OrderProvider.updateOrderStatus] Mobile update not implemented',
        );
      }
      await loadAllOrders();
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  Future<bool> updatePaymentStatus(String orderId, PaymentStatus status) async {
    try {
      if (_isWeb) {
        // Web: Update Firebase then reload
        await _firebaseService.updatePaymentStatus(orderId, status);
      } else {
        // Mobile: Not implemented for now
        print(
          '[OrderProvider.updatePaymentStatus] Mobile update not implemented',
        );
      }
      await loadAllOrders();
      return true;
    } catch (e) {
      print('Error updating payment status: $e');
      return false;
    }
  }

  Future<Order?> getOrderById(String orderId) async {
    try {
      if (_isWeb) {
        // Web: Get from current loaded orders
        try {
          return _allOrders.firstWhere((o) => o.id == orderId);
        } catch (e) {
          return null;
        }
      } else {
        // Mobile: Not implemented
        print('[OrderProvider.getOrderById] Mobile lookup not implemented');
        return null;
      }
    } catch (e) {
      print('Error getting order: $e');
      return null;
    }
  }

  Future<List<Order>> getCustomerOrders(int customerId) async {
    try {
      if (_isWeb) {
        return _allOrders.where((o) => o.customerId == customerId).toList();
      } else {
        return await _db.getOrdersByCustomerId(customerId);
      }
    } catch (e) {
      print('Error getting customer orders: $e');
      return [];
    }
  }

  Future<bool> updateItemReadyStatus(
    String orderId,
    String? itemDocId,
    bool isReady,
  ) async {
    try {
      if (_isWeb) {
        // Web: Update Firebase then reload
        await _firebaseService.updateItemReadyStatus(
          orderId,
          itemDocId,
          isReady,
        );
      } else {
        // Mobile: Not implemented
        print(
          '[OrderProvider.updateItemReadyStatus] Mobile update not implemented',
        );
      }
      await loadAllOrders();
      return true;
    } catch (e) {
      print('Error updating item ready status: $e');
      return false;
    }
  }

  bool allItemsReady(Order order) {
    return order.items.isNotEmpty && order.items.every((item) => item.isReady);
  }
}
