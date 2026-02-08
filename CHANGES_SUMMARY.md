# UI/UX Improvements - Table Number System

## Changes Made

### 1. Order Model Update (`lib/models/order.dart`)
- **Added**: `final int tableNumber;` field to `Order` class
- **Updated Constructor**: Added `required this.tableNumber` parameter
- **Updated `toMap()`**: Added `'table_number': tableNumber` mapping
- **Updated `fromMap()`**: Added `tableNumber: map['table_number'] ?? 0`
- **Updated `copyWith()`**: Added `int? tableNumber` parameter

### 2. Checkout Flow (`lib/screens/cart_screen.dart`)
- **Changed**: Dialog now asks for **Nomor Meja** (table number) instead of **Nama Anda** (customer name)
- **Input Type**: Changed to numeric input (`keyboardType: TextInputType.number`)
- **Validation**: Table number must be between 1-99
- **Customer Name**: Auto-generated as `'Guest Meja [number]'` for guests, or uses logged-in user name
- **Order Creation**: Now passes `tableNumber` to Order constructor

### 3. Cashier Order Display (`lib/screens/cashier_orders_screen.dart`)
- **Replaced**: Customer name display with **Meja #[number]** format
  - Old: `'Customer: ${order.customerName}'`
  - New: `'Meja #${order.tableNumber}'`
- **Reduced Item Display Size**:
  - Changed font size from default to **12pt**
  - Reduced vertical padding from `4` to `2`
  - Item text now displayed more compactly
  - Total height reduced while maintaining readability
- **Spacing**: Reduced `SizedBox` from 12 to 8 between header and items

## User Flow

### For Guest Customers:
1. Browse menu
2. Add items to cart
3. Click **Checkout**
4. Enter table number (1-99)
5. Order created with table number

### For Logged-in Customers:
1. Browse menu
2. Add items to cart
3. Click **Checkout**
4. Enter table number (1-99) - same as guest flow
5. Order created with customer name + table number

### For Cashier:
1. View **Pesanan** (Orders) tab
2. See orders displayed by table number: `Meja #1`, `Meja #2`, etc.
3. Item list shown in compact format with smaller font
4. Process orders normally

## Benefits

✅ **Clearer Order Tracking**: Orders tracked by table number instead of customer name
✅ **Compact Display**: Menu items in order view take up less screen space
✅ **Better UX**: Simpler checkout flow asking for specific table number
✅ **Mobile Friendly**: Compact item display works better on smaller screens
✅ **Consistent**: All orders now use table-based tracking system

## Files Modified

1. `lib/models/order.dart` - Data model
2. `lib/screens/cart_screen.dart` - Checkout flow
3. `lib/screens/cashier_orders_screen.dart` - Order display

## Compilation Status

✅ All Dart files compile without errors
✅ No breaking changes to existing functionality
✅ Backward compatible with existing database (uses defaults for legacy data)
