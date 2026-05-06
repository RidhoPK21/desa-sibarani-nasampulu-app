import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 🔥 Wajib di-import untuk mendeteksi kIsWeb
import 'package:desa_sibarani_app/features/public/apbdes/data/models/apbdes_model.dart';

class ApbdesCard extends StatelessWidget {
  final ApbdesModel apbdes;
  final VoidCallback onTap;

  const ApbdesCard({
    super.key,
    required this.apbdes,
    required this.onTap,
  });

  // 🔥 Fungsi Penjinak URL Gambar (Mendukung Web & Emulator Android)
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

  // Fungsi fallback jika gambar kosong atau gagal dimuat
  Widget _buildImageFallback() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        gradient: LinearGradient(
          colors: [Colors.green.shade800, Colors.green.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.account_balance_wallet, color: Colors.white54, size: 48),
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
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // 🔥 Memanggil Network Image dengan URL yang sudah dijinakkan
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: apbdes.imageUrl.isNotEmpty
                      ? Image.network(
                    _formatImageUrl(apbdes.imageUrl),
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildImageFallback(),
                  )
                      : _buildImageFallback(),
                ),
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 12,
                  child: Text(
                    apbdes.tahun,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 8,
                  right: 12,
                  child: Row(
                    children: [
                      Text(
                        'View Details ',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Icon(Icons.arrow_forward, color: Colors.white70, size: 12),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(apbdes.tanggal,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 12),
                  const Icon(Icons.access_time, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(apbdes.jam,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 12),
                  const Icon(Icons.location_on, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  // 🔥 Saya tambahkan Expanded agar teks lokasi panjang tidak membuat layar error overflow
                  Expanded(
                    child: Text(
                      apbdes.lokasi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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