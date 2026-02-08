# 🐛 Panduan Debugging Hotpot POS

## 1. Debugging untuk WEB (Chrome)

### Cara Tercepat:
```bash
flutter run -d chrome
```

**Proses ini memakan waktu:**
- First run: 2-3 menit (karena build web files)
- Subsequent runs: 30-60 detik

### Jika Ingin Lebih Cepat (Hot Reload):
```bash
flutter run -d chrome --fast-start
```

### Buka DevTools untuk Debug:
Di VS Code, tekan:
- `r` - Hot reload (reload code)
- `R` - Hot restart (full restart)
- `d` - Detach (stop debugging)

Atau gunakan Chrome DevTools:
1. Buka Chrome DevTools (`F12`)
2. Buka tab **Console** untuk melihat logs
3. Buka tab **Network** untuk melihat Firebase requests

---

## 2. Debugging untuk Desktop (Windows)

### Syarat:
- Visual Studio dengan "Desktop development with C++" workload
- (Saat ini belum terinstall di sistem ini)

### Perintah:
```bash
flutter run -d windows
```

---

## 3. Debugging untuk Android

### Syarat:
- Android SDK (perlu install Android Studio)
- Device atau emulator Android

### Perintah:
```bash
flutter run -d emulator  # jika menggunakan emulator
flutter run              # jika ada device terhubung
```

---

## 4. Troubleshooting Debugging

### ❌ Error: "No connected devices"
```bash
flutter devices  # Cek device yang tersedia
```

**Solusi:**
- Pastikan Chrome sudah terinstall untuk web debugging
- Atau hubungkan Android device dengan USB

### ❌ Error: "Waiting for connection from debug service..."
**Ini normal!** Tunggu 2-3 menit di first run.

Tekan `Ctrl+C` jika:
- Sudah menunggu 5+ menit
- Melihat error message

Kemudian coba lagi dengan:
```bash
flutter run -d chrome --no-fast-start
```

### ❌ Error: "Firebase not initialized"
- Pastikan internet terhubung
- Pastikan Firebase Console sudah dikonfigurasi
- Cek browser console (`F12`) untuk error details

### ❌ Port sudah digunakan
```bash
flutter run -d chrome --web-port=8082
```

---

## 5. Tips untuk Debugging Lebih Baik

### Lihat Logs di Console:
```dart
print('Debug message: $variable');  // di Flutter
```

Lihat output di:
- VS Code Debug Console (bawaan)
- Chrome DevTools Console (`F12`)

### Gunakan Breakpoints:
1. Klik di margin code line (di kiri nomor baris)
2. Breakpoint akan terbentuk (red dot)
3. Saat program jalan, akan pause di breakpoint tersebut

### Inspect Variables:
Saat program pause di breakpoint:
- Hover di variable untuk melihat value
- Buka **Debug Console** untuk eval expressions

### Hot Reload vs Hot Restart:
- **Hot Reload (`r`)**: Update code, tapi state tetap (cepat)
- **Hot Restart (`R`)**: Update code + reset state (lebih lambat, tapi bersih)

---

## 6. Quick Debug Checklist

- [ ] Device/emulator terhubung?
- [ ] Chrome sudah terinstall?
- [ ] Internet terhubung?
- [ ] Sudah clear cache: `flutter clean`
- [ ] Sudah update pubspec.yaml: `flutter pub get`
- [ ] Lihat error di Chrome Console (`F12`)

---

## 7. Laporan Error untuk Support

Jika masih error, kumpulkan informasi:

1. **Output dari terminal:**
   ```bash
   flutter run -d chrome 2>&1 | tee debug.log
   ```

2. **Error dari Chrome Console:**
   - Buka `F12` → Console
   - Screenshot atau copy error message

3. **Flutter doctor output:**
   ```bash
   flutter doctor -v
   ```

Berikan ketiga informasi tersebut untuk bantuan lebih cepat!

---

## 8. Untuk Development Lebih Cepat

### Setup per project:
```bash
# Terminal 1: Run app
flutter run -d chrome

# Terminal 2: Watch file changes
dart run build_runner watch
```

### Atau gunakan VS Code shortcuts:
- `F5` - Start debugging
- `Ctrl+Shift+D` - Open Debug view
- `Ctrl+K Ctrl+I` - Toggle Debug Console

---

**Kapan Harus Debugging?**
- Saat UI tidak muncul dengan benar
- Saat data tidak tersimpan/tampil
- Saat ada error dari console
- Saat ingin optimize performance

**Jangan lupa:** Selalu lihat **console output** terlebih dahulu sebelum berspekulasi! 🎯
