import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/network/api_client.dart';

// 1. PROVIDER UNTUK RINGKASAN DINAMIS
final adminSummaryProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  try {
    final resDusun = await api.get('/statistic/dusun');
    final resIdm = await api.get('/statistic/idm');
    final resPerangkat = await api.get('/info/profil/perangkat-desa');

    final dusunData = resDusun.data['data'] as List;
    final totalPenduduk = dusunData.fold(0, (sum, item) => sum + (item['total_penduduk'] as int));

    final idmList = resIdm.data['data'] as List;
    String idmTerbaru = idmList.isNotEmpty ? idmList[0]['status_idm'] : "Belum Ada Data";
    String tahunIdm = idmList.isNotEmpty ? idmList[0]['tahun_idm'].toString() : "-";

    return {
      "totalPenduduk": totalPenduduk,
      "statusIdm": idmTerbaru,
      "tahunIdm": tahunIdm,
      "totalPerangkat": (resPerangkat.data['data'] as List).length,
    };
  } catch (e) {
    throw Exception('Gagal memuat ringkasan: $e');
  }
});

// 2. PROVIDER UNTUK LIST PERANGKAT & BANNER
final adminPerangkatProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final res = await api.get('/info/profil/perangkat-desa');
  return res.data['data'] ?? [];
});

final adminBannerProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final res = await api.get('/content/banner');
  return res.data['data'] ?? [];
});

// 3. CONTROLLER CRUD DASHBOARD (DENGAN BENTENG PERTAHANAN)
class AdminDashboardController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  //  Taktik Intelijen: Deteksi jika mesin sudah dihancurkan
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true; // Tandai mesin mati
    super.dispose();
  }

  // Fungsi Update Teks (Sambutan/Visi Misi)
  Future<void> updateTextData(String endpoint, Map<String, dynamic> data, String? id) async {
    isLoading = true; errorMessage = null;
    if (!_isDisposed) notifyListeners();

    try {
      if (id != null && id.isNotEmpty) {
        await api.put('$endpoint/$id', data: data);
      } else {
        await api.post(endpoint, data: data);
      }
    } catch (e) {
      errorMessage = 'Gagal menyimpan data teks';
    } finally {
      isLoading = false;
      //  Pastikan mesin belum hancur sebelum memberi laporan ke UI!
      if (!_isDisposed) notifyListeners();
    }
  }

  // Fungsi Simpan dengan Gambar (Perangkat/Banner)
  Future<void> saveMultipart({
    required String endpoint,
    required Map<String, dynamic> fields,
    PlatformFile? file,
    String? id,
    String fileKey = 'foto',
  }) async {
    isLoading = true; errorMessage = null;
    if (!_isDisposed) notifyListeners();

    try {
      final formData = FormData.fromMap({
        ...fields,
        if (id != null) '_method': 'PUT',
      });

      if (file != null && file.bytes != null) {
        formData.files.add(MapEntry(
          fileKey,
          MultipartFile.fromBytes(file.bytes!, filename: file.name),
        ));
      }

      await api.post(id != null ? '$endpoint/$id' : endpoint, data: formData);
    } catch (e) {
      errorMessage = 'Gagal menyimpan data gambar';
    } finally {
      isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  Future<void> deleteData(String endpoint, String id) async {
    isLoading = true;
    if (!_isDisposed) notifyListeners();

    try {
      await api.delete('$endpoint/$id');
    } catch (e) {
      errorMessage = 'Gagal menghapus data';
    } finally {
      isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }
}


final adminDashboardControllerProvider = ChangeNotifierProvider<AdminDashboardController>((ref) => AdminDashboardController());