import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import '../../../../core/network/api_client.dart'; // Sesuaikan path jika perlu

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  String statusKoneksi = "Tekan tombol untuk uji API ke Laravel";

  void _testKoneksiBackend() async {
    setState(() {
      statusKoneksi = "Loading... Menghubungi Backend...";
    });

    try {
      // 🔥 Menembak API Gateway Nginx/Laravel untuk mengambil daftar berita
      final response = await api.get('/info/berita');

      setState(() {
        // Jika sukses, kita tampilkan status dan sedikit potongan datanya
        String rawData = response.data.toString();
        
        // Perbaikan RangeError: Cek panjang string sebelum melakukan substring
        String previewData = rawData.length > 100 
            ? "${rawData.substring(0, 100)}..." 
            : rawData;

        statusKoneksi = "✅ BERHASIL TERHUBUNG!\n\nStatus Code: ${response.statusCode}\nData: $previewData";
      });
    } on DioException catch (e) {
      setState(() {
        // Penanganan khusus untuk CORS Error di Flutter Web
        if (kIsWeb && e.message != null && e.message!.contains('XMLHttpRequest')) {
          statusKoneksi = "❌ GAGAL (CORS ERROR)\n\nBrowser memblokir akses. Pastikan Laravel sudah dikonfigurasi 'allowed_origins' => ['*'] di config/cors.php";
        } else {
          statusKoneksi = "❌ GAGAL TERHUBUNG!\n\nError: ${e.message}";
        }
      });
    } catch (e) {
      setState(() {
        statusKoneksi = "❌ TERJADI KESALAHAN!\n\nError: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.api, size: 80, color: Color(0xFF4EA674)),
            const SizedBox(height: 20),
            Text(
              statusKoneksi,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _testKoneksiBackend,
              icon: const Icon(Icons.network_ping),
              label: const Text("Uji Koneksi Backend"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4EA674),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
