import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/cart_item.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map product;
  final String username;

  const ProductDetailScreen({Key? key, required this.product, required this.username}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  late int _stock;

  @override
  void initState() {
    super.initState();
    _stock = widget.product['stock'] ?? 10;
  }

  void _addToCart() async {
    var box = Hive.box<CartItem>('cartBox');
    
    final item = CartItem(
      id: widget.product['id'],
      title: widget.product['title'],
      price: widget.product['price'].toDouble(),
      quantity: _quantity,
      user: widget.username,
      thumbnail: widget.product['thumbnail'],
    );

    // Check if item already exists for user
    int existingIndex = -1;
    for (int i = 0; i < box.length; i++) {
      var current = box.getAt(i);
      if (current != null && current.id == item.id && current.user == item.user) {
        existingIndex = i;
        break;
      }
    }

    if (existingIndex != -1) {
      var current = box.getAt(existingIndex)!;
      box.putAt(existingIndex, CartItem(
        id: current.id,
        title: current.title,
        price: current.price,
        quantity: current.quantity + _quantity,
        user: current.user,
        thumbnail: current.thumbnail,
      ));
    } else {
      box.add(item);
    }

    Get.snackbar('Success', 'Added to cart!', snackPosition: SnackPosition.BOTTOM);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product['title'])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                widget.product['thumbnail'], 
                height: 250, 
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 24),
            Text(widget.product['title'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('\$${widget.product['price']}', style: TextStyle(fontSize: 22, color: Colors.green, fontWeight: FontWeight.w600)),
            SizedBox(height: 16),
            Text(widget.product['description'] ?? '', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text('Stock: $_stock', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle_outline, size: 32),
                  onPressed: () {
                    if (_quantity > 1) {
                      setState(() {
                        _quantity--;
                      });
                    }
                  },
                ),
                SizedBox(width: 16),
                Text('$_quantity', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, size: 32),
                  onPressed: () {
                    if (_quantity < _stock) {
                      setState(() {
                        _quantity++;
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _addToCart,
                child: Text('Add to Cart', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
