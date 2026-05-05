import 'package:dio/dio.dart';
import '../core/network/api_client.dart'; // sesuaikan path
import '../data/models/apbdes_model.dart';

class ApiService {
  final Dio _dio = api; // pakai 'api' dari api_client.dart yang sudah ada

  // ── APBDES ────────────────────────────────────────────────
  Future<List<ApbdesModel>> fetchApbdes() async {
    final response = await _dio.get('/info/apbdes');
    final List data = response.data['data'] ?? [];
    return data.map((e) => ApbdesModel.fromJson(e)).toList();
  }

  Future<ApbdesModel> createApbdes(ApbdesModel model) async {
    final response = await _dio.post(
      '/info/apbdes',
      data: model.toJson(),
    );
    return ApbdesModel.fromJson(response.data['data']);
  }

  Future<ApbdesModel> updateApbdes(int id, ApbdesModel model) async {
    final payload = model.toJson();
    payload['_method'] = 'PUT';
    final response = await _dio.post(
      '/info/apbdes/$id',
      data: payload,
    );
    return ApbdesModel.fromJson(response.data['data']);
  }

  Future<void> deleteApbdes(int id) async {
    await _dio.delete('/info/apbdes/$id');
  }
}
