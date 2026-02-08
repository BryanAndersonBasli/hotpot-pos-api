# 🔧 DOKUMENTASI TEKNIS - HOTPOT POS

Dokumentasi lengkap untuk developer yang ingin memahami arsitektur dan implementasi aplikasi HOTPOT POS.

## 📐 Arsitektur Aplikasi

```txt
Architecture Pattern: Service-Provider-View (SPV)
|
├── Services (Database & Business Logic)
│   ├── DatabaseService (SQLite)
│   └── PrintService (PDF Generation)
│
├── Providers (State Management)
│   ├── AuthProvider (User Authentication)
│   ├── MenuProvider (Menu Management)
│   ├── OrderProvider (Order Management)
│   ├── SalesProvider (Sales Reporting)
│   └── CartProvider (Shopping Cart)
│
└── Views (UI Screens)
    ├── Authentication Screens
    ├── Customer Screens
    ├── Cashier Screens
    └── Owner Screens
```

## 🏗️ Komponen Utama

### Models

#### `user.dart`

- Merepresentasikan user/akun dalam aplikasi
- Fields: id, username, password, role, name, created_at
- Enums: UserRole (customer, cashier, owner)

#### `menu_item.dart`

- Merepresentasikan item menu yang dijual
- Fields: id, name, description, price, category, image, is_available, created_at
- Enums: MenuCategory (soup, seafood, noodle, rice, drink)

#### `order.dart`

- Merepresentasikan pesanan dari customer
- Fields: id, customer_id, customer_name, status, payment_status, total_amount, created_at
- OrderItem: id, order_id, menu_item_id, menu_item_name, price, quantity, subtotal
- Enums: OrderStatus (pending, processing, completed, cancelled), PaymentStatus (unpaid, paid, failed)

#### `sale.dart`

- Merepresentasikan laporan penjualan
- Fields: date, totalRevenue, totalOrders, averagePerOrder

### Services

#### `database_service.dart`

Singleton service untuk mengelola SQLite database dengan fitur:

- **Initialization**: Auto-create tables dan seed default data
- **Users**: CRUD operations untuk user accounts
- **Menu**: CRUD operations untuk menu items dengan category filtering
- **Orders**: Create order, query by status/customer, update status dan payment
- **Sales Reports**: Query daily sales, range-based reporting

Database Schema:

```sql
-- Users Table
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  role TEXT NOT NULL,
  name TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
)

-- Menu Items Table
CREATE TABLE menu_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  price REAL NOT NULL,
  category TEXT NOT NULL,
  image TEXT,
  is_available INTEGER DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
)

-- Orders Table
CREATE TABLE orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_id INTEGER NOT NULL,
  customer_name TEXT NOT NULL,
  status TEXT NOT NULL,
  payment_status TEXT NOT NULL,
  total_amount REAL NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  completed_at DATETIME
)

-- Order Items Table
CREATE TABLE order_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id INTEGER NOT NULL,
  menu_item_id INTEGER NOT NULL,
  menu_item_name TEXT NOT NULL,
  price REAL NOT NULL,
  quantity INTEGER NOT NULL,
  subtotal REAL NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id)
)
```

#### `print_service.dart`

Service untuk generate dan print receipt:

- Generate PDF receipt dengan format thermal printer (80mm)
- Include: order details, items, total, payment status
- Support untuk berbagai jenis printer

### Providers

#### `auth_provider.dart`

State management untuk authentication:

- Methods: login(), register(), logout()
- Properties: currentUser, isLoggedIn

#### `menu_provider.dart`

State management untuk menu:

- Methods: loadMenus(), addMenu(), updateMenu(), deleteMenu()
- Grouping by category untuk UI

#### `order_provider.dart`

State management untuk orders:

- Methods: createOrder(), getOrders(), updateOrderStatus(), updatePaymentStatus()
- Filtering by status, customer

#### `sales_provider.dart`

State management untuk sales reports:

- Methods: loadSalesData(), generateReport()
- Date range filtering support

#### `cart_provider.dart`

State management untuk shopping cart:

- Methods: addItem(), removeItem(), updateQuantity(), checkout()
- Total calculation

## 🛠️ Setup Development

### Persyaratan

- Flutter SDK >= 3.7.2
- Dart SDK >= 3.0
- Android SDK atau iOS SDK
- SQLite3 (built-in di sqflite)

### Dependencies

```yaml
flutter:
  sdk: flutter

provider: ^6.1.0
sqflite: ^2.3.0
path: ^1.8.3
intl: ^0.19.0
pdf: ^3.10.0
printing: ^5.11.0
flutter_speed_dial: ^7.0.0
```

### Instalasi Development

```bash
# Clone repository
git clone <repo_url>

# Install dependencies
flutter pub get

# Run aplikasi
flutter run
```

## 📱 Platform Support

- **Android**: Fully supported
- **iOS**: Fully supported
- **Web**: Mostly supported (beberapa fitur print terbatas)
- **Desktop**: Testing required

## 🔐 Security Considerations

### Current Implementation

- ⚠️ Password stored in plain text (for demo only)
- ⚠️ No encryption for sensitive data
- ⚠️ No token-based authentication

### Recommendations for Production

1. **Password Security**
   - Gunakan bcrypt atau argon2
   - Never store plain text passwords

2. **Session Management**
   - Implement JWT tokens
   - Add token expiration
   - Refresh token mechanism

3. **Data Protection**
   - Use encryption for sensitive fields
   - Implement secure storage (flutter_secure_storage)
   - HTTPS only for API calls

4. **API Security**
   - Input validation & sanitization
   - Rate limiting
   - CORS configuration

## 🗄️ Database Operations

### User Management

```dart
// Login
final user = await db.getUserByUsername(username, password);

// Register
await db.createUser(username, password, role, name);

// Get all users
final users = await db.getAllUsers();
```

### Menu Management

```dart
// Get menu by category
final items = await db.getMenuByCategory(MenuCategory.soup);

// Add menu
await db.createMenuItem(name, description, price, category);

// Update menu
await db.updateMenuItem(id, name, description, price);

// Delete menu
await db.deleteMenuItem(id);
```

### Order Management

```dart
// Create order
final orderId = await db.createOrder(customerId, items, totalAmount);

// Get orders by customer
final orders = await db.getOrdersByCustomer(customerId);

// Update order status
await db.updateOrderStatus(orderId, OrderStatus.processing);

// Update payment status
await db.updatePaymentStatus(orderId, PaymentStatus.paid);
```

### Sales Reporting

```dart
// Get daily sales
final dailySales = await db.getDailySales(date);

// Get sales by date range
final rangeSales = await db.getSalesByDateRange(startDate, endDate);

// Get total revenue
final revenue = await db.getTotalRevenue(startDate, endDate);
```

## 📊 Routing Structure

```dart
// Named Routes
Map<String, WidgetBuilder> routes = {
  '/login': (_) => LoginScreen(),
  '/register': (_) => RegisterScreen(),
  '/home': (_) => HomeScreen(),
  '/customer/menu': (_) => CustomerMenuScreen(),
  '/cart': (_) => CartScreen(),
  '/customer/orders': (_) => CustomerOrdersScreen(),
  '/cashier/orders': (_) => CashierOrdersScreen(),
  '/owner/menu': (_) => OwnerMenuManagementScreen(),
  '/owner/sales': (_) => OwnerSalesScreen(),
};

// Navigation
Navigator.pushNamed(context, '/home');
```

## 🎨 Theme Configuration

```dart
// Primary Color: Red (Hotpot brand)
ColorScheme.fromSeed(seedColor: Colors.red)

// Secondary Colors
- Blue: Cashier role
- Green: Owner role
- Teal: Accent

// Material 3 Design System
useMaterial3: true
```

## 🧪 Testing

### Unit Tests

```dart
// Test models
test('User model serialization', () {
  final user = User(id: 1, username: 'test', role: UserRole.customer);
  expect(user.username, 'test');
});
```

### Integration Tests

```dart
// Test database operations
testWidgets('Database operations', (tester) async {
  final db = DatabaseService();
  await db.initialize();
  
  // Test CRUD
  final userId = await db.createUser('test', 'pass', 'customer', 'Test User');
  expect(userId, isNotNull);
});
```

## 🚀 Deployment

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Sign APK
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
  -keystore key.keystore app-release-unsigned.apk alias_name

# Zipalign
zipalign -v 4 app-release-unsigned.apk app-release.apk
```

### iOS

```bash
# Build
flutter build ios --release

# Archive & Upload via Xcode
```

## 📈 Performance Optimization

1. **Database**
   - Use indexes untuk frequently queried columns
   - Implement pagination untuk large datasets
   - Cache queries result saat possible

2. **UI Rendering**
   - Use const constructors
   - Implement efficient list views (ListView.builder)
   - Avoid unnecessary rebuilds dengan Provider

3. **Memory Management**
   - Dispose providers properly
   - Use weak references untuk large objects
   - Clean up subscriptions

## 🐛 Debugging

### Enable Debug Logging

```dart
// Add to main.dart
debugPrint('Event: $message');
```

### Database Debugging

```dart
// Export database untuk inspection
sqlite3 command line tools
```

### Performance Monitoring

```dart
// Use Flutter DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

## 📚 Referensi

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [PDF Package](https://pub.dev/packages/pdf)

## 📞 Support

Untuk pertanyaan teknis, silakan referensi ke dokumentasi di atas atau hubungi tim development.

---

**Version**: 1.0.0  
**Last Updated**: January 26, 2026
