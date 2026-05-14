import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/api_client.dart';

// 1. STATE UNTUK DAFTAR APBDES
final adminApbdesListProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  try {
    final response = await api.get('/info/apbdes');
    return response.data['data'] ?? [];
  } catch (e) {
    throw Exception('Gagal memuat daftar APBDes: $e');
  }
});

// 2. CONTROLLER UNTUK CRUD
class AdminApbdesController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  // Fungsi CREATE / UPDATE
  Future<void> saveApbdes(Map<String, dynamic> data, String? id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (id != null) {
        data['_method'] = 'PUT'; // Trik Laravel untuk update JSON
        await api.post('/info/apbdes/$id', data: data);
      } else {
        await api.post('/info/apbdes', data: data);
      }
    } catch (e) {
      errorMessage = 'Gagal menyimpan APBDes: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi DELETE
  Future<void> deleteApbdes(String id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await api.delete('/info/apbdes/$id');
    } catch (e) {
      errorMessage = 'Gagal menghapus APBDes: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

final adminApbdesControllerProvider = ChangeNotifierProvider.autoDispose<AdminApbdesController>((ref) {
  return AdminApbdesController();
});