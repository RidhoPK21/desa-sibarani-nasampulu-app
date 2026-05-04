// lib/features/public/apbdes/presentation/screens/apbdes_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:desa_sibarani_app/features/public/apbdes/presentation/providers/apbdes_provider.dart';
import 'package:desa_sibarani_app/features/public/apbdes/presentation/widgets/apbdes_card.dart';

class ApbdesListScreen extends ConsumerWidget {
  const ApbdesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apbdesAsync = ref.watch(apbdesListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF4EA674),
      appBar: AppBar(
        title: const Text(
          'APBDes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: apbdesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 8),
              Text(
                'Gagal memuat data: $e',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        data: (list) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'APBDes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Anggaran Pendapatan dan Belanja Desa',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  ...list.map(
                        (apbdes) => ApbdesCard(
                      apbdes: apbdes,
                      onTap: () => context.push('/apbdes/${apbdes.id}'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}