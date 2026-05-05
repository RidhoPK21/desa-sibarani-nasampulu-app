import '../models/apbdes_model.dart';
import '../services/api_service.dart';

class ApbdesRepository {
  final ApiService _apiService = ApiService();

  Future<List<ApbdesModel>> getAll() => _apiService.fetchApbdes();

  Future<ApbdesModel> create(ApbdesModel model) =>
      _apiService.createApbdes(model);

  Future<ApbdesModel> update(int id, ApbdesModel model) =>
      _apiService.updateApbdes(id, model);

  Future<void> delete(int id) => _apiService.deleteApbdes(id);
}
