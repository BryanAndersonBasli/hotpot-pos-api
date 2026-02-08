# Dokumentasi Integrasi Firebase - Hotpot POS

## Overview
Aplikasi Hotpot POS telah diintegrasikan dengan Firebase untuk menyimpan data di cloud. Integrasi ini mencakup:
- **Firebase Authentication** - untuk autentikasi pengguna
- **Cloud Firestore** - untuk menyimpan data aplikasi (menu, pesanan, penjualan)
- **Firebase Storage** - untuk menyimpan gambar dan file

## Status Integrasi

### ✅ Sudah Diimplementasi

#### 1. **Firebase Core Initialization** (`lib/main.dart`)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

#### 2. **Firebase Service** (`lib/services/firebase_service.dart`)
Service lengkap dengan metode:
- Authentication: `registerUser()`, `loginUser()`, `logoutUser()`
- Menu Items: `addMenuItem()`, `getMenuItems()`, `updateMenuItem()`, `deleteMenuItem()`
- Orders: `createOrder()`, `getOrders()`, `updateOrder()`
- Sales: `recordSale()`, `getSales()`

#### 3. **Provider Integration**
Semua provider telah diupdate untuk menggunakan Firebase sebagai sumber data utama:

**AuthProvider** (`lib/providers/auth_provider.dart`)
- Menggunakan Firebase Auth untuk login dan registrasi
- Fallback ke database lokal dan mock data untuk web testing

**MenuProvider** (`lib/providers/menu_provider.dart`)
- Memuat menu dari Firebase terlebih dahulu
- Fallback ke database lokal untuk mobile

**OrderProvider** (`lib/providers/order_provider.dart`)
- Memuat pesanan dari Firebase
- Sinkronisasi dengan database lokal

**SalesProvider** (`lib/providers/sales_provider.dart`)
- Mengambil laporan penjualan dari Firebase

#### 4. **Dependencies Ditambahkan** (`pubspec.yaml`)
```yaml
firebase_core: ^3.0.0
firebase_auth: ^5.0.0
cloud_firestore: ^5.0.0
firebase_storage: ^12.0.0
```

## Konfigurasi Firebase

### File Konfigurasi yang Sudah Ada
- `lib/firebase_options.dart` - Konfigurasi Firebase untuk semua platform
- `firebase.json` - Konfigurasi Firebase Project
- `android/app/google-services.json` - Konfigurasi Firebase untuk Android

### Firestore Database Structure

```
users/
├── {uid}
│   ├── uid: string
│   ├── email: string
│   ├── username: string
│   ├── name: string
│   ├── role: string (owner, cashier, customer)
│   └── created_at: timestamp

menu_items/
├── {docId}
│   ├── name: string
│   ├── description: string
│   ├── price: number
│   ├── category: string
│   ├── image: string
│   ├── is_available: boolean
│   └── created_at: timestamp

orders/
├── {orderId}
│   ├── customer_id: number
│   ├── customer_name: string
│   ├── table_number: number
│   ├── status: string (pending, processing, completed)
│   ├── payment_status: string (unpaid, paid)
│   ├── total_amount: number
│   ├── created_at: timestamp
│   ├── completed_at: timestamp
│   └── items/ (subcollection)
│       └── {itemId}
│           ├── menu_item_id: number
│           ├── menu_item_name: string
│           ├── price: number
│           ├── quantity: number
│           ├── subtotal: number
│           └── is_ready: boolean

sales/
├── {saleId}
│   ├── order_id: number
│   ├── customer_name: string
│   ├── total_amount: number
│   ├── payment_method: string
│   └── created_at: timestamp
```

## Cara Menggunakan Firebase Service

### 1. Import Service
```dart
import 'package:hotpot/services/firebase_service.dart';
```

### 2. Membuat Instance
```dart
final firebaseService = FirebaseService();
```

### 3. Contoh Penggunaan

#### Register User
```dart
bool success = await firebaseService.registerUser(
  email: 'user@example.com',
  password: 'password123',
  username: 'username',
  name: 'Full Name',
  role: 'customer',
);
```

#### Login
```dart
User? user = await firebaseService.loginUser(
  'user@example.com',
  'password123',
);
```

#### Add Menu Item
```dart
bool success = await firebaseService.addMenuItem(
  MenuItem(
    id: 1,
    name: 'Menu Name',
    description: 'Description',
    price: 50000,
    category: MenuCategory.beef,
    isAvailable: true,
  ),
);
```

#### Create Order
```dart
String? orderId = await firebaseService.createOrder(
  Order(
    id: 0,
    customerId: 1,
    customerName: 'Customer Name',
    tableNumber: 1,
    status: OrderStatus.pending,
    paymentStatus: PaymentStatus.unpaid,
    totalAmount: 500000,
    items: [...orderItems],
    createdAt: DateTime.now(),
  ),
);
```

## Real-time Updates dengan Streams

Firebase Service menyediakan Stream untuk real-time updates:

```dart
// Real-time menu updates
firebaseService.getMenuItemsStream().listen((items) {
  // Update UI dengan menu items terbaru
});

// Real-time order updates
firebaseService.getOrdersStream().listen((orders) {
  // Update UI dengan orders terbaru
});
```

## Fallback Strategy

Aplikasi memiliki strategi fallback yang robust:

1. **Production Mode (Mobile/Desktop)**
   - Coba Firebase terlebih dahulu
   - Jika gagal, gunakan database lokal (SQLite)
   - Jika database kosong, gunakan mock data

2. **Web Mode**
   - Gunakan Firebase untuk data real-time
   - Fallback ke mock data untuk testing

3. **Offline Support**
   - Data lokal di-cache untuk akses offline
   - Sinkronisasi otomatis ketika online

## Langkah-Langkah Setup Selanjutnya

### 1. Setup Security Rules di Firebase Console
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{document=**} {
      allow read, write: if request.auth != null;
    }
    match /menu_items/{document=**} {
      allow read: if true;
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'owner';
    }
    match /orders/{document=**} {
      allow read, write: if request.auth != null;
    }
    match /sales/{document=**} {
      allow read: if request.auth != null && 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'owner';
      allow write: if request.auth != null;
    }
  }
}
```

### 2. Enable Authentication Methods
- Email/Password
- (Optional) Google Sign-In
- (Optional) Phone Authentication

### 3. Create Firestore Indexes (jika diperlukan)
- Index untuk `orders` berdasarkan `created_at`
- Index untuk `sales` berdasarkan `created_at` dan `customer_name`

### 4. Setup Storage Rules (opsional untuk upload gambar)
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /menu_images/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && 
                      request.auth.token.email_verified == true;
    }
  }
}
```

## Testing Firebase Locally

### 1. Menggunakan Firebase Emulator
```bash
firebase emulators:start
```

### 2. Connect Flutter App ke Emulator
```dart
// Di development mode
if (kDebugMode) {
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
}
```

## Troubleshooting

### Error: "firebase_core not initialized"
**Solusi**: Pastikan `Firebase.initializeApp()` dipanggil di `main()` sebelum `runApp()`

### Error: "Permission denied" di Firestore
**Solusi**: Periksa Security Rules di Firebase Console dan pastikan user sudah authenticated

### Error: "User not found" di Cloud Firestore
**Solusi**: Pastikan user data sudah disimpan ke Firestore saat registrasi

### Firebase tidak tersambung di Web
**Solusi**: Buka browser DevTools > Console untuk melihat error detail

## Monitoring & Analytics

### 1. Firebase Console
- Pantau penggunaan real-time di Firebase Console
- Lihat Firestore usage, Authentication logs, dan performance

### 2. Enable Google Analytics (Optional)
```dart
// Di main.dart
await FirebaseAnalytics.instance.logAppOpen();
```

## Best Practices

1. **Error Handling**
   - Selalu gunakan try-catch di Firebase operations
   - Implementasikan user-friendly error messages

2. **Data Validation**
   - Validate data sebelum dikirim ke Firebase
   - Gunakan Firestore Rules untuk server-side validation

3. **Batching**
   - Gunakan batch writes untuk multiple documents
   - Implementasikan pagination untuk large datasets

4. **Caching**
   - Cache data yang sering diakses
   - Implementasikan cache invalidation strategy

5. **Security**
   - Jangan hardcode API keys
   - Gunakan environment variables untuk sensitive data
   - Implement proper authentication dan authorization

## Referensi Dokumentasi
- Firebase Official Docs: https://firebase.google.com/docs
- FlutterFire: https://firebase.flutter.dev/
- Cloud Firestore: https://firebase.google.com/docs/firestore
- Firebase Authentication: https://firebase.google.com/docs/auth

## Kontak & Support
Untuk masalah lebih lanjut, hubungi:
- Firebase Support: support@firebase.google.com
- Flutter Community: https://fluttercommunity.dev/

---
**Last Updated**: January 27, 2026
**Status**: ✅ Firebase Integration Complete
