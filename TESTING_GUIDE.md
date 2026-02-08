# Panduan Testing Aplikasi HOTPOT POS

## 📱 Akun yang Tersedia

### 1. Owner/Admin

- **Username:** `owner`
- **Password:** `owner123`
- **Akses:** Kelola menu, lihat laporan penjualan, kelola user

### 2. Kasir/Cashier

- **Username:** `cashier`
- **Password:** `cashier123`
- **Akses:** Proses pesanan pelanggan, menerima pembayaran

### 3. Konsumen (Customer)

Tersedia 3 akun konsumen untuk testing:

#### Konsumen 1

- **Username:** `customer1`
- **Password:** `customer123`

#### Konsumen 2

- **Username:** `customer2`
- **Password:** `customer123`

#### Konsumen 3

- **Username:** `customer3`
- **Password:** `customer123`

---

## 🔄 Alur Testing (Skenario Lengkap)

### Langkah 1: Login sebagai Konsumen
1. Buka aplikasi di browser atau emulator
2. Masukkan username: `customer1`
3. Masukkan password: `customer123`
4. Klik tombol **"Masuk"**

### Langkah 2: Pesan Makanan (Konsumen)
1. Setelah login, klik tombol **"Pesan Menu"**
2. Pilih kategori makanan (misalnya: Kuah, Daging Sapi, etc)
3. Klik menu item untuk menambahkan ke keranjang
4. Masukkan jumlah dan klik **"Tambahkan"**
5. Ulangi untuk menu lain jika ingin
6. Klik tombol **"Keranjang"** untuk melihat pesanan

### Langkah 3: Checkout (Konsumen)
1. Di halaman keranjang, review pesanan
2. Klik tombol **"Pesan Sekarang"** atau **"Checkout"**
3. Pesanan akan dikirim ke sistem

### Langkah 4: Login sebagai Kasir
1. Logout dari akun konsumen
2. Login dengan username: `cashier`
3. Password: `cashier123`

### Langkah 5: Proses Pesanan (Kasir)
1. Masuk ke menu **"Pesanan"** atau **"Orders"**
2. Lihat daftar pesanan di tab **"Pending"**
3. Klik pesanan dari konsumen yang baru masuk
4. Klik tombol **"Mulai Proses"** atau **"Process"**
5. Pesanan akan pindah ke tab **"Processing"**
6. Setelah siap, klik **"Selesaikan"** atau **"Complete"**
7. Pesanan akan pindah ke tab **"Completed"**

### Langkah 6: Login sebagai Owner (Optional)
1. Logout dari kasir
2. Login dengan username: `owner`
3. Password: `owner123`
4. Lihat:
   - 📊 Dashboard dengan statistik penjualan
   - 🍽️ Menu management (tambah/edit/hapus menu)
   - 👥 Laporan pesanan

---

## 🍜 Menu Yang Tersedia

### Kategori Kuah (5 item)
- Kuah Original (35,000)
- Kuah Pedas (35,000)
- Kuah Tom Yum (40,000)
- Kuah Ayam Putih (38,000)
- Kuah Tulang Sapi (45,000)

### Kategori Daging Sapi (5 item)
- Wagyu Premium (185,000)
- Beef Sliced US (125,000)
- Sirloin Potongan (95,000)
- Beef Brisket (85,000)
- Meatball Beef (65,000)

### Kategori Ayam (4 item)
- Dada Ayam Slice (65,000)
- Paha Ayam Premium (55,000)
- Chicken Meatball (48,000)
- Ayam Goreng Potong (45,000)

### Kategori Hasil Laut (5 item)
- Udang Tiger Premium (145,000)
- Cumi-Cumi Fresh (95,000)
- Ikan Salmon (125,000)
- Kerang Hijau (65,000)
- Seafood Mix (135,000)

### Kategori Sayuran (5 item)
- Sayuran Hijau Segar (28,000)
- Jamur Campuran (35,000)
- Brokoli & Kembang Kol (32,000)
- Jagung Manis & Wortel (25,000)
- Tomat & Bawang Prei (20,000)

### Kategori Tahu (5 item)
- Tahu Putih Premium (22,000)
- Tahu Goreng (25,000)
- Telur Puyuh (18,000)
- Bakso Ikan (38,000)
- Surimi Stick (32,000)

### Kategori Mie (5 item)
- Mie Kuning (18,000)
- Mie Putih (18,000)
- Ramen Telur (28,000)
- Glass Noodle (22,000)
- Kentang Goreng (20,000)

### Kategori Nasi (4 item)
- Nasi Putih (12,000)
- Nasi Goreng Telur (28,000)
- Nasi Goreng Ayam (32,000)
- Nasi Goreng Seafood (38,000)

### Kategori Minuman (5 item)
- Es Teh Manis (8,000)
- Es Jeruk Nipis (10,000)
- Es Lemon Tea (12,000)
- Kopi Iced (15,000)
- Air Mineral (5,000)

### Kategori Dessert (4 item)
- Pudding Coklat (18,000)
- Es Krim Vanilla (15,000)
- Soto Ayam Dessert (12,000)
- Panna Cotta (22,000)

---

## 📱 Platform Support

### Web (Chrome, Firefox, Safari)
✅ Semua fitur tersedia
- Login/Logout
- Pesan makanan (konsumen)
- Lihat pesanan (kasir)
- Kelola menu (owner)
- In-memory data storage (data hilang saat refresh)

### Mobile (Android)
✅ Semua fitur tersedia
- Login/Logout
- Pesan makanan (konsumen)
- Lihat pesanan (kasir)
- Kelola menu (owner)
- SQLite database (data persistent)

### Desktop (Windows, Linux, macOS)
✅ Semua fitur tersedia (sama dengan mobile)

---

## 🐛 Testing Checklist

### Login Testing
- [ ] Login owner berhasil
- [ ] Login kasir berhasil
- [ ] Login customer berhasil
- [ ] Error message muncul untuk password salah
- [ ] Logout berhasil

### Customer Flow
- [ ] Customer bisa melihat menu
- [ ] Customer bisa memilih kategori
- [ ] Customer bisa tambah item ke keranjang
- [ ] Quantity dapat diubah
- [ ] Item bisa dihapus dari keranjang
- [ ] Checkout berhasil dan pesanan terlihat di kasir

### Cashier Flow
- [ ] Kasir melihat pesanan pending
- [ ] Kasir bisa update status ke "Processing"
- [ ] Kasir bisa update status ke "Completed"
- [ ] Pesanan berpindah tab sesuai status

### Owner Menu Management
- [ ] Owner bisa lihat semua menu
- [ ] Owner bisa tambah menu baru
- [ ] Owner bisa edit menu
- [ ] Owner bisa hapus menu
- [ ] Menu baru langsung terlihat di customer

### Owner Dashboard
- [ ] Dashboard menampilkan statistik
- [ ] Total pesanan hari ini
- [ ] Total revenue hari ini
- [ ] Grafik atau summary ada

---

## 🌐 Testing di Web

### Run di Web
```bash
flutter run -d chrome
```

### Expected Behavior
1. Aplikasi membuka di browser Chrome
2. Semua menu kategori terupdate dengan 47 items
3. Login dengan 3 akun berbeda berhasil
4. Pesan makanan disimpan di memory (hilang saat refresh)

---

## 📝 Test Cases Khusus

### Test Case 1: Multi-Customer Ordering
```
1. Login customer1, pesan makanan
2. Logout
3. Login customer2, pesan makanan berbeda
4. Login kasir, lihat 2 pesanan berbeda
Result: Kedua pesanan masuk dengan benar
```

### Test Case 2: Order Status Flow
```
1. Customer1 pesan: Kuah Original, Wagyu Premium
2. Kasir menerima pesanan (Pending)
3. Kasir klik "Process" → status berubah ke Processing
4. Kasir klik "Complete" → status berubah ke Completed
5. Customer1 bisa lihat riwayat pesanan
Result: Status flow berjalan dengan benar
```

### Test Case 3: Menu Management
```
1. Owner login
2. Tambah menu baru: "Menu Custom" - 50000
3. Customer login
4. Menu custom terlihat di list
5. Customer order menu custom
6. Kasir proses order dengan menu custom
Result: Menu custom berhasil terintegrasi
```

---

## 🔧 Troubleshooting

### Issue: Pesanan tidak muncul di kasir
**Solusi:**
- Refresh halaman kasir
- Pastikan customer sudah logout setelah pesan
- Cek DevTools console (F12) untuk error

### Issue: Menu tidak terupdate
**Solusi:**
- Refresh halaman customer
- Cek apakah menu sudah tersimpan (cek console)
- Di web, refresh page akan reset menu custom

### Issue: Login gagal
**Solusi:**
- Pastikan username/password benar
- Cek DevTools console untuk error detail
- Coba dengan akun lain

### Issue: Platform error pada web
**Solusi:**
- Sudah di-fix dengan menggunakan kIsWeb
- Jika masih error, cek console browser
- Restart aplikasi dengan `flutter run -d chrome`

---

## ℹ️ Informasi Teknis

### Roles & Permissions

| Fitur | Customer | Cashier | Owner |
|-------|----------|---------|-------|
| Lihat Menu | ✅ | ❌ | ✅ |
| Pesan Menu | ✅ | ❌ | ❌ |
| Lihat Pesanan Sendiri | ✅ | ❌ | ❌ |
| Proses Pesanan | ❌ | ✅ | ❌ |
| Kelola Menu | ❌ | ❌ | ✅ |
| Lihat Laporan | ❌ | ❌ | ✅ |

### Database Schema (Mobile/Desktop)
- **users:** owner, cashier, customer1-3
- **menu_items:** 47 items dengan 10 kategori
- **orders:** Pesanan dari customers
- **order_items:** Item detail dalam pesanan

### Web Storage (Browser)
- Mock menu items disimpan di static list
- Custom menu disimpan di in-memory list (hilang saat refresh)
- Orders disimpan di memory (tidak persistent)

---

## 🎯 Expected Results Setelah Test

✅ Login berhasil untuk semua 5 akun
✅ Customer bisa melihat 47 menu items
✅ Customer bisa order dan checkout
✅ Kasir bisa menerima dan memproses pesanan
✅ Owner bisa mengelola menu dan melihat dashboard
✅ Tidak ada error pada console
✅ UI responsif dan user-friendly

**Aplikasi siap untuk presentation!** 🚀
