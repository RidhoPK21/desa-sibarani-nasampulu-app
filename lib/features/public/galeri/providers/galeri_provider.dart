import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/galeri_model.dart';

final galeriProvider = FutureProvider<List<GaleriModel>>((ref) async {
  try {
    // Tembak 2 API sekaligus
    final results = await Future.wait([
      api.get('/info/berita').catchError((_) => null),
      api.get('/info/kegiatan').catchError((_) => null), // Asumsi endpoint kegiatan
    ]);

    List<GaleriModel> allItems = [];

    // 1. Olah Data Berita
    if (results[0] != null && results[0].data['data'] is List) {
      for (var item in results[0].data['data']) {
        final gambar = item['gambar_url'];
        final isPublished = item['is_published'] == 1 || item['is_published'] == true;
        // Hanya ambil yang punya gambar & sudah di-publish
        if (gambar != null && gambar.toString().isNotEmpty && isPublished) {
          allItems.add(GaleriModel(
            id: 'berita-${item['id']}',
            judul: item['judul'] ?? 'Tanpa Judul',
            gambarUrl: GaleriModel.formatUrl(gambar),
            tanggal: DateTime.tryParse(item['created_at'] ?? ''),
            kategori: 'Berita',
          ));
        }
      }
    }

    // 2. Olah Data Kegiatan
    if (results[1] != null && results[1].data['data'] is List) {
      for (var item in results[1].data['data']) {
        // Fallback key gambar, disesuaikan jika kolom di Laravel bernama lain
        final gambar = item['gambar_url'] ?? item['gambar'] ?? item['foto_url'];
        if (gambar != null && gambar.toString().isNotEmpty) {
          allItems.add(GaleriModel(
            id: 'kegiatan-${item['id']}',
            judul: item['judul'] ?? item['nama_kegiatan'] ?? 'Tanpa Judul',
            gambarUrl: GaleriModel.formatUrl(gambar),
            tanggal: DateTime.tryParse(item['created_at'] ?? item['tanggal_kegiatan'] ?? ''),
            kategori: 'Kegiatan',
          ));
        }
      }
    }

    // 3. Urutkan berdasarkan tanggal terbaru (Descending)
    allItems.sort((a, b) {
      if (a.tanggal == null && b.tanggal == null) return 0;
      if (a.tanggal == null) return 1;
      if (b.tanggal == null) return -1;
      return b.tanggal!.compareTo(a.tanggal!);
    });

    return allItems;
  } catch (e) {
    throw Exception('Gagal memuat galeri: $e');
  }
});