// lib/features/public/apbdes/presentation/widgets/apbdes_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Wajib di-import untuk mendeteksi kIsWeb
import 'package:desa_sibarani_app/features/public/apbdes/data/models/apbdes_model.dart';

class ApbdesCard extends StatelessWidget {
  final ApbdesModel apbdes;
  final VoidCallback onTap;

  const ApbdesCard({
    super.key,
    required this.apbdes,
    required this.onTap,
  });

  // Fungsi Penjinak URL Gambar (Mendukung Web & Emulator Android)
  String _formatImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http') && !url.contains('localhost') && !url.contains('127.0.0.1')) return url;

    // Jika Web pakai localhost, jika Android Emulator pakai 10.0.2.2
    String host = kIsWeb ? "localhost" : "10.0.2.2";

    if (url.contains('localhost') || url.contains('127.0.0.1')) {
      try { return "http://$host:9000${Uri.parse(url).path}"; } catch (_) {}
    }
    if (!url.startsWith('storage/') && !url.startsWith('/storage/')) {
      return "http://$host:9000/storage/$url";
    }
    return "http://$host:9000/${url.startsWith('/') ? url.substring(1) : url}";
  }

  // 🔥 Taktik Intelijen: Fallback warna diubah ke Emerald/Teal
  Widget _buildImageFallback() {
    return Container(
      height: 160, // Sedikit ditinggikan agar lebih proporsional
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        gradient: LinearGradient(
          colors: [Color(0xFF57A677), Color(0xFF4EA674)], // Gradasi Emerald
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.account_balance_wallet, color: Colors.white54, size: 56),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // 🔥 Dibuat lebih membulat (16)
          border: Border.all(color: Colors.grey.shade100), // Border halus
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), // 🔥 Shadow lebih lembut
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Memanggil Network Image dengan URL yang sudah dijinakkan
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: apbdes.imageUrl.isNotEmpty
                      ? Image.network(
                    _formatImageUrl(apbdes.imageUrl),
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildImageFallback(),
                  )
                      : _buildImageFallback(),
                ),
                // Overlay Gelap agar teks tahun terbaca jelas
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 16,
                  child: Text(
                    apbdes.tahun,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 14,
                  right: 16,
                  child: Row(
                    children: [
                      Text(
                        'Lihat Rincian ',
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 12),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(apbdes.tanggal,
                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                  const Spacer(), // 🔥 Pakai Spacer agar teks lokasi rata kanan
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      apbdes.lokasi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}