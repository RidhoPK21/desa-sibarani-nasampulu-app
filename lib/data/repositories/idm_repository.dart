import '../../core/constants/api_constants.dart';
import '../models/idm_model.dart';
import '../services/api_service.dart';

class IdmRepository {
  final ApiService _apiService;

  IdmRepository(this._apiService);

  Future<IdmModel> getIdmTerkini() async {
    final history = await getIdmHistory();
    if (history.isEmpty) {
      throw Exception('Data IDM belum tersedia');
    }
    return history.first;
  }

  Future<List<IdmModel>> getIdmHistory() async {
    final response = await _apiService.get(ApiConstants.idm);
    final list = _extractList(response.data);
    final history = list
        .whereType<Map>()
        .map((item) => IdmModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    history.sort((a, b) => b.tahun.compareTo(a.tahun));
    return history;
  }

  Future<IdmModel?> getIdmByTahun(int tahun) async {
    final history = await getIdmHistory();
    for (final idm in history) {
      if (idm.tahun == tahun) return idm;
    }
    return null;
  }

  Future<PendudukStatsModel> getPendudukStats() async {
    final dusuns = await _getDusuns();
    final lakiLaki = dusuns.fold<int>(
      0,
      (sum, item) => sum + _asInt(item['penduduk_laki']),
    );
    final perempuan = dusuns.fold<int>(
      0,
      (sum, item) => sum + _asInt(item['penduduk_perempuan']),
    );
    final total = lakiLaki + perempuan;

    return PendudukStatsModel(
      totalPenduduk: total,
      lakiLaki: lakiLaki,
      perempuan: perempuan,
      kepalaKeluarga: dusuns.length,
      pendudukMiskin: 0,
      rasioJenisKelamin: perempuan == 0 ? 0 : (lakiLaki / perempuan) * 100,
    );
  }

  Future<List<KelompokUmurModel>> getKelompokUmur() async {
    final items = await _aggregateDusunRelation(
      relationKey: 'usias',
      labelKey: 'kelompok_usia',
    );
    return items.map(KelompokUmurModel.fromJson).toList();
  }

  Future<List<PendidikanModel>> getPendidikan() async {
    final items = await _aggregateDusunRelation(
      relationKey: 'pendidikans',
      labelKey: 'tingkat_pendidikan',
    );
    return items.map(PendidikanModel.fromJson).toList();
  }

  Future<List<PekerjaanModel>> getPekerjaan() async {
    final items = await _aggregateDusunRelation(
      relationKey: 'pekerjaans',
      labelKey: 'jenis_pekerjaan',
    );
    return items.map(PekerjaanModel.fromJson).toList();
  }

  Future<IdmModel> createIdm({
    required int tahun,
    required double skorIdm,
    required String statusIdm,
    required double skorIks,
    required double skorIke,
    required double skorIkl,
    String? catatan,
  }) async {
    final response = await _apiService.post(
      ApiConstants.idm,
      data: _buildIdmPayload(
        tahun: tahun,
        skorIdm: skorIdm,
        statusIdm: statusIdm,
        skorIks: skorIks,
        skorIke: skorIke,
        skorIkl: skorIkl,
        catatan: catatan,
      ),
    );
    return _extractItem(response.data);
  }

  Future<IdmModel> updateIdm({
    required String id,
    required int tahun,
    required double skorIdm,
    required String statusIdm,
    required double skorIks,
    required double skorIke,
    required double skorIkl,
    String? catatan,
  }) async {
    final response = await _apiService.put(
      '${ApiConstants.idm}/$id',
      data: _buildIdmPayload(
        tahun: tahun,
        skorIdm: skorIdm,
        statusIdm: statusIdm,
        skorIks: skorIks,
        skorIke: skorIke,
        skorIkl: skorIkl,
        catatan: catatan,
      ),
    );
    return _extractItem(response.data);
  }

  Future<void> deleteIdm(String id) async {
    await _apiService.delete('${ApiConstants.idm}/$id');
  }

  Future<List<Map<String, dynamic>>> _aggregateDusunRelation({
    required String relationKey,
    required String labelKey,
  }) async {
    final dusuns = await _getDusuns();
    final totals = <String, int>{};

    for (final dusun in dusuns) {
      final relation = dusun[relationKey];
      if (relation is! List) continue;

      for (final row in relation.whereType<Map>()) {
        final label = '${row[labelKey] ?? ''}'.trim();
        if (label.isEmpty) continue;
        totals[label] = (totals[label] ?? 0) + _asInt(row['jumlah_jiwa']);
      }
    }

    final grandTotal = totals.values.fold<int>(0, (sum, value) => sum + value);
    return totals.entries
        .map(
          (entry) => {
            labelKey: entry.key,
            'jumlah_jiwa': entry.value,
            'persentase': grandTotal == 0
                ? 0.0
                : entry.value / grandTotal * 100,
          },
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> _getDusuns() async {
    final response = await _apiService.get(ApiConstants.dusun);
    return _extractList(
      response.data,
    ).whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Map<String, dynamic> _buildIdmPayload({
    required int tahun,
    required double skorIdm,
    required String statusIdm,
    required double skorIks,
    required double skorIke,
    required double skorIkl,
    String? catatan,
  }) {
    return {
      'tahun_idm': tahun,
      'score_idm': skorIdm,
      'status_idm': statusIdm,
      'sosial_idm': skorIks,
      'ekonomi_idm': skorIke,
      'lingkungan_idm': skorIkl,
    };
  }

  List<dynamic> _extractList(dynamic responseData) {
    if (responseData is List) return responseData;
    if (responseData is Map && responseData['data'] is List) {
      return responseData['data'] as List;
    }
    return const [];
  }

  IdmModel _extractItem(dynamic responseData) {
    if (responseData is Map && responseData['data'] is Map) {
      return IdmModel.fromJson(Map<String, dynamic>.from(responseData['data']));
    }
    if (responseData is Map) {
      return IdmModel.fromJson(Map<String, dynamic>.from(responseData));
    }
    throw Exception('Respons data IDM tidak valid');
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}
