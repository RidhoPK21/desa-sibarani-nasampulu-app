import 'package:flutter/material.dart';

import '../../../data/models/apbdes_model.dart';
import '../../../data/services/api_service.dart';


class ApbdesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ApbdesModel> _apbdesList = [];
  List<ApbdesModel> get apbdesList => _apbdesList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Mengambil data dari backend
  Future<void> fetchApbdes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _apbdesList = await _apiService.fetchApbdes();
    } catch (e) {
      _errorMessage = 'Gagal memuat data: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
// --- Tambahkan blok kode ini ke dalam ApbdesProvider ---

  // Fungsi untuk menyimpan atau mengupdate data
  Future<bool> save(ApbdesModel model, {ApbdesModel? existing}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (existing != null && existing.id != null) {
        // Jika data sudah ada, lakukan UPDATE
        await _apiService.updateApbdes(existing.id!, model);
      } else {
        // Jika data baru, lakukan CREATE
        await _apiService.createApbdes(model);
      }
      return true; // Berhasil
    } catch (e) {
      _errorMessage = 'Gagal menyimpan data: ${e.toString()}';
      return false; // Gagal
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // Menghapus data
  Future<void> deleteApbdes(int id) async {
    try {
      await _apiService.deleteApbdes(id);

      // PERBAIKAN NULL SAFETY: Cukup bandingkan langsung (int? == int itu valid di Dart)
      _apbdesList.removeWhere((item) => item.id == id);

      notifyListeners();
    } catch (e) {
      throw Exception('Gagal menghapus data');
    }
  }
}