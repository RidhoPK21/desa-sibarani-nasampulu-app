import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
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
      statusKoneksi = "Loading... Menghubungi Backend 10.0.2.2:9000...";
    });

    try {
      // 🔥 Menembak API Gateway Nginx kalian untuk mengambil daftar berita
      final response = await api.get('/info/berita');

      setState(() {
        // Jika sukses, kita tampilkan status dan sedikit potongan datanya
        statusKoneksi = "✅ BERHASIL TERHUBUNG!\n\nStatus Code: ${response.statusCode}\nData: ${response.data.toString().substring(0, 100)}...";
      });
    } on DioException catch (e) {
      setState(() {
        // Jika gagal (Nginx mati atau salah IP), tampilkan errornya
        statusKoneksi = "❌ GAGAL TERHUBUNG!\n\nError: ${e.message}";
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