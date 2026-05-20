import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'models/cart_item.dart';
import 'models/cart_item.dart';
import 'screens/login_screen.dart';
import 'screens/home_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(CartItemAdapter());
  await Hive.openBox<CartItem>('cartBox');
  
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
      title: 'Keripikroll',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.orange.shade800,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
        colorScheme: ColorScheme.dark(
          primary: Colors.orange.shade800,
          secondary: Colors.orangeAccent,
        ),
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
