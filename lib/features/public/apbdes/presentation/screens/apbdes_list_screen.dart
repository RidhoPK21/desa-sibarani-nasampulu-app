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

    // 🔥 Taktik Intelijen: Seragamkan dengan warna ProfilScreen
    const primaryGreen = Color(0xFF57A677);
    const textGreen = Color(0xFF4EA674);

    return Scaffold(
      backgroundColor: Colors.grey[50], // Background yang konsisten dengan Profil
      appBar: AppBar(
        title: const Text(
          'Transparansi APBDes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: apbdesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: primaryGreen),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              Text(
                'Gagal memuat data: $e',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        data: (list) => SingleChildScrollView(
          padding: const EdgeInsets.all(24), // Padding diperlebar agar lebih elegan
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Data APBDes',
                style: TextStyle(
                  fontSize: 24, // Judul diperbesar agar serasi dengan Profil
                  fontWeight: FontWeight.w900,
                  color: textGreen,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Anggaran Pendapatan dan Belanja Desa Sibarani Nasampulu',
                style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),

              // Handle jika data kosong
              if (list.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(
                      "Data APBDes belum tersedia.",
                      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ),
                )
              else
                ...list.map(
                      (apbdes) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0), // Jarak antar card dipertegas
                    child: ApbdesCard(
                      apbdes: apbdes,
                      onTap: () => context.push('/apb-desa/${apbdes.id}'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}