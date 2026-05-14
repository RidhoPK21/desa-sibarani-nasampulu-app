import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class GaleriModel {
  final String id;
  final String judul;
  final String gambarUrl;
  final DateTime? tanggal;
  final String kategori;

  GaleriModel({
    required this.id,
    required this.judul,
    required this.gambarUrl,
    required this.tanggal,
    required this.kategori,
  });

  // Fungsi sakti untuk menjinakkan URL localhost
  static String formatUrl(String? url) {
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

  // Format tanggal ke Bahasa Indonesia (Contoh: 12 Mei 2026)
  String get tanggalFormat {
    if (tanggal == null) return '-';
    return DateFormat('dd MMMM yyyy', 'id_ID').format(tanggal!);
  }
}