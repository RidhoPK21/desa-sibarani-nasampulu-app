import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/api_client.dart';

// 1. STATE UNTUK DAFTAR IDM
final adminIdmListProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  try {
    final response = await api.get('/statistic/idm');
    return response.data['data'] ?? [];
  } catch (e) {
    throw Exception('Gagal memuat data IDM: $e');
  }
});

// 2. CONTROLLER UNTUK CRUD
class AdminIdmController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  // Fungsi CREATE / UPDATE
  Future<void> saveIdm(Map<String, dynamic> data, String? id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (id != null) {
        data['_method'] = 'PUT'; // Trik Laravel untuk update JSON
        await api.post('/statistic/idm/$id', data: data);
      } else {
        await api.post('/statistic/idm', data: data);
      }
    } catch (e) {
      errorMessage = 'Gagal menyimpan data IDM: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi DELETE
  Future<void> deleteIdm(String id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await api.delete('/statistic/idm/$id');
    } catch (e) {
      errorMessage = 'Gagal menghapus data IDM: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

final adminIdmControllerProvider = ChangeNotifierProvider.autoDispose<AdminIdmController>((ref) {
  return AdminIdmController();
});