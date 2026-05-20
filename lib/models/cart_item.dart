import 'package:hive/hive.dart';

class CartItem {
  final int id;
  final String title;
  final double price;
  int quantity;
  final String user;
  final String thumbnail;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.user,
    required this.thumbnail,
  });
}

class CartItemAdapter extends TypeAdapter<CartItem> {
  @override
  final int typeId = 0;

  @override
  CartItem read(BinaryReader reader) {
    return CartItem(
      id: reader.readInt(),
      title: reader.readString(),
      price: reader.readDouble(),
      quantity: reader.readInt(),
      user: reader.readString(),
      thumbnail: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.title);
    writer.writeDouble(obj.price);
    writer.writeInt(obj.quantity);
    writer.writeString(obj.user);
    writer.writeString(obj.thumbnail);
  }
}
