enum OrderStatus { pending, processing, completed, cancelled }

enum PaymentStatus { unpaid, paid, failed }

class OrderItem {
  final int? id;
  final String? docId; // Firebase document ID
  final int orderId;
  final int menuItemId;
  final String menuItemName;
  final double price;
  final int quantity;
  final double subtotal;
  final bool isReady;

  OrderItem({
    this.id,
    this.docId,
    required this.orderId,
    required this.menuItemId,
    required this.menuItemName,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.isReady = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doc_id': docId,
      'order_id': orderId,
      'menu_item_id': menuItemId,
      'menu_item_name': menuItemName,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
      'is_ready': isReady ? 1 : 0,
    };
  }

  static OrderItem fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'],
      docId: map['doc_id'],
      orderId: map['order_id'],
      menuItemId: map['menu_item_id'],
      menuItemName: map['menu_item_name'],
      price: map['price'].toDouble(),
      quantity: map['quantity'],
      subtotal: map['subtotal'].toDouble(),
      isReady: (map['is_ready'] ?? 0) == 1,
    );
  }

  OrderItem copyWith({
    int? id,
    String? docId,
    int? orderId,
    int? menuItemId,
    String? menuItemName,
    double? price,
    int? quantity,
    double? subtotal,
    bool? isReady,
  }) {
    return OrderItem(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      orderId: orderId ?? this.orderId,
      menuItemId: menuItemId ?? this.menuItemId,
      menuItemName: menuItemName ?? this.menuItemName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      subtotal: subtotal ?? this.subtotal,
      isReady: isReady ?? this.isReady,
    );
  }
}

class Order {
  final String? id; // Changed from int to String to store Firebase document ID
  final int customerId;
  final String customerName;
  final int tableNumber;
  final List<OrderItem> items;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime? completedAt;

  Order({
    this.id,
    required this.customerId,
    required this.customerName,
    required this.tableNumber,
    required this.items,
    this.status = OrderStatus.pending,
    this.paymentStatus = PaymentStatus.unpaid,
    required this.totalAmount,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_name': customerName,
      'table_number': tableNumber,
      'status': status.toString().split('.').last,
      'payment_status': paymentStatus.toString().split('.').last,
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  static Order fromMap(
    Map<String, dynamic> map, {
    List<OrderItem> items = const [],
  }) {
    return Order(
      id: map['id'],
      customerId: map['customer_id'],
      customerName: map['customer_name'],
      tableNumber: map['table_number'] ?? 0,
      items: items,
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['payment_status'],
      ),
      totalAmount: map['total_amount'].toDouble(),
      createdAt: DateTime.parse(map['created_at']),
      completedAt:
          map['completed_at'] != null
              ? DateTime.parse(map['completed_at'])
              : null,
    );
  }

  Order copyWith({
    String? id,
    int? customerId,
    String? customerName,
    int? tableNumber,
    List<OrderItem>? items,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      tableNumber: tableNumber ?? this.tableNumber,
      items: items ?? this.items,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
