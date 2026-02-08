# HOTPOT POS - Aplikasi Kasir Restoran Hotpot

Aplikasi Point of Sale (POS) lengkap untuk restoran hotpot yang dibangun dengan Flutter. Aplikasi ini mendukung 3 role berbeda dengan akses dan fitur yang berbeda.

## 📋 Fitur Utama

### 1. **Customer (Pelanggan)**

- ✅ Browsing menu hotpot yang dikategorikan (Soup, Seafood, Noodle, Rice, Drink)
- ✅ Menambah item ke keranjang dengan kuantitas
- ✅ Checkout dan membuat pesanan
- ✅ Melihat riwayat pesanan
- ✅ Tracking status pesanan (Pending → Processing → Completed)

### 2. **Cashier (Kasir)**

- ✅ Melihat daftar pesanan yang masuk
- ✅ Filter pesanan berdasarkan status (Pending, Processing, Completed)
- ✅ Memproses pesanan
- ✅ Confirm pembayaran dari customer
- ✅ Print bon pesanan dengan printer thermal
- ✅ Print ulang bon sesuai kebutuhan

### 3. **Owner (Pemilik)**

- ✅ Mengelola menu (Tambah, Edit, Hapus)
- ✅ Melihat laporan penjualan
- ✅ Melihat data penjualan per hari
- ✅ Filter laporan penjualan berdasarkan rentang tanggal
- ✅ Lihat statistik (Total Pendapatan, Total Pesanan, Rata-rata per Pesanan)

## 🔐 Autentikasi & Akun Default

Aplikasi memiliki sistem login dengan 3 akun default:

| Role | Username | Password |
| --- | --- | --- |
| Owner | `owner` | `owner123` |
| Cashier | `cashier` | `cashier123` |
| Customer | Bisa membuat akun baru | - |

## 📁 Struktur Project

```dart
lib/
├── main.dart                          # Entry point aplikasi
├── models/
│   ├── user.dart                      # Model User dengan role
│   ├── menu_item.dart                 # Model MenuItem dengan kategori
│   ├── order.dart                     # Model Order dan OrderItem
│   └── sale.dart                      # Model SaleReport
├── providers/
│   ├── auth_provider.dart             # State management untuk auth
│   ├── menu_provider.dart             # State management menu
│   ├── order_provider.dart            # State management order
│   ├── sales_provider.dart            # State management sales
│   └── cart_provider.dart             # State management shopping cart
├── services/
│   ├── database_service.dart          # SQLite database service
│   └── print_service.dart             # Print/PDF service
└── screens/
    ├── login_screen.dart              # Login page
    ├── register_screen.dart           # Registrasi customer
    ├── home_screen.dart               # Home screen sesuai role
    ├── customer_menu_screen.dart      # Browse menu
    ├── cart_screen.dart               # Shopping cart
    ├── customer_orders_screen.dart    # History pesanan customer
    ├── cashier_orders_screen.dart     # Order management kasir
    ├── owner_menu_management_screen.dart  # Kelola menu
    └── owner_sales_screen.dart        # Laporan penjualan
```

## 🏗️ Teknologi yang Digunakan

- **Flutter** - Framework UI
- **Provider** - State management
- **SQLite** (`sqflite`) - Database lokal
- **PDF & Printing** - Generate dan print bon
- **Intl** - Date formatting

## 📦 Dependencies

```yaml
provider: ^6.1.0          # State management
sqflite: ^2.3.0           # SQLite database
path: ^1.8.3              # Path utilities
intl: ^0.19.0             # Internationalization
pdf: ^3.10.0              # PDF generation
printing: ^5.11.0         # Print support
flutter_speed_dial: ^7.0.0 # Floating action menu (optional)
```

## 🚀 Setup & Instalasi

### Prerequisites

- Flutter SDK (3.7.2 atau lebih)
- Dart SDK
- Android Studio atau Visual Studio Code dengan Flutter extension

### Langkah Instalasi

1. **Clone/Extract Project**

```bash
cd hotpot
```

1. **Install Dependencies**

```bash
flutter pub get
```

1. **Run Aplikasi**

```bash
flutter run
```

Atau untuk device spesifik:

```bash
flutter run -d <device_id>
```

## 💾 Database

Aplikasi menggunakan SQLite untuk menyimpan data. Database berisi tabel-tabel berikut:

### Tabel `users`

- Menyimpan akun user dengan role
- Default: 2 user (owner dan cashier)

### Tabel `menu_items`

- Menyimpan daftar menu dengan kategori
- Default: 10 menu sample

### Tabel `orders`

- Menyimpan data pesanan dengan status dan payment status

### Tabel `order_items`

- Menyimpan detail item dalam setiap pesanan

## 🔄 Workflow Pesanan

```txt
Customer membuat pesanan
        ↓
Kasir melihat pesanan (status: Pending)
        ↓
Kasir menerima pembayaran
        ↓
Pesanan berubah status: Processing
        ↓
Kasir menyelesaikan pesanan
        ↓
Pesanan status: Completed
        ↓
Kasir print bon
```

## 🖨️ Print Bon

Fitur print dapat digunakan untuk:

- Print bon saat pesanan selesai
- Print ulang bon kapan saja
- Kompatibel dengan printer thermal 80mm
- Format receipt standar

## 📊 Laporan Penjualan

Owner dapat melihat:

- Total pendapatan periode tertentu
- Total jumlah pesanan
- Rata-rata nilai per pesanan
- Breakdown penjualan per hari
- Filter berdasarkan tanggal

## 🎨 Tema & Desain

- **Warna Utama**: Merah (brand color hotpot)
- **Warna Sekunder**: Biru (untuk kasir), Hijau (untuk owner)
- **Material Design 3** - UI modern dan clean

## 🐛 Troubleshooting

### Aplikasi tidak jalan

```bash
flutter clean
flutter pub get
flutter run
```

### Database error

- Hapus data aplikasi dari settings
- Atau jalankan ulang dengan fresh install

### Print tidak bekerja

- Pastikan printer terhubung
- Update driver printer
- Cek permissions di AndroidManifest.xml

## 🔐 Keamanan

**Catatan**: Password disimpan dalam plain text untuk demo. Untuk production:

- Gunakan password hashing (bcrypt, argon2)
- Implementasi JWT tokens
- Gunakan secure storage untuk session

## 📝 Catatan Pengembang

### Menambah Menu Baru

1. Login sebagai Owner
2. Ke "Kelola Menu"
3. Pilih kategori
4. Klik tombol + untuk tambah menu
5. Isi detail dan simpan

### Melihat Laporan Penjualan

1. Login sebagai Owner
2. Ke "Laporan Penjualan"
3. Gunakan icon tanggal untuk filter range
4. Lihat breakdown harian

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ⚠️ Web (tested, beberapa fitur print tidak tersedia)
- ⚠️ Desktop (tested, beberapa fitur print tidak tersedia)

## 🚀 Future Enhancement

- [ ] Multiple outlet/branch support
- [ ] Real-time notification untuk kasir
- [ ] Integration dengan payment gateway
- [ ] Inventory management
- [ ] Employee management & dashboard
- [ ] Analytics & business intelligence
- [ ] Mobile app untuk kitchen display

## 📄 License

Private - For Educational Purpose

## 👨‍💼 Support & Contact

Untuk pertanyaan dan support, silakan hubungi tim development.

---

**Version**: 1.0.0  
**Last Updated**: January 26, 2026
