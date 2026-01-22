# 🎓 Campus Lost & Found App

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase&logoColor=ffca28)](https://firebase.google.com/)

**Campus Lost & Found** adalah aplikasi mobile modern yang dirancang untuk membantu mahasiswa dan civitas akademika dalam menemukan barang yang hilang atau melaporkan barang yang ditemukan di lingkungan kampus.

---

## ✨ Fitur Utama

- 🛡️ **Sistem Autentikasi**: Login dan daftar akun dengan aman menggunakan Firebase Auth.
- 📢 **Lapor Barang Hilang**: Detail lengkap mulai dari foto, deskripsi, lokasi (Gedung A, B, CWS, dll), hingga tanggal kejadian.
- 🤝 **Lapor Barang Ditemukan**: Penemu dapat dengan mudah mengunggah info barang temuan.
- 🔍 **Pencarian Cerdas**: Filter barang berdasarkan deskripsi atau kategori (Elektronik, Dokumen, Dompet, dll).
- 🌓 **Mode Gelap (Dark Mode)**: Dukungan penuh untuk tema terang dan gelap yang elegan dan nyaman di mata.
- 📸 **Preview Foto Interaktif**: Klik pada gambar untuk melihat detail lebih jelas dengan dukungan zoom.
- 📱 **Onboarding Screen**: Pengalaman pengguna baru yang informatif saat pertama kali membuka aplikasi.
- 👤 **Manajemen Profil**: Edit nama dan foto profil dengan sistem penyimpanan Firestore yang efisien.
- 💬 **Integrasi WhatsApp**: Hubungi pemilik atau penemu barang secara langsung melalui tombol WhatsApp sekali klik.

---

## 🎨 Desain & UX

Aplikasi ini menggunakan desain yang terinspirasi oleh tren **Modern Light Blue UI**:
- **Palet Warna**: Biru langit cerah (Sky Blue) yang memberikan kesan bersih dan profesional.
- **Tipografi**: Menggunakan font **Inter** dari Google Fonts untuk keterbacaan tinggi.
- **Animasi**: Micro-interaction yang halus menggunakan *FadeInSlide* pada setiap elemen daftar.
- **Glassmorphism**: Efek transparansi pada beberapa elemen untuk kesan futuristik.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter SDK](https://flutter.dev) (Dart)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Backend Service**: 
  - **Firebase Authentication** (User identity)
  - **Cloud Firestore** (Real-time database & long-string photo storage)
  - **Firebase Storage** (Optional file hosting)
- **Local Storage**: `shared_preferences` untuk status onboarding.
- **Third Party**: 
  - `image_picker` (Upload foto)
  - `url_launcher` (Integrasi WhatsApp)
  - `google_fonts` (Tipografi premium)

---

## 🚀 Instalasi & Setup

1. **Clone Project**:
   ```bash
   git clone https://github.com/haruyaaa-ai/Campus-Lost-Found.git
   ```
2. **Setup Firebase**:
   - Daftarkan aplikasi di [Firebase Console](https://console.firebase.google.com/).
   - Download `google-services.json` (untuk Android) dan masukkan ke `android/app/`.
   - Aktifkan **Email/Password Auth**, **Firestore Database**, dan **Storage**.
   - Set Firestore rules ke mode publik atau sesuaikan dengan kebutuhan (lihat `FIREBASE_COMPLETE_SETUP.md`).
3. **Install Dependencies**:
   ```bash
   flutter pub get
   ```
4. **Jalankan Aplikasi**:
   ```bash
   flutter run
   ```

---

## 📋 Catatan Teknis (Optimasi Gambar)
Untuk menjaga performa database, aplikasi memiliki batasan ukuran upload foto sebesar **maksimal 800KB**. Foto profil disimpan di Firestore untuk menghindari batasan panjang URL pada sistem autentikasi Firebase standar.

---

## 👤 Informasi Mahasiswa (Developer)

| Detail | Informasi |
| :--- | :--- |
| **Nama** | Damar Satriatama Putra |
| **NIM** | 23552011300 |
| **Instansi** | Universitas Teknologi Bandung |
| **Tujuan** | Project UAS Pemrograman Mobile |

---

## 📑 Dokumentasi Tambahan
- [Panduan Deployment (Build APK/EXE)](DEPLOY.md)
- [Konfigurasi Firebase Lengkap](FIREBASE_COMPLETE_SETUP.md)
- [Bantuan & Setup Authentication](FIREBASE_AUTH_SETUP.md)

---
© 2026 Campus Lost & Found - Developed by Damar Satriatama Putra
=======
# Campus-Lost-Found

Campus Lost & Found adalah aplikasi mobile berbasis Flutter yang dirancang untuk membantu civitas akademika kampus dalam melaporkan, mencari, dan mengklaim barang yang hilang maupun ditemukan di lingkungan kampus. Aplikasi ini menyediakan dua jenis laporan utama, yaitu laporan barang hilang dan laporan barang ditemukan, sehingga memudahkan proses pencarian barang secara terstruktur dan efisien.

Aplikasi ini memanfaatkan REST API sebagai sumber data dinamis untuk menampilkan daftar barang hilang dan barang ditemukan, serta Firebase sebagai sistem autentikasi pengguna dan penyimpanan data pengguna serta data klaim barang. Aplikasi dijalankan pada perangkat Android maupun iOS dan dirancang untuk mendukung interaksi pengguna secara real-time melalui perubahan status barang.

Dengan konsep ini, pengguna yang kehilangan barang dapat mencari dan mengklaim barang yang ditemukan, sedangkan pengguna yang menemukan barang dapat membantu pemilik asli dengan melaporkan temuan tersebut ke dalam sistem.
>>>>>>> 45f50a5169bed2b736311d85d336c12aac986683
