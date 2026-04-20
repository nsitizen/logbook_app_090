# 🛣️ Logbook Offline First + Smart-Patrol Vision

Aplikasi *mobile* berbasis Flutter yang dirancang untuk membantu petugas patroli dalam mendeteksi, mendokumentasikan, dan menganalisis kerusakan jalan (aspal). Aplikasi ini dilengkapi dengan modul **Pengolahan Citra Digital (PCD)** yang dibangun murni menggunakan fungsi dasar bahasa Dart, tanpa bergantung pada *library* eksternal C++ seperti OpenCV.

# Demo Aplikasi
![Demo Aplikasi](assets\gif\Demo_PCD.gif)

## ✨ Fitur Utama

* 📸 **Kamera Terintegrasi:** Modul kamera kustom untuk mengambil gambar jalan raya secara presisi tanpa *distortion/stretching*.
* 🎛️ **PCD Editor (Native Dart):**
  * **Koreksi Gamma (Brightness):** Penyesuaian intensitas cahaya secara non-linear.
  * **Color-Preserving Histogram Equalization:** Peningkatan kontras retakan aspal tingkat dewa tanpa merusak warna (*chrominance*) asli jalanan.
  * **Spatial Noise Reduction:** Filter penghilang derau menggunakan **Mean Filter**, **Median Filter** (pengurutan matriks 3x3 manual), dan **Gaussian Blur**.
  * **Edge Detection & Sharpening:** Filter **Sobel** dan **High-Pass Convolution** untuk menonjolkan detail tekstur jalan yang rusak.
* 📝 **Sistem Pencatatan Harian (Logbook):** Fitur pencatatan aktivitas harian yang hak aksesnya diatur secara spesifik. Catatan hanya dapat diakses atau dilihat berdasarkan siapa pembuatnya (*author*), izin visibilitas yang diberikan (publik/privat), serta pengaturan hak akses untuk anggota dalam satu grup/tim.
* 🏗️ **Clean Architecture:** Pemisahan ketat antara *Business Logic* (Controller) dan *User Interface* (View) menggunakan pola `ChangeNotifier` & `ListenableBuilder`.

## 🛠️ Teknologi & *Library* yang Digunakan

* **Framework:** Flutter & Dart
* **Pengolahan Citra:** `image` (Manipulasi piksel murni di memori)
* **Kamera:** `camera`
* **Antarmuka Tambahan:** `flutter_speed_dial` (Untuk menu aksi logbook)

## 🚀 Prasyarat Instalasi

Sebelum menjalankan aplikasi ini, pastikan komputer Anda telah terinstal:
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (Versi 3.0.0 ke atas)
* [Dart SDK](https://dart.dev/get-dart)
* Android Studio (beserta Android SDK) atau VS Code dengan ekstensi Flutter.
* *Device* fisik (HP Android) sangat direkomendasikan untuk pengujian kamera dan pemrosesan citra, dibanding menggunakan Emulator.

## 📦 Cara Instalasi & Menjalankan Aplikasi

Ikuti langkah-langkah berikut untuk menjalankan proyek di mesin lokal Anda:

1. **Clone repositori ini:**
   ```bash
   git clone [https://github.com/nsitizen/logbook_app_090.git](https://github.com/nsitizen/logbook_app_090.git)
   cd logbook_app_090
2. **Bersihkan cache proyek:**
   ```bash
   flutter clean
3. **Unduh semua dependensi:**
   ```bash
   flutter pub get
4. **Jalankan aplikasi (Pastikan device atau emulator sudah terhubung):**
   ```bash
   flutter run

## ⚠️ Catatan Penting Terkait Performa (PCD)

Aplikasi ini menggunakan algoritma Spatial Filtering (seperti Median Filter dan Histogram Equalization) yang ditulis secara manual dan dieksekusi secara berurutan (sequential) menggunakan Dart murni di perangkat seluler.

* Waktu Tunggu: Saat menekan tombol filter seperti Median atau Hist. Equal pada gambar beresolusi tinggi (kamera HP modern), proses komputasi iterasi matriks dapat memakan waktu 1 hingga 3 detik.

* Indikator Loading: Aplikasi telah dilengkapi dengan UI loading indicator (lingkaran ungu) yang akan berputar selama proses komputasi berlangsung untuk memastikan aplikasi tidak terlihat freeze atau macet. Harap tunggu hingga proses selesai.


Dibuat untuk memenuhi Evaluasi Tengah Semester (ETS) Pengolahan Citra Digital 

Nama Mahasiswa: Siti Soviyyah
NIM: 241511090