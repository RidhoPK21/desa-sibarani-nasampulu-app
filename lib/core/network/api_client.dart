import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;
  final storage = const FlutterSecureStorage();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    String baseUrl;

    // 🔥 Menggunakan port 9000 sesuai instruksi terbaru (API Gateway)
    if (kIsWeb) {
      baseUrl = 'http://127.0.0.1:9000/api/info'; 
    } else if (Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:9000/api/info'; 
    } else {
      baseUrl = 'http://127.0.0.1:9000/api/info';
    }

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Logika tambahan jika diperlukan untuk handle wrapper response global
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        // Centralized error handling
        return handler.next(e);
      },
    ));
  }
}

final api = ApiClient().dio;
