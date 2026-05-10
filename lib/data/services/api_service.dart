// lib/data/services/api_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';

class ApiService {
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: ApiConstants.defaultHeaders,
      ),
    );

    // Interceptor — auto-inject token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  // ─── Generic GET ─────────────────────────────────────────────────
  Future<Response> get(String url, {Map<String, dynamic>? queryParams}) async {
    return await _dio.get(url, queryParameters: queryParams);
  }

  // ─── Generic POST ────────────────────────────────────────────────
  Future<Response> post(String url, {dynamic data}) async {
    return await _dio.post(
      url,
      data: data,
      options: data is FormData
          ? Options(headers: {'Content-Type': 'multipart/form-data'})
          : null,
    );
  }

  // ─── Generic PUT ─────────────────────────────────────────────────
  Future<Response> put(String url, {dynamic data}) async {
    return await _dio.put(
      url,
      data: data,
      options: data is FormData
          ? Options(headers: {'Content-Type': 'multipart/form-data'})
          : null,
    );
  }

  // ─── Generic DELETE ──────────────────────────────────────────────
  Future<Response> delete(String url) async {
    return await _dio.delete(url);
  }

  // ─── Save Token ──────────────────────────────────────────────────
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // ─── Clear Token ─────────────────────────────────────────────────
  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // ─── Get Token ───────────────────────────────────────────────────
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}
