# 📋 PANDUAN LENGKAP APLIKASI HOTPOT POS

## 🎯 Ringkasan Aplikasi

Aplikasi HOTPOT POS adalah sistem manajemen kasir yang lengkap untuk restoran hotpot dengan 3 role pengguna:

- **Customer**: Memesan makanan
- **Cashier/Kasir**: Memproses pesanan dan pembayaran
- **Owner**: Mengelola menu dan melihat laporan penjualan

## 🔐 Login & Akun

### Akun Default

#### Owner

- Username: `owner`
- Password: `owner123`

#### Cashier

- Username: `cashier`
- Password: `cashier123`

#### Customer

- Bisa membuat akun baru di halaman registrasi
- Contoh: username `john`, password `123456`

## 👥 Fitur per Role

---

## 🛒 CUSTOMER (Pelanggan)

### 1. Membuat Pesanan

**Langkah-langkah:**

1. Login dengan akun customer
2. Klik tombol **"Pesan Menu"**
3. Pilih kategori menu:
   - 🍲 Soup (Sup)
   - 🦐 Seafood (Hasil Laut)
   - 🍜 Noodle (Mie)
   - 🍚 Rice (Nasi)
   - 🥤 Drink (Minuman)
4. Klik item yang ingin dipesan
5. Dialog akan muncul, atur jumlah dengan tombol **+** dan **-**
6. Klik **"Tambahkan"** untuk menambah ke keranjang

### 2. Mengelola Keranjang

**Halaman Keranjang:**

- Lihat semua item yang sudah ditambahkan
- Ubah jumlah item dengan tombol **+** dan **-**
- Hapus item dengan swipe atau ikon delete
- Lihat total harga di bawah

**Checkout:**

1. Pastikan item di keranjang sudah sesuai
2. Klik tombol **"Pesan"** (merah)
3. Pesanan akan dikirim ke kasir
4. Tunggu konfirmasi dari kasir

### 3. Melihat Pesanan

**Halaman Pesanan Saya:**

1. Login sebagai customer
2. Klik tombol **"Pesanan Saya"**
3. Lihat daftar semua pesanan yang pernah dibuat
4. Setiap pesanan menampilkan:
   - Nomor pesanan
   - Tanggal/waktu pemesanan
   - Total harga
   - Status pesanan (Pending → Processing → Completed)
5. Tap pada pesanan untuk melihat detail item

---

## 💳 CASHIER (Kasir)

### 1. Melihat Pesanan Masuk

**Halaman Pesanan:**

1. Login sebagai cashier
2. Akan melihat tab dengan status:
   - **Pending**: Pesanan baru dari customer
   - **Processing**: Pesanan sedang diproses
   - **Completed**: Pesanan sudah selesai

### 2. Memproses Pesanan

**Langkah-langkah:**

1. Di tab **"Pending"**, lihat pesanan baru
2. Setiap pesanan menampilkan:
   - Nama customer
   - Daftar item yang dipesan
   - Total harga
3. Tap pesanan untuk melihat detail lengkap
4. Klik tombol **"Proses Pesanan"** untuk ubah status ke Processing
5. Pesanan akan pindah ke tab Processing

### 3. Menerima Pembayaran

**Langkah-langkah:**

1. Di tab **"Processing"**, lihat pesanan yang siap
2. Minta pembayaran dari customer
3. Setelah uang diterima, klik tombol **"Bayar"**
4. Status payment berubah menjadi PAID
5. Pesanan siap untuk diserahkan ke customer

### 4. Menyelesaikan Pesanan

**Langkah-langkah:**

1. Pesanan sudah dibayar
2. Klik tombol **"Selesaikan"** untuk ubah status ke Completed
3. Pesanan akan pindah ke tab Completed

### 5. Print Bon

**Langkah-langkah:**

1. Pesanan di tab Processing atau Completed
2. Klik tombol **"Print Bon"**
3. Dialog print akan muncul
4. Pilih printer (thermal printer untuk POS)
5. Bon akan tercetak otomatis

**Format Bon:**

```txt
========================
    HOTPOT RESTAURANT
========================
Tanggal: 26 Jan 2026 14:30
Order #: 001
Customer: John Doe
------------------------
Item         Qty  Harga
Widget       2    Rp.50.000
Demo         1    Rp.25.000
------------------------
Total:             Rp.125.000
Status: PAID
========================
Terima Kasih!
========================
```

---

## 🏪 OWNER (Pemilik)

### 1. Mengelola Menu

**Halaman Menu Management:**

1. Login sebagai owner
2. Klik tombol **"Kelola Menu"**
3. Lihat daftar menu berdasarkan kategori

**Menambah Menu Baru:**

1. Pilih kategori di bagian atas
2. Klik tombol **"+"** di kanan bawah (FAB)
3. Dialog form akan muncul dengan field:
   - Nama menu
   - Deskripsi
   - Harga
   - Kategori
4. Isi semua field
5. Klik **"Tambah"** untuk simpan

**Edit Menu:**

1. Long-press atau swipe pada item menu
2. Pilih **"Edit"**
3. Ubah data sesuai kebutuhan
4. Klik **"Simpan"**

**Hapus Menu:**

1. Long-press atau swipe pada item menu
2. Pilih **"Hapus"**
3. Konfirmasi penghapusan
4. Item akan dihapus dari database

### 2. Melihat Laporan Penjualan

**Halaman Laporan Penjualan:**

1. Login sebagai owner
2. Klik tombol **"Laporan Penjualan"**
3. Akan melihat:
   - **Summary cards** di atas:
     - Total Pendapatan
     - Total Pesanan
     - Rata-rata per Pesanan
   - **Daily breakdown** dibawah dengan daftar penjualan per hari

**Filter berdasarkan Tanggal:**

1. Klik icon **"Tanggal"** di atas
2. Pilih tanggal mulai dan tanggal akhir
3. Data akan difilter sesuai range tanggal
4. Summary cards akan diperbarui otomatis

**Format Laporan:**

```txt
Total Pendapatan:      Rp. 1.250.000
Total Pesanan:         50
Rata-rata per Pesanan: Rp. 25.000

Daily Breakdown:
26 Jan 2026 | Rp. 500.000 (20 pesanan)
25 Jan 2026 | Rp. 450.000 (18 pesanan)
24 Jan 2026 | Rp. 300.000 (12 pesanan)
```

---

## ⚙️ Tips & Trik

### Untuk Customer

- ✅ Periksa riwayat pesanan untuk track status
- ✅ Gunakan kategori menu untuk cepat menemukan item
- ✅ Registrasi dengan email untuk akun yang aman

### Untuk Cashier

- ✅ Check pesanan pending secara berkala
- ✅ Pastikan pembayaran sudah diterima sebelum marking PAID
- ✅ Print bon segera setelah customer bayar
- ✅ Gunakan refresh untuk update pesanan terbaru

### Untuk Owner

- ✅ Monitor penjualan harian untuk track performa
- ✅ Tambah/edit menu sesuai kebutuhan
- ✅ Filter laporan untuk analisa trend penjualan
- ✅ Export data laporan secara berkala

---

## 🐛 Troubleshooting

### Lupa Password

Saat login, aplikasi menyimpan password. Untuk akun default:

- Owner: `owner123`
- Cashier: `cashier123`

Jika perlu reset, hubungi administrator untuk clear database.

### Pesanan Tidak Muncul

**Untuk Cashier:**

1. Refresh halaman (pull down)
2. Pastikan ada pesanan baru dari customer

**Untuk Customer:**

1. Pastikan sudah checkout dari keranjang
2. Lihat di halaman "Pesanan Saya"

### Print Tidak Bekerja

1. Pastikan printer terhubung dengan device
2. Check permissions di Android Settings
3. Update driver printer jika perlu
4. Coba gunakan printer virtual PDF terlebih dahulu

### Database Error

Jika aplikasi crash atau data tidak tersimpan:

1. Clear app data dari Settings
2. Uninstall dan install ulang aplikasi
3. Data akan di-reset ke default

---

## 📞 Support

Untuk bantuan lebih lanjut atau melaporkan bug, silakan hubungi tim development.

**Version**: 1.0.0  
**Last Updated**: January 26, 2026
