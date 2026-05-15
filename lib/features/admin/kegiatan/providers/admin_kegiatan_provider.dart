import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart'; // Tetap bawa pelindung legacy kita
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/network/api_client.dart';

// 1. STATE UNTUK DAFTAR KEGIATAN
final adminKegiatanProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  try {
    final response = await api.get('/info/kegiatan');
    return response.data['data'] ?? [];
  } catch (e) {
    throw Exception('Gagal memuat daftar kegiatan: $e');
  }
});

// 2. CONTROLLER UNTUK CRUD
class AdminKegiatanController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  // Fungsi CREATE / UPDATE
  Future<void> saveKegiatan({
    String? id,
    required String jenisKegiatan,
    required String judulKegiatan,
    required String deskripsiKegiatan,
    required String tanggalPelaksana,
    String? tanggalBerakhir,
    required String statusKegiatan,
    PlatformFile? gambar,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final formData = FormData.fromMap({
        'jenis_kegiatan': jenisKegiatan,
        'judul_kegiatan': judulKegiatan,
        if (deskripsiKegiatan.isNotEmpty) 'deskripsi_kegiatan': deskripsiKegiatan,
        'tanggal_pelaksana': tanggalPelaksana,
        if (tanggalBerakhir != null && tanggalBerakhir.isNotEmpty) 'tanggal_berakhir': tanggalBerakhir,
        'status_kegiatan': statusKegiatan,

        // Trik Laravel: Jika Update, gunakan POST dengan _method PUT
        if (id != null) '_method': 'PUT',
      });

      // Tambahkan gambar jika ada yang dipilih
      if (gambar != null && gambar.bytes != null) {
        formData.files.add(MapEntry(
          'gambar',
          MultipartFile.fromBytes(gambar.bytes!, filename: gambar.name),
        ));
      }

      if (id != null) {
        await api.post('/info/kegiatan/$id', data: formData); // UPDATE
      } else {
        await api.post('/info/kegiatan', data: formData); // CREATE
      }
    } catch (e) {
      errorMessage = 'Gagal menyimpan kegiatan: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi DELETE
  Future<void> deleteKegiatan(String id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await api.delete('/info/kegiatan/$id');
    } catch (e) {
      errorMessage = 'Gagal menghapus kegiatan: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

final adminKegiatanControllerProvider = ChangeNotifierProvider.autoDispose<AdminKegiatanController>((ref) {
  return AdminKegiatanController();
});