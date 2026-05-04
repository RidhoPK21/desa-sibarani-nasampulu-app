import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/dusun_model.dart';

// Provider untuk mengambil daftar dusun
final dusunListProvider = AsyncNotifierProvider<DusunNotifier, List<DusunModel>>(() {
  return DusunNotifier();
});

class DusunNotifier extends AsyncNotifier<List<DusunModel>> {
  @override
  Future<List<DusunModel>> build() async {
    return _fetchDusuns();
  }

  Future<List<DusunModel>> _fetchDusuns() async {
    final response = await api.get('/statistic/dusun');
    final List data = response.data['data'] ?? [];
    return data.map((e) => DusunModel.fromJson(e)).toList();
  }

  // Refresh data secara paksa
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchDusuns());
  }

  // Tambah Dusun Baru
  Future<void> addDusun(DusunModel dusun) async {
    await api.post('/statistic/dusun', data: dusun.toJson());
    await refresh(); // Refresh list setelah menambah
  }

  // Hapus Dusun
  Future<void> deleteDusun(int id) async {
    await api.delete('/statistic/dusun/$id');
    await refresh();
  }
}
