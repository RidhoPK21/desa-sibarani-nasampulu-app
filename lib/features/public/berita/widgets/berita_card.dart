import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/berita_model.dart';

class BeritaCard extends StatelessWidget {
  final BeritaModel berita;
  final VoidCallback onTap;

  const BeritaCard({super.key, required this.berita, required this.onTap});

  String _formatImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http') && !url.contains('localhost') && !url.contains('127.0.0.1')) return url;
    String host = kIsWeb ? "localhost" : "10.0.2.2";
    if (url.contains('localhost') || url.contains('127.0.0.1')) {
      try { return "http://$host:9000${Uri.parse(url).path}"; } catch (_) {}
    }
    if (!url.startsWith('storage/') && !url.startsWith('/storage/')) {
      return "http://$host:9000/storage/$url";
    }
    return "http://$host:9000/${url.startsWith('/') ? url.substring(1) : url}";
  }

  // Fungsi untuk menghapus tag HTML dari teks (meniru React)
  String _stripHtmlIfNeeded(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Header
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: berita.gambarUrl != null && berita.gambarUrl!.isNotEmpty
                    ? Image.network(
                  _formatImageUrl(berita.gambarUrl),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallbackImage(),
                )
                    : _fallbackImage(),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tanggal & Jam
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF4EA674)),
                        const SizedBox(width: 6),
                        Text(DateFormat('dd MMM yyyy').format(berita.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 16),
                        const Icon(Icons.access_time, size: 14, color: Color(0xFF4EA674)),
                        const SizedBox(width: 6),
                        Text(DateFormat('HH:mm WIB').format(berita.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Judul
                    Text(
                      berita.judul,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1F2937), height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Cuplikan Konten (Di-strip HTML-nya)
                    Text(
                      _stripHtmlIfNeeded(berita.konten),
                      style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    // Tombol Baca
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("Baca Selengkapnya", style: TextStyle(color: Color(0xFF4EA674), fontSize: 13, fontWeight: FontWeight.bold)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, color: Color(0xFF4EA674), size: 16),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      height: 200,
      width: double.infinity,
      color: const Color(0xFFE8F5E9),
      child: const Center(child: Icon(Icons.newspaper_rounded, color: Color(0xFF4EA674), size: 48)),
    );
  }
}