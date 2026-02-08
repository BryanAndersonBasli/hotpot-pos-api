# 🚀 Hotpot POS - Quick Start Debugging

## ⚡ Cara Tercepat Mulai Debug

### Opsi 1: Windows Batch (Klik 2x)
```
Double-click: start-debug.bat
```

### Opsi 2: PowerShell
```powershell
./start-debug.ps1
```

### Opsi 3: Command Line Manual
```bash
# Di direktori hotpot/
flutter run -d chrome
```

---

## 📋 Yang Terjadi Saat Debugging

### First Run (Normal)
```
⏱️  Waktu: 2-3 menit
📦 Proses: Compile Dart → Build Web Assets → Launch Chrome
✅ Setelah: Chrome terbuka dengan app
```

### Subsequent Runs (Hot Reload)
```
⏱️  Waktu: 30-60 detik
🔄 Proses: Update code → Hot reload
✅ Setelah: Perubahan langsung terlihat di Chrome
```

---

## 🎮 Shortcuts Saat Debugging

| Key | Action |
|-----|--------|
| `r` | Hot Reload (reload code) |
| `R` | Hot Restart (full restart) |
| `d` | Detach (stop debugging) |
| `s` | Take screenshot |
| `q` | Quit |

---

## 🔍 Melihat Error/Logs

### Terminal Output
- Error akan langsung muncul di terminal flutter run

### Chrome Developer Tools
```
Tekan F12 → Console tab
```
- Lihat semua print() statements
- Lihat error dari Firebase
- Lihat network requests

### Tips
```dart
// Debug print
print('VariableName: $variable');
print('DEBUG: Function executed');
```

---

## ❌ Common Issues & Fixes

### Issue: "Waiting for connection from debug service..."
**Solusi:**
- Tunggu 3-5 menit (normal)
- Jika > 5 min: Tekan `Ctrl+C` dan ulang
- Coba: `flutter run -d chrome --no-fast-start`

### Issue: "Chrome not found"
**Solusi:**
- Install Chrome dari: https://www.google.com/chrome/
- Atau gunakan Edge: `flutter run -d edge`

### Issue: Port already in use
**Solusi:**
```bash
flutter run -d chrome --web-port=8082
```

### Issue: App crashes saat startup
**Solusi:**
1. Buka Chrome F12 (DevTools)
2. Lihat Console tab untuk error
3. Copy error message
4. Sebutkan di laporan bug

---

## 📱 Jika Ingin Debug Platform Lain

### Desktop Windows (Memerlukan setup)
```bash
flutter run -d windows
```

### Android (Memerlukan Android SDK)
```bash
# Setup Android Studio terlebih dahulu
flutter run
```

---

## 🔧 Setup/Clean Cache

### Jika Masalah Persisten
```bash
# Clear semua cache Flutter
flutter clean

# Update dependencies
flutter pub get

# Verify setup
flutter doctor

# Coba lagi
flutter run -d chrome
```

---

## 📊 Performance Tips

### Untuk Debugging Lebih Cepat
1. **Jangan tutup Chrome saat debugging**
   - Hot reload akan lebih cepat
   
2. **Gunakan F12 Console**
   - Jangan hanya lihat terminal

3. **Commit perubahan sebelum test**
   - Jika error, bisa rollback cepat

4. **Test di Chrome dulu, baru platform lain**
   - Web paling cepat untuk development

---

## 🎯 Debugging Workflow

```
1. flutter run -d chrome
   ↓
2. Tunggu app load di Chrome
   ↓
3. Buat perubahan code
   ↓
4. Tekan 'r' untuk hot reload
   ↓
5. Lihat hasil di Chrome + F12 Console
   ↓
6. Ulangi step 3-5
```

---

## 📝 Laporan Bug Template

Saat error, kumpulkan:

1. **Terminal output:**
   ```bash
   flutter run -d chrome 2>&1 | Tee-Object -FilePath debug.log
   ```

2. **Chrome Console (F12):**
   - Screenshot error
   - Copy error message

3. **Flutter status:**
   ```bash
   flutter doctor -v > flutter-doctor.txt
   ```

Jika sudah, share `debug.log` + error message + screenshot untuk bantuan!

---

## ✅ Pre-Launch Checklist

- [ ] Internet connection aktif
- [ ] Chrome terinstall
- [ ] Di direktori `hotpot/` 
- [ ] Sudah run `flutter pub get`
- [ ] No other app using port 5900-5910

Ready? **Mulai debug!** 🚀
