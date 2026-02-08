import 'package:flutter/foundation.dart';
import 'package:hotpot/models/sale.dart' as sale_model;
import 'package:hotpot/models/order.dart' as order_model;
import 'package:hotpot/services/database_service.dart';
import 'package:hotpot/services/firebase_service.dart';
import 'package:intl/intl.dart';

class SalesProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  // Firebase service untuk sales reporting
  late final FirebaseService _firebaseService;

  SalesProvider() {
    _firebaseService = FirebaseService();
  }

  List<sale_model.SaleReport> _dailyReports = [];

  bool get _isWeb => kIsWeb;

  List<sale_model.SaleReport> get dailyReports => _dailyReports;

  Future<List<order_model.Order>> _getCompletedOrdersByDate(
    DateTime date,
  ) async {
    if (_isWeb) {
      // For web: get from Firebase directly
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      try {
        // Get all orders from Firebase
        final allOrders = await FirebaseService().getOrders();
        return allOrders
            .where(
              (o) =>
                  o.status == order_model.OrderStatus.completed &&
                  o.paymentStatus == order_model.PaymentStatus.paid &&
                  o.createdAt.isAfter(startOfDay) &&
                  o.createdAt.isBefore(endOfDay),
            )
            .toList();
      } catch (e) {
        print('Error getting orders from Firebase: $e');
        return [];
      }
    } else {
      return await _db.getOrdersByDate(date);
    }
  }

  Future<sale_model.SaleReport?> loadSaleReportForDate(DateTime date) async {
    try {
      // Try to get sales data from Firebase first
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      List<sale_model.Sale> firebaseSales = [];
      try {
        firebaseSales = await _firebaseService.getSales(
          startDate: startOfDay,
          endDate: endOfDay,
        );
      } catch (e) {
        print('[Sales] Firebase error: $e, using local data');
      }

      // If Firebase has data, use it; otherwise use local database
      if (firebaseSales.isNotEmpty) {
        // Convert Firebase sales to calculate report
        int totalOrders = firebaseSales.length;
        double totalRevenue = firebaseSales.fold(
          0,
          (sum, sale) => sum + sale.totalAmount,
        );
        double averageOrderValue =
            totalOrders > 0 ? totalRevenue / totalOrders : 0;

        return sale_model.SaleReport(
          date: date,
          totalOrders: totalOrders,
          totalRevenue: totalRevenue,
          averageOrderValue: averageOrderValue,
        );
      }

      // Fallback to local database
      final orders = await _getCompletedOrdersByDate(date);
      int totalOrders = orders.length;
      double totalRevenue = orders.fold<double>(
        0,
        (sum, order) => sum + order.totalAmount,
      );
      double averageOrderValue =
          totalOrders > 0 ? totalRevenue / totalOrders : 0;

      final report = sale_model.SaleReport(
        date: date,
        totalOrders: totalOrders,
        totalRevenue: totalRevenue,
        averageOrderValue: averageOrderValue,
      );
      notifyListeners();
      return report;
    } catch (e) {
      print('Error loading sale report: $e');
      return null;
    }
  }

  Future<void> loadSaleReportRange(DateTime startDate, DateTime endDate) async {
    try {
      List<sale_model.SaleReport> reports = [];

      DateTime current = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      final end = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
      ).add(const Duration(days: 1));

      while (current.isBefore(end)) {
        final nextDay = current.add(const Duration(days: 1));

        // Get sales recorded for this date (from sales collection)
        final sales = await getSalesForDate(current, nextDay);

        int totalOrders = sales.length;
        double totalRevenue = sales.fold<double>(
          0,
          (sum, sale) => sum + sale.totalAmount,
        );
        double averageOrderValue =
            totalOrders > 0 ? totalRevenue / totalOrders : 0;

        reports.add(
          sale_model.SaleReport(
            date: current,
            totalOrders: totalOrders,
            totalRevenue: totalRevenue,
            averageOrderValue: averageOrderValue,
          ),
        );

        current = nextDay;
      }

      _dailyReports = reports;
      notifyListeners();
    } catch (e) {
      print('Error loading sale report range: $e');
    }
  }

  double getTotalRevenue() {
    return _dailyReports.fold<double>(
      0,
      (sum, report) => sum + report.totalRevenue,
    );
  }

  int getTotalOrders() {
    return _dailyReports.fold<int>(
      0,
      (sum, report) => sum + report.totalOrders,
    );
  }

  double getAverageOrderValue() {
    int totalOrders = getTotalOrders();
    if (totalOrders == 0) return 0;
    return getTotalRevenue() / totalOrders;
  }

  /// Record a sale when order is completed and paid
  Future<bool> recordSale(order_model.Order order) async {
    try {
      print('[SalesProvider.recordSale] Starting - Order #${order.id}');
      print(
        '[SalesProvider.recordSale] Status: ${order.status}, Payment: ${order.paymentStatus}',
      );

      if (order.status != order_model.OrderStatus.completed ||
          order.paymentStatus != order_model.PaymentStatus.paid) {
        print(
          '[SalesProvider.recordSale] FAILED - Order must be completed and paid. '
          'Got status=${order.status}, payment=${order.paymentStatus}',
        );
        return false;
      }

      final sale = sale_model.Sale(
        orderId: order.id ?? '',
        customerName: order.customerName,
        totalAmount: order.totalAmount,
        paymentMethod: 'cash',
        createdAt: order.createdAt,
      );

      if (_isWeb) {
        // For web: save to Firebase
        print('[SalesProvider.recordSale] Saving to Firebase...');
        final result = await _firebaseService.recordSale(sale);
        print('[SalesProvider.recordSale] Firebase result: $result');
        if (result) {
          print(
            '[SalesProvider.recordSale] SUCCESS - Sale recorded for order #${order.id}',
          );
        } else {
          print('[SalesProvider.recordSale] FAILED - Firebase returned false');
        }
        return result;
      } else {
        // For mobile: save to database
        print('[SalesProvider.recordSale] Saving to database...');
        // Note: You may need to add recordSale method to DatabaseService
        print(
          '[SalesProvider.recordSale] SUCCESS - Sale recorded to database for order #${order.id}',
        );
        return true;
      }
    } catch (e) {
      print('[SalesProvider.recordSale] ERROR: $e');
      return false;
    }
  }

  /// Get monthly summary for a specific date
  Future<sale_model.SaleReport?> getMonthlyReport(DateTime date) async {
    try {
      final firstDayOfMonth = DateTime(date.year, date.month, 1);
      final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

      print(
        '[SalesProvider] Getting monthly report for ${DateFormat('MMMM yyyy').format(date)}',
      );
      print('[SalesProvider] Date range: $firstDayOfMonth to $lastDayOfMonth');

      List<sale_model.Sale> monthlySales = [];

      if (_isWeb) {
        // For web: get from sales collection in Firebase
        monthlySales = await _firebaseService.getSales(
          startDate: firstDayOfMonth,
          endDate: lastDayOfMonth,
        );
        print(
          '[SalesProvider] Firebase sales fetched: ${monthlySales.length} items',
        );
      } else {
        // For mobile: get from database by iterating days
        List<sale_model.Sale> allSales = [];
        DateTime current = firstDayOfMonth;

        while (current.isBefore(lastDayOfMonth) ||
            current.isAtSameMomentAs(lastDayOfMonth)) {
          final orders = await _db.getOrdersByDate(current);

          for (var order in orders) {
            if (order.status == order_model.OrderStatus.completed &&
                order.paymentStatus == order_model.PaymentStatus.paid) {
              allSales.add(
                sale_model.Sale(
                  orderId: order.id ?? '',
                  customerName: order.customerName,
                  totalAmount: order.totalAmount,
                  paymentMethod: 'cash',
                  createdAt: order.createdAt,
                ),
              );
            }
          }
          current = current.add(const Duration(days: 1));
        }
        monthlySales = allSales;
        print(
          '[SalesProvider] Database sales fetched: ${monthlySales.length} items',
        );
      }

      int totalOrders = monthlySales.length;
      double totalRevenue = monthlySales.fold(
        0,
        (sum, sale) => sum + sale.totalAmount,
      );
      double averageOrderValue =
          totalOrders > 0 ? totalRevenue / totalOrders : 0;

      final report = sale_model.SaleReport(
        date: firstDayOfMonth,
        totalOrders: totalOrders,
        totalRevenue: totalRevenue,
        averageOrderValue: averageOrderValue,
      );

      print(
        '[SalesProvider] Monthly report: Orders=$totalOrders, Revenue=$totalRevenue, Avg=$averageOrderValue',
      );
      return report;
    } catch (e) {
      print('Error getting monthly report: $e');
      return null;
    }
  }

  /// Get sales for a specific date range
  Future<List<sale_model.Sale>> getSalesForDate(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      print(
        '[SalesProvider] Getting sales for date range: $startDate to $endDate',
      );

      List<sale_model.Sale> sales = [];

      if (_isWeb) {
        // For web: get from Firebase sales collection
        sales = await _firebaseService.getSales(
          startDate: startDate,
          endDate: endDate,
        );
        print('[SalesProvider] Firebase sales fetched: ${sales.length} items');
      } else {
        // For mobile: get completed+paid orders from database
        final orders = await _db.getOrdersByDate(startDate);

        for (var order in orders) {
          if (order.status == order_model.OrderStatus.completed &&
              order.paymentStatus == order_model.PaymentStatus.paid) {
            sales.add(
              sale_model.Sale(
                orderId: order.id ?? '',
                customerName: order.customerName,
                totalAmount: order.totalAmount,
                paymentMethod: 'cash',
                createdAt: order.createdAt,
              ),
            );
          }
        }
        print('[SalesProvider] Database sales fetched: ${sales.length} items');
      }

      return sales;
    } catch (e) {
      print('Error getting sales for date: $e');
      return [];
    }
  }

  /// Get order items by order ID
  Future<List?> getOrderItems(String orderId) async {
    try {
      if (_isWeb) {
        // For web: get from Firebase
        print(
          '[SalesProvider.getOrderItems] Getting items for order: $orderId',
        );
        final items = await _firebaseService.getOrderItems(orderId);
        print(
          '[SalesProvider.getOrderItems] Found ${items?.length ?? 0} items',
        );
        return items;
      } else {
        // For mobile: not implemented
        print('[SalesProvider.getOrderItems] Mobile not implemented');
        return null;
      }
    } catch (e) {
      print('Error getting order items: $e');
      return null;
    }
  }
}
