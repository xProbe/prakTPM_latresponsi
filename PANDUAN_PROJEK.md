# 🧭 PANDUAN PENGGUNAAN PROJEK (UNTUK AWAM)
> **Panduan Memahami, Memodifikasi, dan Menjalankan Aplikasi Responsi Kamu**

Halo! Jangan khawatir jika kamu merasa masih awam dalam Flutter. Folder `latihan_responsi1` ini sekarang sudah dirapikan, diperbaiki dari bug, serta dilengkapi dengan fitur bonus (Notifikasi dan GPS/LBS). 

Seluruh kode program juga sudah diberikan **komentar bahasa Indonesia yang sangat jelas** di setiap baris kuncinya.

Dokumen ini adalah **peta petunjuk** agar kamu tahu apa isi projek ini, bagaimana cara mengubah datanya, dan cara menguji aplikasinya dengan mudah.

---

## 📂 1. PETA FOLDER: APA SAJA ISI DI DALAMNYA?

Dalam Flutter, semua kode yang kita tulis berada di dalam folder `lib/`. Berikut adalah peta dari isi folder `lib/` kamu:

* 📂 **`lib/`** (Pusat seluruh kode Flutter)
  * 📄 **`main.dart`**  
    * **Fungsi:** Gerbang masuk utama aplikasi. Di sini kita menghidupkan Hive (database lokal), SharedPreferences (session login), dan NotificationService (notifikasi bonus). Di sini juga ditentukan: *"Jika user sudah login, langsung ke Home. Jika belum, tampilkan halaman Login."*
  * 📂 **`models/`** (Tempat menyimpan cetakan data)
    * 📄 **`cart_item.dart`**  
      * **Fungsi:** Berisi cetakan data (`CartItem`) untuk barang-barang yang dimasukkan ke keranjang beserta **Adapter Hive** manual agar data tersebut bisa ditulis ke memori HP.
  * 📂 **`services/`** (Pelayan/Fitur pembantu di balik layar)
    * 📄 **`notification_service.dart`** 🌟 *(BONUS)*  
      * **Fungsi:** Mengelola pemicu push notification lokal di HP ketika user sukses mengklik tombol keranjang belanja.
  * 📂 **`screens/`** (Tampilan layar yang dilihat pengguna di HP)
    * 📄 **`login_screen.dart`**  
      * **Fungsi:** Layar login. Meminta username bebas dan password berupa NIM kamu.
    * 📄 **`home_wrapper.dart`**  
      * **Fungsi:** Induk/Pembungkus halaman utama yang menampilkan tombol menu bawah (Bottom Navigation Bar) untuk berpindah antara halaman **Home** dan **Profile**.
    * 📄 **`home_screen.dart`**  
      * **Fungsi:** Halaman toko yang mengambil daftar produk dari internet (API) lalu menampilkannya dalam bentuk daftar (ListView). Terdapat tombol keranjang belanja di pojok kanan atas.
    * 📄 **`product_detail_screen.dart`**  
      * **Fungsi:** Halaman detail produk. Ketika diklik dari home, halaman ini mengambil data detail secara mendiri dari API menggunakan **ID Produk**, mengatur jumlah barang (+ / -), menyimpan ke database Hive, dan memicu notifikasi.
    * 📄 **`cart_screen.dart`**  
      * **Fungsi:** Halaman keranjang belanja. Menampilkan daftar barang khusus untuk user yang sedang login, menghitung total belanjaan, dan memiliki tombol hapus belanjaan.
    * 📄 **`profile_screen.dart`** 📍 *(BONUS)*  
      * **Fungsi:** Halaman profil user. Menampilkan deskripsi diri, tombol logout, serta **fitur LBS (GPS)** untuk mendeteksi koordinat lokasi HP kamu saat tombol diklik.

---

## 🛠️ 2. TITIK TWEAKING: BAGIAN MANA YANG HARUS SAYA EDIT SAAT UJIAN?

Ketika ujian responsi besok berlangsung, kemungkinan besar asisten dosen akan meminta kamu mengubah beberapa parameter seperti NIM password atau URL API. 

Berikut adalah **panduan praktis lokasi baris kode** yang harus kamu edit:

### 🔑 A. Mengubah NIM (Password Login)
Jika kamu ingin mengubah NIM yang valid untuk masuk ke aplikasi:
1. Buka file [lib/screens/login_screen.dart](file:///e:/kuliah/praktikum_mobile/contoh-responsi/latihan_responsi1/lib/screens/login_screen.dart).
2. Cari baris berikut (sekitar baris **29**):
   ```dart
   const String targetNIM = '123230169'; // Ganti dengan NIM asli kamu saat responsi
   ```
3. Ganti `'123230169'` dengan NIM kamu sendiri.

### 🌐 B. Mengubah URL API Produk
Jika asisten dosen memberikan link API yang berbeda besok pagi:
* **Untuk Halaman Utama (Daftar Produk):**
  1. Buka file [lib/screens/home_screen.dart](file:///e:/kuliah/praktikum_mobile/contoh-responsi/latihan_responsi1/lib/screens/home_screen.dart).
  2. Cari baris berikut (sekitar baris **35**):
     ```dart
     final response = await http.get(Uri.parse('https://dummyjson.com/products'));
     ```
  3. Ganti `'https://dummyjson.com/products'` dengan link API baru dari asdos.

* **Untuk Halaman Detail (Detail Produk by ID):**
  1. Buka file [lib/screens/product_detail_screen.dart](file:///e:/kuliah/praktikum_mobile/contoh-responsi/latihan_responsi1/lib/screens/product_detail_screen.dart).
  2. Cari baris berikut (sekitar baris **38**):
     ```dart
     final response = await http.get(Uri.parse('https://dummyjson.com/products/${widget.productId}'));
     ```
  3. Sesuaikan URL dasar tersebut. Simbol `${widget.productId}` berfungsi untuk menyisipkan ID produk yang diklik di akhir URL secara otomatis.

### 🔔 C. Mengubah Isi Notifikasi
Jika ingin mengubah teks notifikasi yang muncul di HP saat user menambahkan produk:
1. Buka file [lib/screens/product_detail_screen.dart](file:///e:/kuliah/praktikum_mobile/contoh-responsi/latihan_responsi1/lib/screens/product_detail_screen.dart).
2. Cari baris berikut (sekitar baris **89**):
   ```dart
   await NotificationService.showNotification(
     title: "🛒 Keranjang Diperbarui!",
     body: "$_quantity unit ${_productDetail!['title']} berhasil dimasukkan ke keranjang.",
   );
   ```
3. Ganti teks `title` dan `body` sesuai kebutuhan soal ujian.

### 📍 D. Mengubah Akurasi GPS (LBS)
Jika kamu ingin mengubah tingkat akurasi pembacaan koordinat GPS (misal agar lebih hemat baterai atau lebih cepat):
1. Buka file [lib/screens/profile_screen.dart](file:///e:/kuliah/praktikum_mobile/contoh-responsi/latihan_responsi1/lib/screens/profile_screen.dart).
2. Cari baris berikut (sekitar baris **72**):
   ```dart
   Position position = await Geolocator.getCurrentPosition(
     desiredAccuracy: LocationAccuracy.high, // Akurasi tinggi
   );
   ```
3. Kamu bisa mengganti `LocationAccuracy.high` menjadi `LocationAccuracy.low` atau `LocationAccuracy.medium` sesuai perintah asdos.

---

## 🚀 3. CARA MENJALANKAN DAN MENGUJI APLIKASI

Untuk menjalankan projek ini di laptop kamu:

1. **Buka Visual Studio Code** lalu buka folder `latihan_responsi1`.
2. Buka terminal di VS Code (tekan tombol `Ctrl + ~` atau lewat menu `Terminal -> New Terminal`).
3. Jalankan perintah untuk mengunduh semua library/package (jika belum):
   ```bash
   flutter pub get
   ```
4. Hubungkan HP kamu menggunakan kabel USB (pastikan *USB Debugging* aktif) atau nyalakan Emulator Android.
5. Jalankan aplikasi dengan perintah:
   ```bash
   flutter run
   ```

---

## 🔥 TIPS EFEKTIF UNTUK UJIAN BESOK
* **Open Book Project:** Saat ujian, buka dokumen ini (`PANDUAN_PROJEK.md`) dan [PANDUAN_RESPONSI.md](file:///e:/kuliah/praktikum_mobile/contoh-responsi/PANDUAN_RESPONSI.md) di VS Code.
* **Periksa Internet:** Jika data produk tidak muncul (hanya loading berputar), pastikan laptop atau emulator kamu terhubung ke jaringan internet yang aktif.
* **Database Reset:** Jika data di keranjang belanja menjadi aneh karena kamu banyak melakukan utak-atik kode, kamu bisa menghapus data keranjang secara bersih dengan cara *Uninstall* aplikasi di emulator/HP, lalu jalankan `flutter run` kembali.

**Kamu sekarang memegang kendali penuh atas kode projek ini. Semoga responsi besok sukses dan mendapatkan nilai A!** 🎓🌟
