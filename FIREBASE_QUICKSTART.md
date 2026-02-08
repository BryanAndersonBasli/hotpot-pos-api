# Quick Start - Firebase Integration

## Ringkasan Perubahan

Firebase telah berhasil diintegrasikan ke aplikasi Hotpot POS. Berikut adalah apa yang telah dilakukan:

## ✅ Tahap 1: Setup Dependencies
- Menambahkan Firebase packages ke `pubspec.yaml`:
  - `firebase_core: ^3.0.0`
  - `firebase_auth: ^5.0.0`
  - `cloud_firestore: ^5.0.0`
  - `firebase_storage: ^12.0.0`
- Menjalankan `flutter pub get` untuk install packages

## ✅ Tahap 2: Firebase Initialization
- Update `lib/main.dart` untuk initialize Firebase
- Firebase sekarang diinisialisasi saat app startup dengan konfigurasi otomatis dari `firebase_options.dart`

## ✅ Tahap 3: Membuat Firebase Service
- Membuat file `lib/services/firebase_service.dart` dengan lengkap berisi:
  - **Authentication methods**: registerUser, loginUser, logoutUser
  - **Menu methods**: addMenuItem, getMenuItems, updateMenuItem, deleteMenuItem
  - **Order methods**: createOrder, getOrders, updateOrder
  - **Sales methods**: recordSale, getSales
  - **Real-time streams** untuk menu dan orders

## ✅ Tahap 4: Update Providers
- **AuthProvider**: Sekarang menggunakan Firebase Auth + fallback ke database lokal
- **MenuProvider**: Memuat menu dari Firebase terlebih dahulu
- **OrderProvider**: Sinkronisasi orders dengan Firebase
- **SalesProvider**: Mengambil data penjualan dari Firebase

## 🚀 Cara Memulai Testing

### 1. Pastikan Flutter Pub Get Sudah Dilakukan
```bash
cd d:\skripsi\Aplikasi POS JN\Hotpot\hotpot
flutter pub get
```

### 2. Setup Firebase Console (jika belum)
Jika belum membuat Firebase project, ikuti langkah ini:

a. Buka https://console.firebase.google.com/
b. Klik "Create a new project"
c. Masukkan nama project: "Hotpot POS"
d. Terima syarat dan ketentuan, lalu klik "Create project"
e. Tunggu project selesai dibuat

### 3. Enable Firestore Database
- Di Firebase Console, pilih project Hotpot POS
- Klik "Firestore Database" di sidebar
- Klik "Create Database"
- Pilih lokasi terdekat (Asia Tenggara)
- Mulai dengan "Production mode" atau "Test mode"
- Klik "Create"

### 4. Enable Authentication
- Di Firebase Console, klik "Authentication"
- Klik "Get Started"
- Di tab "Sign-in method", klik "Email/Password"
- Aktifkan dan klik "Save"

### 5. Update Firebase Config (jika diperlukan)
Jika menggunakan Firebase project baru:
- Jalankan FlutterFire CLI:
  ```bash
  dart pub global activate flutterfire_cli
  flutterfire configure --project=hotpot-pos
  ```
- Pilih platform yang ingin dikonfigurasi (Android, iOS, Web, Windows, macOS, Linux)
- CLI akan automatically update `firebase_options.dart`

### 6. Jalankan Aplikasi

#### Untuk Web:
```bash
flutter run -d chrome
```

#### Untuk Android:
```bash
flutter run -d android
```

#### Untuk iOS:
```bash
flutter run -d ios
```

### 7. Test Firebase Integration

#### Test Login/Register:
1. Buka aplikasi
2. Klik "Register" jika ada opsi baru
3. Atau gunakan akun default:
   - Username: `owner` / Password: `owner123`
   - Username: `cashier` / Password: `cashier123`
   - Username: `customer1` / Password: `customer123`

#### Test Menu Loading:
1. Login sebagai owner
2. Buka menu management
3. Verifikasi menu termuat dari Firebase (atau mock data jika offline)

#### Test Order Creation:
1. Login sebagai customer
2. Pesan menu
3. Verifikasi order tersimpan ke Firebase

## 📊 Melihat Data di Firebase Console

### Firestore Data:
1. Buka Firebase Console → Firestore Database
2. Klik tab "Data"
3. Lihat collections:
   - `users` - data pengguna
   - `menu_items` - data menu
   - `orders` - data pesanan
   - `sales` - data penjualan

### Authentication:
1. Buka Firebase Console → Authentication
2. Klik tab "Users"
3. Lihat semua user yang terdaftar

## 🔧 Setup Firestore Security Rules (PENTING!)

Firestore dimulai dengan "Test Mode" yang memungkinkan siapa saja membaca/menulis. Untuk production:

1. Di Firebase Console → Firestore Database → Rules
2. Salin-paste security rules di bawah ini:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users: hanya bisa read/write data sendiri
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Menu Items: siapa saja bisa baca, hanya owner bisa edit
    match /menu_items/{document=**} {
      allow read: if true;
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'owner';
    }
    
    // Orders: user bisa akses order mereka sendiri
    match /orders/{orderId} {
      allow read: if request.auth.uid == resource.data.uid ||
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'owner';
      allow write: if request.auth != null;
    }
    
    // Sales: hanya owner bisa baca
    match /sales/{document=**} {
      allow read: if request.auth != null && 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'owner';
      allow write: if request.auth != null;
    }
  }
}
```

3. Klik "Publish"

## 📋 Checklist Implementasi

- [x] Firebase Core Initialization
- [x] Firebase Authentication Setup
- [x] Firestore Database Setup
- [x] Firebase Service Creation
- [x] Provider Integration
- [x] Dependencies Installation
- [ ] Firebase Console Project Configuration
- [ ] Firestore Security Rules Configuration
- [ ] Enable Authentication Methods
- [ ] Test Login/Register
- [ ] Test Menu Management
- [ ] Test Order Creation
- [ ] Test Sales Report
- [ ] Deploy ke Production

## 🐛 Common Issues & Solutions

### Error: "Unhandled Exception: firebase_core not initialized"
**Solusi**: Pastikan `Firebase.initializeApp()` dipanggil di main() sebelum `runApp()`

### Error: "Permission denied"
**Solusi**: 
- Cek Firestore Security Rules
- Pastikan user sudah authenticated
- Cek Firebase Console log untuk details

### Error: "User not found in Authentication"
**Solusi**: Register user baru melalui aplikasi atau Firebase Console

### Data tidak muncul di Firestore
**Solusi**:
- Pastikan app connected ke internet
- Cek Firebase Console Firestore tab
- Lihat Network tab di browser DevTools untuk debug

### App tidak connect ke Firebase di Web
**Solusi**:
- Buka browser console (F12)
- Cek error message
- Pastikan Firebase project sudah dikonfigurasi untuk web
- Jalankan `flutterfire configure` ulang untuk web

## 📞 Perlu Bantuan?

Jika mengalami masalah:
1. Cek `FIREBASE_INTEGRATION.md` untuk dokumentasi lengkap
2. Buka browser DevTools untuk melihat error
3. Cek Firebase Console Logs
4. Baca Flutter & Firebase documentation

---

**Status**: ✅ Firebase Integration Ready for Testing
**Last Updated**: January 27, 2026
