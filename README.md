# Latihan Responsi

Aplikasi ini merupakan aplikasi toko online sederhana untuk memenuhi tugas latihan responsi. Aplikasi ini mendapatkan data produk dari API Eksternal (`https://dummyjson.com/products`).

## Struktur Folder

- `lib/`
  - `main.dart`: Titik awal aplikasi (entry point). Disini dilakukan inisialisasi untuk `Hive` dan `SharedPreferences`. Selain itu, dilakukan pengecekan status login dari user untuk menentukan apakah akan diarahkan ke halaman login atau halaman utama (home).
  - `models/`: Folder ini berisi kelas model data.
    - `cart_item.dart`: Berisi definisi model `CartItem` dan adapter Hive (`CartItemAdapter`) yang berfungsi untuk menyimpan data keranjang belanja secara lokal.
  - `screens/`: Folder yang berisi seluruh antarmuka pengguna (UI).
    - `login_screen.dart`: Halaman untuk melakukan login. Terdapat validasi agar username dan password (NIM) tidak kosong serta memastikan password berupa angka. Username disimpan dalam session menggunakan `SharedPreferences`.
    - `home_wrapper.dart`: Halaman yang membungkus (wrapper) dan mengelola navigasi tab bawah (BottomNavigationBar) antara halaman Home dan halaman Profile.
    - `home_screen.dart`: Halaman utama yang menampilkan informasi username yang sedang login, daftar produk yang diambil dari API eksternal, dan tombol keranjang yang menuju `CartScreen`.
    - `product_detail_screen.dart`: Menampilkan detail informasi lengkap dari produk yang dipilih. Terdapat fitur untuk menambah dan mengurangi kuantitas produk serta tombol untuk menambahkan produk ke keranjang yang akan disimpan di local database `Hive`.
    - `cart_screen.dart`: Menampilkan daftar produk yang telah ditambahkan ke keranjang oleh user yang sedang login. Setiap user memiliki list item yang berbeda, dan tiap item dapat dihapus dari keranjang.
    - `profile_screen.dart`: Halaman profil yang menampilkan informasi username, deskripsi user, dan tombol logout untuk menghapus session dan kembali ke halaman login.

## Teknologi dan Library yang Digunakan

- `http`: Untuk melakukan request HTTP ke API eksternal.
- `shared_preferences`: Sebagai Local Storage untuk menyimpan session login (username).
- `hive` & `hive_flutter`: Sebagai Local Database yang ringan dan cepat untuk menyimpan data produk dalam keranjang.
- `get` (GetX): Sebagai library manajemen state opsional, digunakan di project ini untuk manajemen navigasi dan mempermudah menampilkan snackbar tanpa `context`.
