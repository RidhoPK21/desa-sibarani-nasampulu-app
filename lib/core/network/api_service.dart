import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String infoServiceUrl = 'http://localhost:8001/api';

  static Future<List<dynamic>> getBerita() async {
    try {
      final response = await http.get(
        Uri.parse('$infoServiceUrl/berita'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception('Gagal ambil data berita');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}