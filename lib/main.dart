import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(
    // Wajib dibungkus ProviderScope agar Riverpod menyala
    const ProviderScope(
      child: DesaSibaraniApp(),
    ),
  );
}

class DesaSibaraniApp extends ConsumerWidget {
  const DesaSibaraniApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ambil konfigurasi router yang sudah kita buat
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Desa Sibarani',
      theme: ThemeData(
        primaryColor: const Color(0xFF4EA674), // Warna hijau desa
      ),
      routerConfig: router,
    );
  }
}