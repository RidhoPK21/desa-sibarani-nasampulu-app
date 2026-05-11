import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:9000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:9000';
    }
    return 'http://127.0.0.1:9000';
  }

  static String get authBase => '$baseUrl/api/auth';
  static String get login => '$authBase/login';
  static String get register => '$authBase/register';
  static String get logout => '$authBase/logout';
  static String get profile => '$authBase/profile';

  static String get infoBase => '$baseUrl/api/info';
  static String get berita => '$infoBase/berita';
  static String get pengumuman => '$infoBase/pengumuman';
  static String get profil => '$infoBase/profil';
  static String get dokumen => '$infoBase/dokumen';
  static String get kegiatan => '$infoBase/kegiatan';

  static String get statisticBase => '$baseUrl/api/statistic';
  static String get idm => '$statisticBase/idm';
  static String get dusun => '$statisticBase/dusun';

  static String get contentBase => '$baseUrl/api/content';
  static String get banner => '$contentBase/banner';
  static String get galeri => kegiatan;
  static String get ppid => dokumen;
  static String get layanan => '$contentBase/layanan';

  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}
