import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

// Class untuk menampung semua data Beranda
class BerandaData {
  final List<dynamic> banners;
  final String sambutan;
  final List<dynamic> berita;
  final Map<String, int> statistik;

  BerandaData({required this.banners, required this.sambutan, required this.berita, required this.statistik});
}

// Helper untuk format URL Gambar Localhost -> Emulator/Web
String formatImageUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  if (url.startsWith('http') && !url.contains('localhost') && !url.contains('127.0.0.1')) return url;
  String host = kIsWeb ? "localhost" : "10.0.2.2";
  if (url.contains('localhost') || url.contains('127.0.0.1')) {
    try { return "http://$host:9000${Uri.parse(url).path}"; } catch (_) {}
  }
  return "http://$host:9000/${url.startsWith('/') ? url.substring(1) : url}";
}

final berandaProvider = FutureProvider<BerandaData>((ref) async {
  try {
    // Jalankan 4 Request bersamaan (Paralel)
    final responses = await Future.wait([
      api.get('/content/banner').catchError((_) => Response(requestOptions: RequestOptions(path: ''), data: {'data': []})),
      api.get('/info/profil/kata-sambutan').catchError((_) => Response(requestOptions: RequestOptions(path: ''), data: {'data': []})),
      api.get('/info/berita').catchError((_) => Response(requestOptions: RequestOptions(path: ''), data: {'data': []})),
      api.get('/statistic/dusun').catchError((_) => Response(requestOptions: RequestOptions(path: ''), data: {'data': []})),
    ]);

    // 1. Olah Banner (Filter shown == 1/true, urutkan)
    List banners = responses[0].data['data'] ?? [];
    banners = banners.where((b) => b['shown'] == 1 || b['shown'] == true).toList();
    banners.sort((a, b) => (a['urutan'] ?? 0).compareTo(b['urutan'] ?? 0));

    // 2. Olah Kata Sambutan
    String sambutan = '';
    var dataSambutan = responses[1].data['data'];
    if (dataSambutan != null && dataSambutan is List && dataSambutan.isNotEmpty) {
      sambutan = dataSambutan[0]['kata'] ?? '';
    }

    // 3. Olah Berita (Filter publish, urutkan terbaru, ambil 3)
    List berita = responses[2].data['data'] ?? [];
    berita = berita.where((b) => b['is_published'] == 1 || b['is_published'] == true).toList();
    berita.sort((a, b) => DateTime.parse(b['created_at'] ?? '1970-01-01').compareTo(DateTime.parse(a['created_at'] ?? '1970-01-01')));
    berita = berita.take(3).toList();

    // 4. Olah Statistik Dusun
    List dusun = responses[3].data['data'] ?? [];
    int total = 0, laki = 0, perempuan = 0;
    for (var d in dusun) {
      total += (d['total_penduduk'] as int? ?? 0);
      laki += (d['penduduk_laki'] as int? ?? 0);
      perempuan += (d['penduduk_perempuan'] as int? ?? 0);
    }

    return BerandaData(
      banners: banners,
      sambutan: sambutan,
      berita: berita,
      statistik: {'total': total, 'laki': laki, 'perempuan': perempuan},
    );
  } catch (e) {
    throw Exception('Gagal memuat data Beranda: $e');
  }
});