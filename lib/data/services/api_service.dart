import 'package:dio/dio.dart';

// --- PERBAIKAN IMPORT PATH ---
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/apbdes_model.dart';
// -----------------------------

class ApiService {
  final Dio _dio = api;

  // --- Generic Methods untuk modul lain (misal IDM) ---
  Future<Response> get(String url, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(url, queryParameters: queryParameters);
  }

  Future<Response> post(String url, {dynamic data}) {
    return _dio.post(url, data: data);
  }

  Future<Response> put(String url, {dynamic data}) {
    return _dio.put(url, data: data);
  }

  Future<Response> delete(String url) {
    return _dio.delete(url);
  }
  // ----------------------------------------------------

  // APBDES
  Future<List<ApbdesModel>> fetchApbdes() async {
    final response = await _dio.get(ApiConstants.apbdes);
    final List data = response.data['data'] ?? [];
    return data.map((e) => ApbdesModel.fromJson(e)).toList();
  }

  Future<ApbdesModel> createApbdes(ApbdesModel model) async {
    final response = await _dio.post(
      ApiConstants.apbdes,
      data: model.toJson(),
    );
    return ApbdesModel.fromJson(response.data['data']);
  }

  Future<ApbdesModel> updateApbdes(int id, ApbdesModel model) async {
    // Gunakan PUT bawaan dio:
    final response = await _dio.put(
      '${ApiConstants.apbdes}/$id',
      data: model.toJson(),
    );
    return ApbdesModel.fromJson(response.data['data']);
  }

  Future<void> deleteApbdes(int id) async {
    await _dio.delete('${ApiConstants.apbdes}/$id');
  }
}