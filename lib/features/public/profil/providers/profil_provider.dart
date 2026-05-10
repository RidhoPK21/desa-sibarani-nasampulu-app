import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/profil_model.dart';

final profilProvider = FutureProvider<ProfilData>((ref) async {
  try {
    // Tembak 2 API secara bersamaan
    final results = await Future.wait([
      api.get('/info/profil/visi-misi').catchError((_) => null),
      api.get('/info/profil/perangkat-desa').catchError((_) => null),
    ]);

    // 1. Olah Visi Misi
    VisiMisiModel visiMisi = VisiMisiModel(visi: 'Memuat...', misi: 'Memuat...');
    if (results[0] != null && results[0].data['data'] is List && results[0].data['data'].isNotEmpty) {
      visiMisi = VisiMisiModel.fromJson(results[0].data['data'][0]);
    }

    // 2. Olah Perangkat Desa
    List<PerangkatDesaModel> perangkat = [];
    if (results[1] != null && results[1].data['data'] is List) {
      perangkat = (results[1].data['data'] as List)
          .map((e) => PerangkatDesaModel.fromJson(e))
          .toList();
    }

    return ProfilData(visiMisi: visiMisi, perangkatList: perangkat);
  } catch (e) {
    throw Exception('Gagal memuat data profil: $e');
  }
});