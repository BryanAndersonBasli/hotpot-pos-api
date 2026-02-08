# 🌐 WEB SUPPORT - HOTPOT POS

Aplikasi HOTPOT POS sekarang support web dengan mock data untuk testing!

## ✅ Apa yang Berubah

### Platform Support

- ✅ **Android** - SQLite Database (Production)
- ✅ **iOS** - SQLite Database (Production)
- ✅ **Web** - Mock In-Memory Data (Testing/Demo)
- ✅ **Desktop** - SQLite Database (Production)

## 🔑 Web Login Credentials

Di web, gunakan akun default yang sama:

```bash
Owner: owner / owner123
Cashier: cashier / cashier123
Customer: Bisa register baru
```

## 📊 Web Features

### Tersedia di Web

- ✅ Login dengan 3 role
- ✅ Register customer
- ✅ Browse menu (dengan mock data)
- ✅ Shopping cart
- ✅ Order management
- ✅ Sales reporting (dengan mock data)

### Tidak Support di Web

- ❌ Persistent database (data reset saat refresh)
- ❌ Print receipt (tidak ada printer di browser)
- ❌ File upload (image upload)

## 🚀 Cara Jalankan di Web

### Chrome

```bash
flutter run -d chrome
```

### Edge

```bash
flutter run -d edge
```

### Firefox/Safari

```bash
flutter run -d web
flutter devices  # Lihat available devices
```

## 📝 Mock Data Web

Untuk testing di web, aplikasi menggunakan mock data:

### Users (Mock)

```bash
owner / owner123
cashier / cashier123
```

### Menu (5 sample items)

- Tom Yum Soup (Soup)
- Seafood Mix (Seafood)
- Noodle Ramen (Noodle)
- Nasi Goreng (Rice)
- Es Teh Manis (Drink)

### Data Persistence

- **Mobile/Desktop**: Data simpan di SQLite (persist)
- **Web**: Data simpan di memory (hilang saat refresh)

## 🔧 Technical Implementation

### Architecture

```text
Mobile/Desktop: App → Provider → DatabaseService → SQLite
Web:           App → Provider → Mock Data (Memory)
```

### Auto-Detection Platform

Aplikasi otomatis mendeteksi platform:

```dart
bool _isWeb = !Platform.isAndroid && !Platform.isIOS && ...
if (_isWeb) {
  // Gunakan mock data
} else {
  // Gunakan database
}
```

### Dependencies Tambahan

```yaml
hive: ^2.2.3
hive_flutter: ^1.1.0
shared_preferences: ^2.2.2
```

## ⚠️ Catatan Penting

### Untuk Production Web

Jika ingin production di web:

1. Setup backend API
2. Replace mock data dengan API calls
3. Implement persistent storage (IndexedDB/LocalStorage)
4. Add authentication token

### Contoh Backend Integration

```dart
// Ganti mock data dengan API
Future<User?> getUserByUsernamePassword(String username, String password) async {
  final response = await http.post(
    Uri.parse('https://api.example.com/login'),
    body: {'username': username, 'password': password},
  );
  
  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  }
  return null;
}
```

## 🧪 Testing Web

### Test Flow

1. **Customer Journey**
   - Register akun
   - Browse menu
   - Add to cart
   - Checkout

2. **Cashier Flow**
   - View orders
   - Process orders
   - Mark as paid
   - (Print tidak support)

3. **Owner Flow**
   - Add/Edit menu
   - View sales
   - Filter by date

## 📱 Responsive Design

Aplikasi sudah responsive untuk:

- ✅ Desktop (1280px+)
- ✅ Tablet (768px - 1279px)
- ✅ Mobile (< 768px)

## 🔐 Security Notes

### Web Demo Mode

- Password disimpan dalam mock data (JANGAN di production)
- Tidak ada encryption
- Gunakan HTTPS di production

### Recommendations

1. Implement proper authentication
2. Use secure tokens
3. Hash passwords
4. Add CORS security
5. Rate limiting

## 📚 Dokumentasi Lengkap

Untuk dokumentasi lengkap:

- DOKUMENTASI.md
- PANDUAN_PENGGUNA.md
- DOKUMENTASI_TEKNIS.md

---

**Status**: Beta - Ready for Testing  
**Last Updated**: January 26, 2026
