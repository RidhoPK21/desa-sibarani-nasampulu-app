import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/berita.dart';

final beritaProvider = AsyncNotifierProvider<BeritaNotifier, List<Berita>>(() {
  return BeritaNotifier();
});

class BeritaNotifier extends AsyncNotifier<List<Berita>> {
  @override
  Future<List<Berita>> build() async {
    return _fetchData();
  }

  Future<List<Berita>> _fetchData() async {
    try {
      // Menggunakan base URL dari ApiClient (port 9000 /api/info)
      final response = await api.get('/berita');
      
      if (response.statusCode == 200) {
        // Handle wrapper {"status": "success", "data": [...]}
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Berita.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Terjadi kesalahan jaringan');
    }
  }

  Future<void> fetchBerita() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchData());
  }

  // Admin: Create Berita
  Future<void> createBerita(FormData formData) async {
    try {
      final response = await api.post('/berita', data: formData);
      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchBerita();
      } else {
        throw Exception('Gagal membuat berita');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Admin: Update Berita
  Future<void> updateBerita(String id, FormData formData) async {
    try {
      // Laravel Multipart sering butuh method POST dengan _method=PUT
      formData.fields.add(MapEntry('_method', 'PUT'));
      final response = await api.post('/berita/$id', data: formData);
      if (response.statusCode == 200) {
        await fetchBerita();
      } else {
        throw Exception('Gagal memperbarui berita');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Admin: Delete Berita
  Future<void> deleteBerita(String id) async {
    try {
      final response = await api.delete('/berita/$id');
      if (response.statusCode == 200) {
        await fetchBerita();
      } else {
        throw Exception('Gagal menghapus berita');
      }
    } catch (e) {
      rethrow;
    }
  }
}
