import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart'; // 🔥 Wajib untuk tombol admin
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
      // 🔥 Menembak API Gateway Nginx kalian untuk mengambil daftar berita
      final response = await api.get('/info/berita');

      // Ambil teks balasan API
      String responseText = response.data.toString();

      // 🛡️ Cek: Jika lebih dari 100 huruf, potong. Jika kurang, tampilkan apa adanya (Mencegah RangeError)
      String displayData = responseText.length > 100
          ? "${responseText.substring(0, 100)}..."
          : responseText;

      setState(() {
        // Jika sukses, tampilkan status dan datanya
        statusKoneksi = "✅ BERHASIL TERHUBUNG!\n\nStatus Code: ${response.statusCode}\nData: $displayData";
      });
    } on DioException catch (e) {
      setState(() {
        // Jika gagal, berikan pesan spesifik
        if (e.response?.statusCode == 500) {
          statusKoneksi = "❌ GAGAL: Server backend sedang bermasalah (Error 500). Cek log Laravel!";
        } else {
          statusKoneksi = "❌ GAGAL TERHUBUNG!\n\nError: ${e.message}";
        }
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

            // --- TEKS STATUS KONEKSI ---
            Text(
              statusKoneksi,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // --- TOMBOL 1: UJI API ---
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

            const SizedBox(height: 40), // Jarak pemisah

            // --- TOMBOL 2: JALAN TIKUS MENUJU ADMIN ---
            TextButton.icon(
              onPressed: () {
                // Saat ditekan, GoRouter akan membawa kita ke layar simulasi login rahasia
                context.go('/login-rahasia');
              },
              icon: const Icon(Icons.sensor_door, color: Colors.grey),
              label: const Text(
                  "Ke Pintu Rahasia Admin",
                  style: TextStyle(color: Colors.grey)
              ),
            ),
          ],
        ),
      ),
    );
  }
}