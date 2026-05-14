import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart'; // <--- TAMBAHKAN BARIS INI
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/network/api_client.dart';

// 1. STATE UNTUK DAFTAR DOKUMEN
final adminDokumenProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  try {
    final response = await api.get('/info/dokumen');
    return response.data['data'] ?? [];
  } catch (e) {
    throw Exception('Gagal memuat daftar dokumen: $e');
  }
});

// 2. MENGGUNAKAN CHANGENOTIFIER (100% AMAN DARI ERROR VERSI)
class AdminPpidController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  // Fungsi CREATE / UPDATE
  Future<void> saveDokumen({
    String? id,
    required String nama,
    required String jenis,
    required String deskripsi,
    PlatformFile? file,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners(); // Beritahu UI untuk loading

    try {
      final formData = FormData.fromMap({
        'nama_ppid': nama,
        'jenis_ppid': jenis,
        if (deskripsi.isNotEmpty) 'deskripsi_ppid': deskripsi,
        // Trik Laravel
        if (id != null) '_method': 'PUT',
      });

      if (file != null && file.bytes != null) {
        formData.files.add(MapEntry(
          'file',
          MultipartFile.fromBytes(file.bytes!, filename: file.name),
        ));
      }

      if (id != null) {
        await api.post('/info/dokumen/$id', data: formData); // UPDATE
      } else {
        await api.post('/info/dokumen', data: formData); // CREATE
      }
    } catch (e) {
      errorMessage = 'Gagal menyimpan dokumen: $e';
    } finally {
      isLoading = false;
      notifyListeners(); // Beritahu UI loading selesai
    }
  }

  // Fungsi DELETE
  Future<void> deleteDokumen(String id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await api.delete('/info/dokumen/$id');
    } catch (e) {
      errorMessage = 'Gagal menghapus dokumen: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// Daftarkan Provider sebagai ChangeNotifierProvider
final adminPpidControllerProvider = ChangeNotifierProvider.autoDispose<AdminPpidController>((ref) {
  return AdminPpidController();
});