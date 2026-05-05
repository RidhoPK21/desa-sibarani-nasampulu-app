import 'package:flutter/material.dart';
import '../../data/models/apbdes_model.dart';
import '../../data/repositories/apbdes_repository.dart';

class ApbdesProvider extends ChangeNotifier {
  final ApbdesRepository _repo = ApbdesRepository();

  List<ApbdesModel> _list = [];
  bool _isLoading = false;
  String? _error;

  List<ApbdesModel> get list => _list;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _list = await _repo.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> save(ApbdesModel model, {ApbdesModel? existing}) async {
    try {
      if (existing != null) {
        await _repo.update(existing.id!, model);
      } else {
        await _repo.create(model);
      }
      await fetchAll();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> remove(int id) async {
    try {
      await _repo.delete(id);
      await fetchAll();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
