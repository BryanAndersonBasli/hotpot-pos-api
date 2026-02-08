# 🔥 Firebase Setup Guide - WAJIB DIBACA!

## ⚠️ PENTING: Error "Firebase Error - Tidak dapat terhubung ke server"

Jika Anda melihat error ini saat mencoba tambah/edit/hapus menu atau membuat order:
```
❌ Firebase Error - Tidak dapat terhubung ke server

Pastikan:
• Firebase Console sudah setup
• Internet aktif
• Firestore Database aktif di Firebase
```

**Ini berarti Firebase belum dikonfigurasi!**

---

## 📋 Step-by-Step Setup Firebase

### 1. Buka Firebase Console
```
URL: https://console.firebase.google.com
```

### 2. Buat Project Baru (atau gunakan yang sudah ada)
- Klik **Create a new project**
- Nama project: `hotpot-pos` (atau nama lain)
- Tekan **Create**
- Tunggu hingga selesai (~1 menit)

### 3. Enable Firestore Database
1. Di sidebar kiri, klik **Build** → **Firestore Database**
2. Klik **Create Database**
3. Pilih mode: **Test mode** (untuk development)
   - ⚠️ PENTING: Jangan gunakan production mode tanpa security rules!
4. Pilih location: **asia-southeast1** (atau terdekat dengan Anda)
5. Klik **Create**
6. Tunggu hingga Firestore siap (~2 menit)

### 4. Enable Authentication
1. Di sidebar kiri, klik **Build** → **Authentication**
2. Klik tab **Sign-in method**
3. Klik provider **Email/Password**
4. Toggle **Enable** menjadi ON
5. Klik **Save**

### 5. Get Firebase Config
1. Di Firebase Console, klik ⚙️ **Settings** (gear icon)
2. Klik tab **Project settings**
3. Di bagian **Web API Key**, copy setiap value:
   - API Key
   - Project ID
   - Auth Domain
   - Database URL

### 6. Update firebase_options.dart
Buka file: `lib/firebase_options.dart`

Update bagian `web` dengan config dari Firebase Console:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: "YOUR_WEB_API_KEY_HERE",
  authDomain: "YOUR_AUTH_DOMAIN_HERE",
  projectId: "YOUR_PROJECT_ID_HERE",
  storageBucket: "YOUR_STORAGE_BUCKET_HERE",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID_HERE",
  appId: "YOUR_APP_ID_HERE",
  measurementId: "YOUR_MEASUREMENT_ID_HERE",
);
```

Cari value di Firebase Console:
- **Settings** → **Project settings** → **Web apps** → Pilih app Anda

### 7. Setup Security Rules (Optional tapi RECOMMENDED)

1. Di Firebase Console, klik **Firestore Database** → **Rules**
2. Replace dengan rules berikut:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow anyone to read
    match /{document=**} {
      allow read: if true;
    }
    
    // For now, allow anyone to write (development)
    // GANTI INI untuk production!
    match /{document=**} {
      allow write: if true;
    }
  }
}
```

3. Klik **Publish**

---

## ✅ Verify Firebase Sudah Setup Dengan Benar

### Test 1: Buka Aplikasi
1. Jalankan: `flutter run -d chrome`
2. Tunggu aplikasi load
3. Coba **Tambah Menu**
4. Lihat apakah ada pesan sukses

### Test 2: Cek di Firebase Console
1. Buka Firebase Console
2. Klik **Firestore Database**
3. Lihat collection **menu_items**
4. Apakah menu yang Anda tambahkan ada di sini?

Jika ada → ✅ **Firebase Setup Berhasil!**
Jika tidak → ❌ Cek langkah 1-7 di atas

---

## 🆘 Troubleshooting

### Error: "Permission denied" atau "PERMISSION_DENIED"
**Penyebab**: Security Rules terlalu ketat

**Solusi**:
1. Buka Firebase Console
2. Firestore Database → Rules
3. Ganti dengan rules di atas
4. Publish

### Error: "Code: INVALID_ARGUMENT"
**Penyebab**: firebase_options.dart belum di-update dengan config yang benar

**Solusi**:
1. Copy API Key dari Firebase Console
2. Update `lib/firebase_options.dart`
3. Jalankan: `flutter pub get`
4. Restart aplikasi

### Error: "FirebaseException: Cloud Firestore not available"
**Penyebab**: Firestore Database belum di-enable

**Solusi**:
1. Buka Firebase Console
2. Klik **Firestore Database**
3. Klik **Create Database** jika belum ada
4. Tunggu hingga siap

### Error: "Failed to resolve module specification for @angular/compiler-cli"
**Ini adalah development tool warning, bukan error aplikasi**
- Abaikan warning ini
- Aplikasi tetap berjalan dengan baik

---

## 🔒 Security Tips

### Development (Test Mode):
```
✅ Allow: READ dan WRITE untuk semua
```

### Production (WAJIB Setup):
```
❌ DON'T: Gunakan test mode di production!

✅ DO: Setup proper security rules
```

Contoh production rules (hanya user login bisa write):
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Public read
    match /menu_items/{document=**} {
      allow read: if true;
    }
    
    // Owner only
    match /menu_items/{document=**} {
      allow write: if request.auth != null;
    }
    
    // User own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Orders
    match /orders/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 📊 Firebase Project Structure

Setelah setup, struktur Firestore akan terlihat seperti:

```
Firestore
├── menu_items/
│   ├── [doc1] { name: "...", price: ..., }
│   ├── [doc2] { name: "...", price: ..., }
│   └── ...
│
├── orders/
│   ├── [doc1] { customer: "...", status: "...", }
│   ├── [doc2] { customer: "...", status: "...", }
│   └── ...
│
├── users/
│   ├── [uid1] { email: "...", role: "...", }
│   └── ...
│
└── sales/
    ├── [doc1] { amount: ..., date: "...", }
    └── ...
```

---

## ✨ Setelah Setup Selesai

1. **Restart Aplikasi:**
   ```bash
   flutter run -d chrome
   ```

2. **Test Semua Fitur:**
   - [ ] Login
   - [ ] Tambah Menu
   - [ ] Edit Menu
   - [ ] Hapus Menu
   - [ ] Buat Order
   - [ ] Lihat Order

3. **Verifikasi di Firebase:**
   - Buka Firebase Console
   - Lihat apakah data tersimpan di Firestore
   - Lihat logs jika ada error

4. **Backup Config:**
   - Save file `lib/firebase_options.dart`
   - Ini penting jika perlu setup ulang

---

## 🎯 Checklist Setup

- [ ] Firebase Project dibuat
- [ ] Firestore Database di-enable
- [ ] Authentication (Email/Password) di-enable
- [ ] Security Rules di-setup
- [ ] `firebase_options.dart` di-update dengan config
- [ ] Aplikasi di-restart
- [ ] Test login berhasil
- [ ] Test tambah menu berhasil
- [ ] Data terlihat di Firebase Console

Semua ✅? **Selamat! Firebase sudah siap!** 🎉

---

## 💡 Tips

- **Jangan lupa**: Update `lib/firebase_options.dart` dengan config yang benar!
- **Security Rules**: Selalu setup proper rules sebelum production
- **Test Mode**: Hanya untuk development, maksimal 1 bulan
- **Backup**: Save firebase_options.dart di tempat aman

---

**Butuh bantuan?**
- Check Firebase Console logs
- Buka browser F12 Console untuk error messages
- Cek terminal output saat menjalankan `flutter run`

Semoga Firebase setup lancar! 🚀
