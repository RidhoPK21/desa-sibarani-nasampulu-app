import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/berita_model.dart';

final beritaProvider = AsyncNotifierProvider<BeritaNotifier, List<BeritaModel>>(() {
  return BeritaNotifier();
});

class BeritaNotifier extends AsyncNotifier<List<BeritaModel>> {
  @override
  Future<List<BeritaModel>> build() async {
    return _fetchData();
  }

  Future<List<BeritaModel>> _fetchData() async {
    try {
      // 🔥 Menembak endpoint Publik
      final response = await api.get('/info/berita');

      final data = response.data['data'];
      if (data is List) {
        return data
            .map((json) => BeritaModel.fromJson(json))
        // Pastikan hanya berita yang ter-publish yang tampil di publik
            .where((b) => b.isPublished)
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Gagal mengambil data berita: ${e.toString()}');
    }
  }

  Future<void> fetchBerita() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchData());
  }
}

// Provider untuk mengambil 1 detail berita
final beritaDetailProvider = FutureProvider.family<BeritaModel, String>((ref, id) async {
  final list = await ref.read(beritaProvider.future);
  return list.firstWhere((e) => e.id == id);
});