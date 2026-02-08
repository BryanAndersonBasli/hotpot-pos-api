class Sale {
  final int id;
  final String orderId; // Changed from int to String to match Order.id
  final String customerName;
  final double totalAmount;
  final String paymentMethod;
  final DateTime createdAt;

  Sale({
    this.id = 0,
    required this.orderId,
    required this.customerName,
    required this.totalAmount,
    this.paymentMethod = 'cash',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'customer_name': customerName,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static Sale fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] ?? 0,
      orderId: map['order_id'] ?? '',
      customerName: map['customer_name'] ?? '',
      totalAmount: (map['total_amount'] ?? 0).toDouble(),
      paymentMethod: map['payment_method'] ?? 'cash',
      createdAt: DateTime.parse(map['created_at'] ?? '2024-01-01'),
    );
  }
}

class SaleReport {
  final DateTime date;
  final int totalOrders;
  final double totalRevenue;
  final double averageOrderValue;

  SaleReport({
    required this.date,
    required this.totalOrders,
    required this.totalRevenue,
    required this.averageOrderValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'total_orders': totalOrders,
      'total_revenue': totalRevenue,
      'average_order_value': averageOrderValue,
    };
  }

  static SaleReport fromMap(Map<String, dynamic> map) {
    return SaleReport(
      date: DateTime.parse(map['date']),
      totalOrders: map['total_orders'],
      totalRevenue: map['total_revenue'].toDouble(),
      averageOrderValue: map['average_order_value'].toDouble(),
    );
  }
}
