import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart'; // 🔥 TAMBAHKAN INI UNTUK MENDETEKSI WEB

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;
  final storage = const FlutterSecureStorage();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    String baseUrl;

    // 🔥 LOGIKA BARU: Cek apakah jalan di Web, Android, atau iOS
    if (kIsWeb) {
      baseUrl = 'http://127.0.0.1:9000/api'; // Chrome / Web
    } else if (Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:9000/api';  // Emulator Android
    } else {
      baseUrl = 'http://127.0.0.1:9000/api'; // iOS / Real Device
    }

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
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
    ));
  }
}

final api = ApiClient().dio;