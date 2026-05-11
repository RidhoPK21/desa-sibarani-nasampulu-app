import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/constants/api_constants.dart';
import '../models/content_models.dart';
import '../services/api_service.dart';

class ContentRepository {
  final ApiService _api;

  ContentRepository(this._api);

  Future<List<BeritaModel>> getBerita() async {
    final response = await _api.get(ApiConstants.berita);
    return _extractList(response.data)
        .whereType<Map>()
        .map((item) => BeritaModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<BeritaModel> createBerita(
    BeritaModel item, {
    PlatformFile? image,
  }) async {
    final response = await _api.post(
      ApiConstants.berita,
      data: await _beritaFormData(item, image: image),
    );
    return BeritaModel.fromJson(_extractMap(response.data));
  }

  Future<BeritaModel> updateBerita(
    BeritaModel item, {
    PlatformFile? image,
  }) async {
    final form = await _beritaFormData(item, image: image);
    form.fields.add(const MapEntry('_method', 'PUT'));
    final response = await _api.post(
      '${ApiConstants.berita}/${item.id}',
      data: form,
    );
    return BeritaModel.fromJson(_extractMap(response.data));
  }

  Future<void> deleteBerita(String id) async {
    await _api.delete('${ApiConstants.berita}/$id');
  }

  Future<List<PpidDocumentModel>> getPpid() async {
    final response = await _api.get(ApiConstants.ppid);
    return _extractList(response.data)
        .whereType<Map>()
        .map(
          (item) => PpidDocumentModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<PpidDocumentModel> createPpid(
    PpidDocumentModel item, {
    required PlatformFile file,
  }) async {
    final response = await _api.post(
      ApiConstants.ppid,
      data: await _ppidFormData(item, file: file),
    );
    return PpidDocumentModel.fromJson(_extractMap(response.data));
  }

  Future<PpidDocumentModel> updatePpid(
    PpidDocumentModel item, {
    PlatformFile? file,
  }) async {
    final form = await _ppidFormData(item, file: file);
    form.fields.add(const MapEntry('_method', 'PUT'));
    final response = await _api.post(
      '${ApiConstants.ppid}/${item.id}',
      data: form,
    );
    return PpidDocumentModel.fromJson(_extractMap(response.data));
  }

  Future<void> deletePpid(String id) async {
    await _api.delete('${ApiConstants.ppid}/$id');
  }

  Future<List<GaleriModel>> getGaleri() async {
    final response = await _api.get(ApiConstants.galeri);
    return _extractList(response.data)
        .whereType<Map>()
        .map((item) => GaleriModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<FormData> _beritaFormData(
    BeritaModel item, {
    PlatformFile? image,
  }) async {
    final data = Map<String, dynamic>.from(item.toPayload());
    if (image != null) data['gambar_url'] = await _multipart(image);
    return FormData.fromMap(data);
  }

  Future<FormData> _ppidFormData(
    PpidDocumentModel item, {
    PlatformFile? file,
  }) async {
    final data = Map<String, dynamic>.from(item.toPayload());
    if (file != null) data['file'] = await _multipart(file);
    return FormData.fromMap(data);
  }

  Future<MultipartFile> _multipart(PlatformFile file) async {
    if (file.bytes != null) {
      return MultipartFile.fromBytes(file.bytes!, filename: file.name);
    }
    if (file.path != null) {
      return MultipartFile.fromFile(file.path!, filename: file.name);
    }
    throw Exception('File tidak valid');
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'] as List;
    return const [];
  }

  Map<String, dynamic> _extractMap(dynamic data) {
    if (data is Map && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data']);
    }
    if (data is Map) return Map<String, dynamic>.from(data);
    throw Exception('Respons tidak valid');
  }
}
