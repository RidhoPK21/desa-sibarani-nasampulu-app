// lib/features/public/apbdes/presentation/providers/apbdes_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desa_sibarani_app/features/public/apbdes/data/models/apbdes_model.dart';
import 'package:desa_sibarani_app/features/public/apbdes/data/repositories/apbdes_repository.dart';

final apbdesRepositoryProvider = Provider<ApbdesRepository>((ref) {
  return ApbdesRepository();
});

final apbdesListProvider = FutureProvider<List<ApbdesModel>>((ref) async {
  return ref.read(apbdesRepositoryProvider).getApbdesList();
});

final apbdesDetailProvider =
FutureProvider.family<ApbdesModel, String>((ref, id) async {
  return ref.read(apbdesRepositoryProvider).getApbdesDetail(id);
});