import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/network/api_client.dart';

// 1. STATE UNTUK DAFTAR BERITA
final adminBeritaListProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  try {
    final response = await api.get('/info/berita');
    return response.data['data'] ?? [];
  } catch (e) {
    throw Exception('Gagal memuat daftar berita: $e');
  }
});

// 2. CONTROLLER UNTUK CRUD
class AdminBeritaController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  // Fungsi CREATE / UPDATE
  Future<void> saveBerita({
    String? id,
    required String judul,
    required String konten,
    required int isPublished,
    PlatformFile? gambarUrl,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final formData = FormData.fromMap({
        'judul': judul,
        'konten': konten,
        'is_published': isPublished,
        // Trik Laravel: Jika Update bawa file, gunakan POST dengan _method PUT
        if (id != null) '_method': 'PUT',
      });

      // Tambahkan file gambar jika admin memilih file baru
      if (gambarUrl != null && gambarUrl.bytes != null) {
        formData.files.add(MapEntry(
          'gambar_url', // Pastikan key ini sesuai dengan backend/React
          MultipartFile.fromBytes(gambarUrl.bytes!, filename: gambarUrl.name),
        ));
      }

      if (id != null) {
        await api.post('/info/berita/$id', data: formData); // UPDATE
      } else {
        await api.post('/info/berita', data: formData); // CREATE
      }
    } catch (e) {
      errorMessage = 'Gagal menyimpan berita: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi DELETE
  Future<void> deleteBerita(String id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await api.delete('/info/berita/$id');
    } catch (e) {
      errorMessage = 'Gagal menghapus berita: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

final adminBeritaControllerProvider = ChangeNotifierProvider.autoDispose<AdminBeritaController>((ref) {
  return AdminBeritaController();
});