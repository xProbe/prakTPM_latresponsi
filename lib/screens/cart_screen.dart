import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/cart_item.dart';

class CartScreen extends StatelessWidget {
  final String username;

  const CartScreen({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var box = Hive.box<CartItem>('cartBox');

    return Scaffold(
      appBar: AppBar(title: Text('Cart')),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<CartItem> items, _) {
          List<CartItem> userItems = items.values.where((item) => item.user == username).toList();
          List<int> userItemKeys = items.keys.cast<int>().where((key) => items.get(key)?.user == username).toList();

          if (userItems.isEmpty) {
            return Center(child: Text('Your cart is empty', style: TextStyle(fontSize: 18)));
          }

          return ListView.builder(
            itemCount: userItems.length,
            itemBuilder: (context, index) {
              final item = userItems[index];
              final key = userItemKeys[index];

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: Image.network(
                    item.thumbnail, 
                    width: 50, 
                    height: 50, 
                    fit: BoxFit.cover,
                  ),
                  title: Text(item.title),
                  subtitle: Text('Qty: ${item.quantity} | Total: \$${(item.price * item.quantity).toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      box.delete(key);
                    },
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
