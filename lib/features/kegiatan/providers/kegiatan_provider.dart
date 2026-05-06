import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/kegiatan_model.dart';
import '../../../data/repositories/kegiatan_repository.dart';
import '../../../data/services/api_service.dart';

// Provider untuk repository
final kegiatanRepositoryProvider = Provider<KegiatanRepository>((ref) {
  return KegiatanRepository(ApiService());
});

// State untuk list kegiatan
class KegiatanState {
  final List<KegiatanModel> kegiatans;
  final bool isLoading;
  final String? error;

  const KegiatanState({
    this.kegiatans = const [],
    this.isLoading = false,
    this.error,
  });

  KegiatanState copyWith({
    List<KegiatanModel>? kegiatans,
    bool? isLoading,
    String? error,
  }) {
    return KegiatanState(
      kegiatans: kegiatans ?? this.kegiatans,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Notifier untuk mengelola state kegiatan
class KegiatanNotifier extends Notifier<KegiatanState> {
  late final KegiatanRepository _repository;

  @override
  KegiatanState build() {
    _repository = ref.read(kegiatanRepositoryProvider);
    loadKegiatans();
    return const KegiatanState();
  }

  Future<void> loadKegiatans() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final kegiatans = await _repository.getKegiatanList();
      state = state.copyWith(kegiatans: kegiatans, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal memuat data kegiatan: $e',
      );
    }
  }

  Future<void> addKegiatan(KegiatanModel kegiatan) async {
    try {
      final newKegiatan = await _repository.createKegiatan(kegiatan);
      state = state.copyWith(
        kegiatans: [newKegiatan, ...state.kegiatans],
      );
    } catch (e) {
      state = state.copyWith(error: 'Gagal menambah kegiatan: $e');
    }
  }

  Future<void> updateKegiatan(String id, KegiatanModel updatedKegiatan) async {
    try {
      final updated = await _repository.updateKegiatan(id, updatedKegiatan);
      final index = state.kegiatans.indexWhere((k) => k.id == id);
      if (index != -1) {
        final newList = List<KegiatanModel>.from(state.kegiatans);
        newList[index] = updated;
        state = state.copyWith(kegiatans: newList);
      }
    } catch (e) {
      state = state.copyWith(error: 'Gagal mengupdate kegiatan: $e');
    }
  }

  Future<void> deleteKegiatan(String id) async {
    try {
      await _repository.deleteKegiatan(id);
      state = state.copyWith(
        kegiatans: state.kegiatans.where((k) => k.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Gagal menghapus kegiatan: $e');
    }
  }
}

// Provider untuk state kegiatan
final kegiatanProvider = NotifierProvider<KegiatanNotifier, KegiatanState>(() {
  return KegiatanNotifier();
});