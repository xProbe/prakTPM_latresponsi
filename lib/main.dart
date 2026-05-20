import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'models/cart_item.dart';
import 'services/notification_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Hive untuk penyimpanan lokal keranjang
  await Hive.initFlutter();
  Hive.registerAdapter(CartItemAdapter());
  await Hive.openBox<CartItem>('cartBox');
  
  // Inisialisasi Notifikasi Lokal (Bonus Nilai)
  try {
    await NotificationService.init();
  } catch (e) {
    print("Gagal menginisialisasi NotificationService: $e");
  }
  
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  
  runApp(MyApp(initialRoute: username != null && username.isNotEmpty ? '/home' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Latihan Responsi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/home', page: () => HomeWrapper()),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
