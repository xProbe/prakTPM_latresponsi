import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// ==========================================
/// 🔔 NOTIFICATION SERVICE (FITUR BONUS)
/// ==========================================
/// Service ini bertugas untuk menampilkan notifikasi lokal di HP.
/// Sangat mudah dipelajari:
/// 1. Panggil `NotificationService.init()` di main.dart sekali saja.
/// 2. Panggil `NotificationService.showNotification(title: "...", body: "...")` kapanpun kamu mau memicu notifikasi.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Inisialisasi pengaturan notifikasi
  static Future<void> init() async {
    // Pengaturan icon untuk Android. `@mipmap/ic_launcher` adalah icon bawaan aplikasi Flutter.
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );
    
    await _notificationsPlugin.initialize(initSettings);
  }

  // Fungsi untuk menampilkan notifikasi
  static Future<void> showNotification({required String title, required String body}) async {
    // Tentukan detail saluran (channel) notifikasi untuk Android
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'cart_channel_id',     // ID unik saluran
      'Keranjang Belanja',   // Nama saluran yang tampil di pengaturan HP
      channelDescription: 'Saluran notifikasi untuk keranjang belanja',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );
    
    // Tampilkan notifikasinya!
    await _notificationsPlugin.show(
      DateTime.now().millisecond, // ID notifikasi acak berdasarkan milidetik saat ini agar tidak bertumpuk
      title,                      // Judul Notifikasi
      body,                       // Isi Pesan Notifikasi
      platformDetails,
    );
  }
}
