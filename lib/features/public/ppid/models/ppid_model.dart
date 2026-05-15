import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class PpidModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String documentUrl;
  final String? createdAt;

  PpidModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.documentUrl,
    this.createdAt,
  });

  factory PpidModel.fromJson(Map<String, dynamic> json) {
    // 1. Penjinak URL Dokumen (Tetap dipertahankan agar aman di Emulator/Web)
    String formatUrl(String? url) {
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

    // 2. Format Tanggal (Mengikuti kolom 'tanggal_upload' dari Laravel)
    String tgl = '';
    if (json['tanggal_upload'] != null) {
      try {
        tgl = DateFormat('dd MMM yyyy').format(DateTime.parse(json['tanggal_upload']).toLocal());
      } catch (_) {}
    }

    return PpidModel(
      id: json['id']?.toString() ?? '',
      //  DISESUAIKAN: Laravel mengirim 'nama_ppid', bukan 'judul'
      title: json['nama_ppid'] ?? 'Dokumen Tanpa Judul',
      //  DISESUAIKAN: Laravel mengirim 'deskripsi_ppid'
      description: json['deskripsi_ppid'] ?? '',
      //  DISESUAIKAN: Laravel mengirim 'jenis_ppid'
      category: json['jenis_ppid'] ?? 'Umum',
      //  DISESUAIKAN: Laravel Controller sudah membuat 'file_url' secara otomatis
      documentUrl: formatUrl(json['file_url']),
      createdAt: tgl.isNotEmpty ? tgl : null,
    );
  }
}