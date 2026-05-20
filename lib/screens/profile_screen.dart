import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart'; // Import package geolocator untuk GPS

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = '';
  
  // Variabel untuk mengelola status LBS/GPS
  String _locationText = "Koordinat GPS belum dibaca";
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // Mengambil session username dari SharedPreferences
  void _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
    });
  }

  // ==========================================
  // 📍 LBS: Mengambil Lokasi GPS Pengguna
  // ==========================================
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    setState(() {
      _isLocating = true;
      _locationText = "Mengecek perizinan GPS...";
    });

    try {
      // 1. Periksa apakah layanan GPS di HP aktif
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationText = "GPS HP tidak aktif. Silakan aktifkan GPS Anda.";
          _isLocating = false;
        });
        return;
      }

      // 2. Periksa status izin akses lokasi aplikasi
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Jika belum ada izin, minta izin ke pengguna
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationText = "Akses lokasi ditolak oleh pengguna.";
            _isLocating = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Jika izin diblokir secara permanen
        setState(() {
          _locationText = "Akses lokasi ditolak permanen. Aktifkan di pengaturan.";
          _isLocating = false;
        });
        return;
      }

      // 3. Mengambil koordinat GPS aktif saat ini
      setState(() {
        _locationText = "Sedang mengunci koordinat satelit...";
      });
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high, // Akurasi tinggi
      );

      setState(() {
        _locationText = "Latitude: ${position.latitude}\nLongitude: ${position.longitude}";
        _isLocating = false;
      });

      Get.snackbar(
        'Sukses LBS', 
        'Lokasi berhasil didapatkan secara akurat!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade800,
        colorText: Colors.white,
      );
    } catch (e) {
      setState(() {
        _locationText = "Gagal mengambil koordinat: $e";
        _isLocating = false;
      });
    }
  }

  // Melakukan logout (hapus session SharedPreferences)
  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    
    // Keluar ke halaman login dan bersihkan navigasi
    Get.offAllNamed('/login');
    Get.snackbar(
      'Logout Berhasil', 
      'Sampai jumpa kembali!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar Profil
            const CircleAvatar(
              radius: 55,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 55, color: Colors.white),
            ),
            const SizedBox(height: 20),
            
            // Username yang sedang login
            Text(
              'Username: $_username', 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 10),
            
            // Deskripsi Diri (Bebas)
            Text(
              'Mahasiswa IT Universitas - Calon Developer Mobile Berbakat.', 
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            
            // ========================================================
            // 📍 TAMPILAN LBS: Kumpulan Info GPS
            // ========================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        '📍 Lokasi GPS Saya (LBS Bonus)', 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _locationText, 
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontFamily: 'monospace', color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _isLocating ? null : _getCurrentLocation,
                    icon: _isLocating 
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.gps_fixed, size: 18),
                    label: const Text("Ambil Koordinasi GPS"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Tombol Logout
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Keluar dari Akun', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, 
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
