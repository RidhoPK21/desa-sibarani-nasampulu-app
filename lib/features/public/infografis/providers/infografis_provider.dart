import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/infografis_model.dart';

final infografisProvider = FutureProvider<List<DusunStatModel>>((ref) async {
  try {
    final response = await api.get('/statistic/dusun');

    final data = response.data['data'];
    if (data is List) {
      return data.map((json) => DusunStatModel.fromJson(json)).toList();
    }
    return [];
  } catch (e) {
    throw Exception('Gagal memuat data statistik: ${e.toString()}');
  }
});