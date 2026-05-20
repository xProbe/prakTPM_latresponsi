import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import '../models/cart_item.dart';

class CartScreen extends StatelessWidget {
  final String username; // Username aktif saat ini

  const CartScreen({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Membuka box keranjang belanja
    var box = Hive.box<CartItem>('cartBox');

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang Belanja')),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(), // Memantau perubahan database lokal secara langsung
        builder: (context, Box<CartItem> items, _) {
          
          // ========================================================
          // 🔍 FILTERING: Memisahkan Item Keranjang per User
          // ========================================================
          
          // 1. Ambil seluruh item belanjaan milik user aktif
          List<CartItem> userItems = items.values
              .where((item) => item.user == username)
              .toList();

          // 2. Ambil list key (String) dari item-item tersebut secara sejajar
          // Ini digunakan untuk menghapus item secara presisi di database
          List<dynamic> userItemKeys = items.keys
              .where((key) => items.get(key)?.user == username)
              .toList();

          // Tampilan jika keranjang belanja masih kosong
          if (userItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Keranjang Anda masih kosong', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey)
                  ),
                ],
              ),
            );
          }

          // Tampilkan daftar belanjaan menggunakan ListView
          return ListView.builder(
            itemCount: userItems.length,
            itemBuilder: (context, index) {
              final item = userItems[index];
              final itemKey = userItemKeys[index]; // Ini adalah String key unik ("username-productId")

              // Menghitung total harga per item produk (harga * kuantitas)
              double totalItemPrice = item.price * item.quantity;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    // Gambar produk
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.thumbnail, 
                        width: 60, 
                        height: 60, 
                        fit: BoxFit.cover,
                        // Menangani jika loading gambar error
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                    // Judul produk
                    title: Text(
                      item.title, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Kuantitas dan total harga item
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Kuantitas: ${item.quantity} | Total: \$${totalItemPrice.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                      ),
                    ),
                    // Tombol hapus item dari keranjang
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                      onPressed: () {
                        // Dialog konfirmasi hapus item (GetX dialog yang estetik)
                        Get.defaultDialog(
                          title: 'Hapus Produk',
                          middleText: 'Apakah Anda yakin ingin menghapus ${item.title} dari keranjang?',
                          textConfirm: 'Hapus',
                          textCancel: 'Batal',
                          confirmTextColor: Colors.white,
                          buttonColor: Colors.red,
                          onConfirm: () async {
                            // Hapus data langsung dari Hive menggunakan String key uniknya
                            await box.delete(itemKey);
                            
                            Get.back(); // Tutup dialog
                            Get.snackbar(
                              'Berhasil', 
                              'Produk dihapus dari keranjang',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.black87,
                              colorText: Colors.white,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
