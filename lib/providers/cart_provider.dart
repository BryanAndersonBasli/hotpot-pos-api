import 'package:flutter/foundation.dart';
import 'package:hotpot/models/menu_item.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _cartItems = {};

  Map<String, CartItem> get cartItems => _cartItems;

  List<CartItem> get items => _cartItems.values.toList();

  int get itemCount => _cartItems.length;

  double get totalPrice {
    return _cartItems.values.fold(0, (sum, item) => sum + item.subtotal);
  }

  void addItem(MenuItem menuItem, int quantity) {
    final key = menuItem.docId ?? 'item_${menuItem.id}';
    if (_cartItems.containsKey(key)) {
      _cartItems[key]!.quantity += quantity;
    } else {
      _cartItems[key] = CartItem(
        menuItemId: menuItem.id,
        docId: menuItem.docId,
        name: menuItem.name,
        price: menuItem.price,
        quantity: quantity,
      );
    }
    notifyListeners();
  }

  void updateQuantity(String cartKey, int quantity) {
    if (quantity <= 0) {
      removeItem(cartKey);
    } else if (_cartItems.containsKey(cartKey)) {
      _cartItems[cartKey]!.quantity = quantity;
      notifyListeners();
    }
  }

  void removeItem(String cartKey) {
    _cartItems.remove(cartKey);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  int getItemQuantity(String cartKey) {
    return _cartItems[cartKey]?.quantity ?? 0;
  }
}

class CartItem {
  final int? menuItemId;
  final String? docId;
  final String name;
  final double price;
  int quantity;

  CartItem({
    this.menuItemId,
    this.docId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  double get subtotal => price * quantity;
}
