# 🔥 Panduan Lengkap Setup Firebase untuk Aplikasi Lost & Found

## 📋 Layanan Firebase yang Digunakan
Aplikasi ini menggunakan 3 layanan Firebase:
1. ✅ **Firebase Authentication** - Login & Registrasi
2. 🗄️ **Cloud Firestore** - Database untuk menyimpan data barang
3. 📸 **Firebase Storage** - Upload & simpan foto barang

---

## 🚀 LANGKAH 1: Aktifkan Firebase Authentication

### Error yang muncul jika belum aktif:
```
firebase_auth/operation-not-allowed
```

### Cara Mengaktifkan:
1. Buka **Firebase Console**: https://console.firebase.google.com/
2. Pilih **project** aplikasi Lost & Found Anda
3. Klik **"Authentication"** di menu kiri (ikon kunci 🔑)
4. Jika pertama kali, klik tombol **"Get Started"**
5. Klik tab **"Sign-in method"** di bagian atas
6. Cari **"Email/Password"** di daftar provider
7. Klik pada baris **"Email/Password"**
8. **Toggle "Enable"** (aktifkan yang pertama, bukan Email link)
9. Klik tombol **"Save"**

### ✅ Verifikasi:
- Status "Email/Password" harus menunjukkan **"Enabled"**

---

## 🚀 LANGKAH 2: Aktifkan Cloud Firestore

### Error yang muncul jika belum aktif:
```
permission-denied atau missing-permissions
```

### Cara Mengaktifkan:
1. Di Firebase Console, klik **"Firestore Database"** di menu kiri (ikon database 🗄️)
2. Klik tombol **"Create database"**
3. Pilih lokasi server (pilih yang terdekat, misalnya **"asia-southeast1"** atau **"asia-southeast2"**)
4. Pilih mode **"Start in test mode"** (untuk development)
   - **PENTING**: Test mode memungkinkan read/write tanpa autentikasi (hanya untuk development)
5. Klik **"Enable"**
6. Tunggu beberapa saat hingga database dibuat

### ⚙️ Atur Security Rules (PENTING!):
Setelah database dibuat, atur security rules:

1. Di halaman Firestore, klik tab **"Rules"**
2. **Ganti** rules yang ada dengan kode berikut:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write to all authenticated users
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

3. Klik **"Publish"**

**Penjelasan Rules:**
- `request.auth != null` = Hanya user yang sudah login yang bisa akses
- Lebih aman daripada test mode yang allow all

### ✅ Verifikasi:
- Status Firestore harus **"Active"**
- Anda akan melihat tab "Data", "Rules", "Indexes", dll

---

## 🚀 LANGKAH 3: Aktifkan Firebase Storage

### Error yang muncul jika belum aktif:
```
firebase_storage/object-not-found
firebase_storage/unauthorized
```

### Cara Mengaktifkan:
1. Di Firebase Console, klik **"Storage"** di menu kiri (ikon folder 📁)
2. Klik tombol **"Get started"**
3. Akan muncul dialog tentang security rules:
   - Pilih **"Start in test mode"** (untuk development)
   - Atau pilih **"Start in production mode"** (lebih aman, tapi perlu konfigurasi)
4. Klik **"Next"**
5. Pilih lokasi server (sama dengan Firestore, misalnya **"asia-southeast1"**)
6. Klik **"Done"**
7. Tunggu beberapa saat hingga Storage dibuat

### ⚙️ Atur Security Rules (PENTING!):
Setelah Storage dibuat, atur security rules:

1. Di halaman Storage, klik tab **"Rules"**
2. **Ganti** rules yang ada dengan kode berikut:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated users to upload and read images
    match /{allPaths=**} {
      allow read: if true; // Anyone can read (untuk public access gambar)
      allow write: if request.auth != null; // Only authenticated users can upload
    }
  }
}
```

3. Klik **"Publish"**

**Penjelasan Rules:**
- `allow read: if true` = Semua orang bisa lihat gambar (public)
- `allow write: if request.auth != null` = Hanya user login yang bisa upload
- Cocok untuk aplikasi Lost & Found karena gambar harus bisa dilihat semua orang

### 🔒 Alternatif Rules (Lebih Ketat):
Jika ingin hanya user login yang bisa lihat gambar:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### ✅ Verifikasi:
- Status Storage harus **"Active"**
- Anda akan melihat tab "Files", "Rules", "Usage"

---

## 🧪 TESTING SETELAH SETUP LENGKAP

### 1. Force Close Aplikasi
- Di HP Android, force close aplikasi Lost & Found
- Atau uninstall dan install ulang APK

### 2. Test Registrasi
1. Buka aplikasi
2. Klik **"Daftar"** atau **"Register"**
3. Masukkan:
   - Email: `test@example.com`
   - Password: `123456` (minimal 6 karakter)
4. Klik **"Daftar"**
5. ✅ Seharusnya berhasil!

### 3. Test Login
1. Login dengan email dan password yang baru dibuat
2. ✅ Seharusnya berhasil masuk

### 4. Test Lapor Barang Hilang
1. Klik tombol **"Lapor Barang"** atau **"+"**
2. Isi form:
   - Judul: `Dompet Hitam`
   - Deskripsi: `Hilang di parkiran`
   - Kategori: Pilih kategori
   - Lokasi: `Gedung A`
3. Klik **"Pilih Foto"** dan ambil/pilih foto
4. Klik **"Simpan"** atau **"Submit"**
5. ✅ Seharusnya berhasil upload!

---

## 📊 MONITORING DI FIREBASE CONSOLE

### Cek User yang Terdaftar:
1. Buka **Authentication** > tab **"Users"**
2. Anda akan melihat daftar email user yang sudah registrasi

### Cek Data Barang:
1. Buka **Firestore Database** > tab **"Data"**
2. Anda akan melihat collection **"items"** (laporan barang) dan **"users"** (data profil pengguna).
3. Klik untuk melihat data barang atau profil yang sudah tersimpan.
   - **Note**: Foto profil kini disimpan di collection **"users"** untuk mendukung ukuran data yang lebih besar (base64).

### Cek Foto yang Diupload:
1. Buka **Storage** > tab **"Files"**
2. Anda akan melihat folder dengan foto-foto yang diupload
3. Klik foto untuk melihat URL dan detail

---

## ⚠️ TROUBLESHOOTING

### Error: "permission-denied" di Firestore
**Solusi:**
- Pastikan Security Rules sudah di-publish
- Pastikan user sudah login (authenticated)
- Cek di Console > Firestore > Rules

### Error: "unauthorized" di Storage
**Solusi:**
- Pastikan Security Rules sudah di-publish
- Pastikan user sudah login untuk upload
- Cek di Console > Storage > Rules

### Error: "quota-exceeded"
**Solusi:**
- Anda sudah mencapai limit gratis Firebase
- Upgrade ke Blaze plan (pay-as-you-go)
- Atau tunggu reset quota bulan depan

### Foto tidak muncul di aplikasi
**Solusi:**
- Pastikan Storage rules allow read: `if true`
- Cek koneksi internet
- Cek URL foto di Firestore apakah valid

---

## 📋 CHECKLIST LENGKAP

### Setup Firebase Console:
- [ ] Buka Firebase Console
- [ ] Pilih project yang benar
- [ ] Aktifkan Authentication (Email/Password)
- [ ] Aktifkan Cloud Firestore
- [ ] Atur Firestore Security Rules
- [ ] Aktifkan Firebase Storage
- [ ] Atur Storage Security Rules
- [ ] Publish semua rules

### Testing di Aplikasi:
- [ ] Force close / reinstall aplikasi
- [ ] Test registrasi akun baru
- [ ] Test login
- [ ] Test lapor barang dengan foto
- [ ] Test lihat daftar barang
- [ ] Verifikasi data di Firebase Console

---

## 🔐 SECURITY RULES PRODUCTION (Untuk Deploy)

Ketika aplikasi sudah siap production, ganti rules menjadi lebih ketat:

### Firestore Rules (Production):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /items/{itemId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
                               request.auth.uid == resource.data.userId;
    }
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Storage Rules (Production):
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      // Anyone can read
      allow read: if true;
      // Only authenticated users can upload
      // Limit file size to 5MB
      allow write: if request.auth != null &&
                      request.resource.size < 5 * 1024 * 1024;
    }
  }
}
```

---

## 💡 TIPS

1. **Gunakan Test Mode** saat development untuk mempermudah testing
2. **Ganti ke Production Rules** sebelum publish ke Play Store
3. **Monitor Usage** di Firebase Console untuk menghindari over-quota
4. **Backup Data** secara berkala dari Firestore
5. **Set Budget Alerts** jika upgrade ke Blaze plan

---

## 🆘 Masih Error?

Jika masih mengalami error setelah mengikuti semua langkah:

1. **Tunggu 2-3 menit** setelah mengaktifkan layanan (propagation time)
2. **Restart aplikasi** di HP (force close)
3. **Cek koneksi internet** di HP
4. **Verifikasi** di Firebase Console bahwa semua layanan status "Enabled"
5. **Cek logs** di Firebase Console > Analytics atau Crashlytics

---

**Selamat! Aplikasi Lost & Found Anda sekarang sudah siap digunakan! 🎉**
