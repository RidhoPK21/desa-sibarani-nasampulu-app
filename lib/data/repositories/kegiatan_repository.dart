import '../../core/constants/api_constants.dart';
import '../models/kegiatan_model.dart';
import '../services/api_service.dart';

class KegiatanRepository {
  final ApiService _apiService;

  KegiatanRepository(this._apiService);

  Future<List<KegiatanModel>> getKegiatanList() async {
    final response = await _apiService.get(ApiConstants.kegiatan);
    final list = _extractList(response.data);
    return list
        .whereType<Map>()
        .map((item) => KegiatanModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<KegiatanModel> getKegiatanById(String id) async {
    final response = await _apiService.get('${ApiConstants.kegiatan}/$id');
    return KegiatanModel.fromJson(response.data);
  }

  Future<KegiatanModel> createKegiatan(KegiatanModel kegiatan) async {
    final response = await _apiService.post(ApiConstants.kegiatan, data: kegiatan.toJson());
    return KegiatanModel.fromJson(response.data);
  }

  Future<KegiatanModel> updateKegiatan(String id, KegiatanModel kegiatan) async {
    final response = await _apiService.put('${ApiConstants.kegiatan}/$id', data: kegiatan.toJson());
    return KegiatanModel.fromJson(response.data);
  }

  Future<void> deleteKegiatan(String id) async {
    await _apiService.delete('${ApiConstants.kegiatan}/$id');
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data.containsKey('data')) {
      final nested = data['data'];
      if (nested is List) return nested;
    }
    return [];
  }
}