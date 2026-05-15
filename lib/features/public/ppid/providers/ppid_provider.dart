import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/ppid_model.dart';

final ppidProvider = FutureProvider<List<PpidModel>>((ref) async {
  try {
    final response = await api.get('/info/dokumen'); // Sesuaikan endpoint Laravel-mu

    final data = response.data['data'];
    if (data is List) {
      return data.map((json) => PpidModel.fromJson(json)).toList();
    }
    return [];
  } catch (e) {
    throw Exception('Gagal memuat dokumen PPID: $e');
  }
});