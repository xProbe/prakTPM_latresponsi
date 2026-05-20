import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/cart_item.dart';
import '../services/notification_service.dart'; // Import notifikasi bonus

class ProductDetailScreen extends StatefulWidget {
  final int productId; // Menerima ID produk untuk di-fetch
  final String username; // Menerima username aktif

  const ProductDetailScreen({Key? key, required this.productId, required this.username}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, dynamic>? _productDetail; // Menyimpan data hasil fetch API detail
  bool _isLoading = true; // Status loading API
  int _quantity = 1; // Kuantitas pilihan user
  int _stock = 0; // Stok maksimal produk

  @override
  void initState() {
    super.initState();
    _fetchProductDetail(); // Jalankan fetch data saat halaman dibuka
  }

  // ==========================================
  // 🔄 FETCH: Mengambil Data Detail by ID dari API
  // ==========================================
  void _fetchProductDetail() async {
    try {
      // Panggil endpoint detail (menggunakan ID produk)
      final response = await http.get(Uri.parse('https://dummyjson.com/products/${widget.productId}'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _productDetail = data;
          _stock = data['stock'] ?? 10; // Ambil stok dari response API
          _isLoading = false;
        });
      } else {
        Get.snackbar('Error', 'Gagal memuat detail produk dari server.');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan koneksi internet: $e');
      setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // 💾 HIVE STORAGE: Simpan/Update data ke Hive
  // ==========================================
  void _addToCart() async {
    if (_productDetail == null) return;

    var box = Hive.box<CartItem>('cartBox');
    
    // ========================================================
    // 💡 SOLUSI AMAN: Gunakan Unique String Key (Anti-Bug Index)
    // Format Key: "username-productId"
    // ========================================================
    String uniqueKey = "${widget.username}-${widget.productId}";

    // Periksa apakah produk ini sudah pernah dimasukkan oleh user ini sebelumnya
    if (box.containsKey(uniqueKey)) {
      // Jika ada, ambil data lamanya, lalu jumlahkan kuantitasnya
      var existingItem = box.get(uniqueKey)!;
      existingItem.quantity += _quantity;

      // Simpan kembali data yang sudah diperbarui kuantitasnya
      await box.put(uniqueKey, existingItem);
    } else {
      // Jika belum ada, buat objek CartItem baru
      final newItem = CartItem(
        id: widget.productId,
        title: _productDetail!['title'],
        price: (_productDetail!['price'] as num).toDouble(),
        quantity: _quantity,
        user: widget.username,
        thumbnail: _productDetail!['thumbnail'] ?? '',
      );

      // Simpan menggunakan unique key tadi
      await box.put(uniqueKey, newItem);
    }

    // ==========================================
    // 🔔 TRIGGER LOCAL NOTIFICATION (FITUR BONUS)
    // ==========================================
    try {
      await NotificationService.showNotification(
        title: "🛒 Keranjang Diperbarui!",
        body: "$_quantity unit ${_productDetail!['title']} berhasil dimasukkan ke keranjang.",
      );
    } catch (e) {
      print("Gagal menampilkan notifikasi: $e");
    }

    Get.snackbar(
      'Berhasil', 
      'Produk berhasil masuk ke keranjang!', 
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    
    Get.back(); // Kembali ke halaman Home
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? 'Loading...' : (_productDetail?['title'] ?? 'Detail Produk')),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) // Tampilkan loading saat fetch data
        : _productDetail == null
          ? const Center(child: Text('Data produk tidak ditemukan.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Produk
                  Center(
                    child: Image.network(
                      _productDetail!['thumbnail'] ?? '', 
                      height: 250, 
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Judul Produk
                  Text(
                    _productDetail!['title'] ?? '', 
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 8),
                  
                  // Harga Produk
                  Text(
                    '\$${_productDetail!['price']}', 
                    style: const TextStyle(fontSize: 22, color: Colors.green, fontWeight: FontWeight.w600)
                  ),
                  const SizedBox(height: 16),
                  
                  // Deskripsi Produk
                  Text(
                    _productDetail!['description'] ?? 'Tidak ada deskripsi produk.', 
                    style: const TextStyle(fontSize: 16)
                  ),
                  const SizedBox(height: 16),
                  
                  // Info Stok
                  Text(
                    'Stok Tersedia: $_stock', 
                    style: TextStyle(fontSize: 16, color: Colors.grey[700])
                  ),
                  const SizedBox(height: 24),
                  
                  // Kuantitas Selector (+ dan -)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 36, color: Colors.blue),
                        onPressed: () {
                          if (_quantity > 1) {
                            setState(() {
                              _quantity--;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$_quantity', 
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 36, color: Colors.blue),
                        onPressed: () {
                          if (_quantity < _stock) {
                            setState(() {
                              _quantity++;
                            });
                          } else {
                            Get.snackbar(
                              'Stok Terbatas', 
                              'Kuantitas tidak boleh melebihi stok yang tersedia',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Tombol Tambah ke Keranjang
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart, size: 24),
                      onPressed: _addToCart,
                      label: const Text('Masukkan ke Keranjang', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
