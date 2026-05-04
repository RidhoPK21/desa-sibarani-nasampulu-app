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
      statusKoneksi = "Loading... Menghubungi Backend 10.0.2.2:9000...";
    });

    try {
      final response = await api.get('/info/berita');
      final responseText = response.data.toString();
      final previewText = responseText.length > 100
          ? '${responseText.substring(0, 100)}...'
          : responseText;

      setState(() {
        statusKoneksi =
            "BERHASIL TERHUBUNG!\n\nStatus Code: ${response.statusCode}\nData: $previewText";
      });
    } on DioException catch (e) {
      setState(() {
        statusKoneksi = "GAGAL TERHUBUNG!\n\nError: ${e.message}";
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
          ),
        ],
      ),
    );
  }
}
