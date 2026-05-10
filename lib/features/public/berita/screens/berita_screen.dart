import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/berita_provider.dart';
import '../widgets/berita_card.dart';

class BeritaScreen extends ConsumerWidget {
  const BeritaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final beritaAsync = ref.watch(beritaProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF4EA674),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Berita Desa", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("Kabar terbaru dari Desa Sibarani Nasampulu", style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            // Konten
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB), // Abu-abu sangat terang
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: beritaAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF4EA674))),
                  error: (e, _) => Center(child: Text('Gagal memuat berita: $e')),
                  data: (list) {
                    if (list.isEmpty) {
                      return const Center(child: Text('Belum ada berita yang diterbitkan.', style: TextStyle(color: Colors.grey)));
                    }
                    return RefreshIndicator(
                      color: const Color(0xFF4EA674),
                      onRefresh: () => ref.read(beritaProvider.notifier).fetchBerita(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final berita = list[index];
                          return BeritaCard(
                            berita: berita,
                            // 🔥 Navigasi menggunakan GoRouter
                            onTap: () => context.push('/berita/${berita.id}'),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}