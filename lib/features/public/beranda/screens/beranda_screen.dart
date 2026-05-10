import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_client.dart';

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
      final response = await api.get('/info/berita');
      final responseText = response.data.toString();
      final previewText = responseText.length > 100
          ? '${responseText.substring(0, 100)}...'
          : responseText;

      // Ambil teks balasan API
      String responseText = response.data.toString();

      // 🛡️ Mencegah RangeError jika data dari Nginx kurang dari 100 huruf
      String displayData = responseText.length > 100
          ? "${responseText.substring(0, 100)}..."
          : responseText;

      setState(() {
        statusKoneksi = "✅ BERHASIL TERHUBUNG!\n\nStatus Code: ${response.statusCode}\nData: $displayData";
      });
    } on DioException catch (e) {
      setState(() {
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: FilledButton.icon(
              onPressed: () => context.go('/admin'),
              icon: const Icon(Icons.admin_panel_settings_rounded),
              label: const Text('Masuk Admin'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF123524),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          const Icon(Icons.api, size: 80, color: Color(0xFF4EA674)),
          const SizedBox(height: 20),
          Text(
            statusKoneksi,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton.icon(
            const SizedBox(height: 30),

            // --- TOMBOL 1: UJI API ---
            ElevatedButton.icon(
              onPressed: _testKoneksiBackend,
              icon: const Icon(Icons.network_ping),
              label: const Text("Uji Koneksi Backend"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4EA674),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),

            const SizedBox(height: 16), // Jarak antar tombol

            // --- TOMBOL 2 (BARU): CEK HALAMAN IDM ---
            ElevatedButton.icon(
              onPressed: () {
                // Berpindah ke rute '/idm' yang sudah kita daftarkan di app_router.dart
                context.go('/idm');
              },
              icon: const Icon(Icons.pie_chart),
              label: const Text("Lihat Halaman Statistik IDM"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Warna biru agar beda
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),

            const SizedBox(height: 40), // Jarak pemisah ke tombol admin

            // --- TOMBOL 3: JALAN TIKUS MENUJU ADMIN ---
            TextButton.icon(
              onPressed: () {
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
