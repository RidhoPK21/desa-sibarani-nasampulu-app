// lib/core/network/api_client.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;
  final storage = const FlutterSecureStorage();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    String baseUrl;

    if (kIsWeb) {
      baseUrl = 'http://localhost:9000/api';
    } else if (Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:9000/api';
    } else {
      baseUrl = 'http://127.0.0.1:9000/api';
    }

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // flutter_secure_storage tidak support web
          // jadi skip token di web
          if (!kIsWeb) {
            String? token = await storage.read(key: 'auth_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Log error untuk debugging
          debugPrint('API Error: ${e.message}');
          debugPrint('URL: ${e.requestOptions.uri}');
          return handler.next(e);
        },
      ),
    );
  }
}

// Singleton instance - pakai ini di seluruh aplikasi
final apiClient = ApiClient();

// Shortcut langsung ke dio
Dio get api => ApiClient().dio;