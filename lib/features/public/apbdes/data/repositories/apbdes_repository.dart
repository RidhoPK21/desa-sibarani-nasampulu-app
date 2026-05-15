import 'package:dio/dio.dart';
import '../../../../../core/network/api_client.dart';
import '../models/apbdes_model.dart';

class ApbdesRepository {
  Future<List<ApbdesModel>> getApbdesList() async {
    try {
      // Menembak endpoint microservices kalian
      final response = await api.get('/info/apbdes');

      final data = response.data['data'];
      if (data is List) {
        return data.map((json) => ApbdesModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Gagal mengambil data APBDes: ${e.toString()}');
    }
  }

  Future<ApbdesModel> getApbdesDetail(String id) async {
    try {
      final response = await api.get('/info/apbdes/$id');
      return ApbdesModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Gagal mengambil detail APBDes: ${e.toString()}');
    }
  }
}