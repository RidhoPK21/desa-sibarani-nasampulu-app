import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/berita_provider.dart';

class BeritaDetailScreen extends ConsumerWidget {
  final String id;

  const BeritaDetailScreen({super.key, required this.id});

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

  // Membersihkan tag HTML dari backend
  String _stripHtmlIfNeeded(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(beritaDetailProvider(id));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4EA674),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Detail Berita', style: TextStyle(color: Colors.white, fontSize: 16)),
        centerTitle: true,
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF4EA674))),
        error: (e, _) => Center(child: Text('Gagal memuat detail: $e')),
        data: (berita) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Gambar Full Width
                if (berita.gambarUrl != null && berita.gambarUrl!.isNotEmpty)
                  Image.network(
                    _formatImageUrl(berita.gambarUrl),
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(height: 250, color: const Color(0xFFE8F5E9), child: const Icon(Icons.newspaper, size: 60, color: Color(0xFF4EA674))),
                  )
                else
                  Container(height: 250, color: const Color(0xFFE8F5E9), child: const Center(child: Icon(Icons.newspaper, size: 60, color: Color(0xFF4EA674)))),

                // 2. Konten Teks
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Kategori & Tanggal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
                            child: const Text('Berita Desa', style: TextStyle(color: Color(0xFF4EA674), fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(DateFormat('dd MMM yyyy').format(berita.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Judul
                      Text(
                        berita.judul,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1F2937), height: 1.3),
                      ),
                      const SizedBox(height: 24),

                      const Divider(color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 24),

                      // Isi Berita
                      Text(
                        _stripHtmlIfNeeded(berita.konten),
                        style: const TextStyle(fontSize: 16, color: Color(0xFF4B5563), height: 1.8),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}