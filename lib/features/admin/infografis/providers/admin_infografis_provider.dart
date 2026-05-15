import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/api_client.dart';

// 1. STATE UNTUK DAFTAR DUSUN
final adminDusunProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  try {
    final response = await api.get('/statistic/dusun');
    return response.data['data'] ?? [];
  } catch (e) {
    throw Exception('Gagal memuat data Dusun: $e');
  }
});

// 2. CONTROLLER UNTUK CRUD
class AdminInfografisController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  // Fungsi CREATE / UPDATE
  Future<void> saveDusun(Map<String, dynamic> formData, bool isEdit) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Karena ini bukan form-data (tidak ada file), kita bisa kirim JSON langsung
      if (isEdit) {
        formData['_method'] = 'PUT'; // Trik Laravel
        await api.post('/statistic/dusun/${formData['id']}', data: formData);
      } else {
        await api.post('/statistic/dusun', data: formData);
      }
    } catch (e) {
      errorMessage = 'Gagal menyimpan data dusun: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi DELETE
  Future<void> deleteDusun(String id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await api.delete('/statistic/dusun/$id');
    } catch (e) {
      errorMessage = 'Gagal menghapus dusun: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

final adminInfografisControllerProvider = ChangeNotifierProvider.autoDispose<AdminInfografisController>((ref) {
  return AdminInfografisController();
});