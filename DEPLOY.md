# Panduan Deployment Aplikasi Lost & Found

Dokumen ini berisi panduan cara melakukan build dan deployment untuk aplikasi Flutter Lost & Found ke platform Windows, Android, dan Web.

## ⚠️ PENTING: Setup Firebase Terlebih Dahulu!

**SEBELUM** melakukan deployment, pastikan Anda sudah mengaktifkan semua layanan Firebase:
- ✅ Firebase Authentication (Email/Password)
- ✅ Cloud Firestore (Database)
- ✅ Firebase Storage (Upload Foto)

📖 **Baca panduan lengkap di:** `FIREBASE_COMPLETE_SETUP.md`

Jika Firebase belum dikonfigurasi, aplikasi akan error:
- `firebase_auth/operation-not-allowed` - Authentication belum aktif
- `firebase_storage/object-not-found` - Storage belum aktif
- `permission-denied` - Firestore belum aktif atau rules salah

## 1. Persiapan
Pastikan semua dependensi sudah terinstall dan up-to-date:
```bash
flutter pub get
```

## 2. Build untuk Windows (.exe)
Untuk membuat file executable Windows:
```bash
flutter build windows --release
```
File hasil build akan berada di: `build\windows\runner\Release\`
Anda akan menemukan file `lostandfound.exe` dan folder dependensi lainnya di sana.

## 3. Build untuk Android (.apk)
Untuk membuat file APK Android:
```bash
flutter build apk --release
```
File APK akan berada di: `build\app\outputs\flutter-apk\app-release.apk`

## 4. Build untuk Web (Hosting)
Untuk membuat versi web yang siap hosting:
```bash
flutter build web --release
```
File hasil build akan berada di folder `build\web`.
Anda bisa mengupload isi folder ini ke Firebase Hosting, GitHub Pages, atau hosting lainnya.

### Deploy ke Firebase Hosting (Opsional)
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Init: `firebase init hosting` (pilih folder `build/web` sebagai public directory)
4. Deploy: `firebase deploy`

## Catatan Penting
- Pastikan tidak ada error saat menjalankan `flutter run` sebelum melakukan build.
- Untuk Windows, pastikan Visual Studio dengan C++ workload sudah terinstall (biasanya sudah jika Anda bisa menjalankan di Windows).
