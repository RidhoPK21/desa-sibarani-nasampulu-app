import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/galeri_provider.dart';
import '../models/galeri_model.dart';

class GaleriScreen extends ConsumerStatefulWidget {
  const GaleriScreen({super.key});

  @override
  ConsumerState<GaleriScreen> createState() => _GaleriScreenState();
}

class _GaleriScreenState extends ConsumerState<GaleriScreen> {
  String _activeFilter = 'Semua';
  int _page = 1;
  final int _itemsPerPage = 8;

  @override
  Widget build(BuildContext context) {
    final galeriAsync = ref.watch(galeriProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF57A677), // Warna dasar jika ketarik
      body: Stack(
        children: [
          // ── BACKGROUND GRADASI & BLOBS ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF57A677), Color(0xFF4EA674)],
              ),
            ),
          ),
          Positioned(top: -50, left: -50, child: _buildBlob(300, Colors.blue.withOpacity(0.3))),
          Positioned(bottom: 100, right: -50, child: _buildBlob(350, Colors.indigo.withOpacity(0.2))),
          Positioned(top: 50, right: 50, child: _buildBlob(250, const Color(0xFF6EE7B7).withOpacity(0.2))),

          // ── KONTEN UTAMA ──
          galeriAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
            error: (err, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  const Text('Gagal memuat data galeri.', style: TextStyle(color: Colors.white)),
                  TextButton(onPressed: () => ref.refresh(galeriProvider), child: const Text('Coba Lagi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
                ],
              ),
            ),
            data: (allItems) {
              // Logika Filter
              final filteredItems = _activeFilter == 'Semua' ? allItems : allItems.where((i) => i.kategori == _activeFilter).toList();
              // Logika Pagination (Load More)
              final displayedItems = filteredItems.take(_page * _itemsPerPage).toList();
              final hasMore = displayedItems.length < filteredItems.length;

              return RefreshIndicator(
                color: const Color(0xFF4EA674),
                onRefresh: () async => ref.refresh(galeriProvider),
                child: CustomScrollView(
                  slivers: [
                    // HEADER TEXT
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
                        child: Column(
                          children: [
                            const Text(
                              "Galeri Desa Sibarani Nasampulu",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Georgia', fontStyle: FontStyle.italic, height: 1.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Dokumentasi visual dari berbagai aktivitas, program kerja, dan berita terkini di desa kami.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w600, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // CHIP FILTER KATEGORI
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        child: Wrap(
                          spacing: 12, runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: ['Semua', 'Berita', 'Kegiatan'].map((f) {
                            final isActive = _activeFilter == f;
                            final count = f == 'Semua' ? allItems.length : allItems.where((i) => i.kategori == f).length;
                            return InkWell(
                              onTap: () => setState(() { _activeFilter = f; _page = 1; }),
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: isActive ? Colors.white : Colors.white.withOpacity(0.5)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(f, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? const Color(0xFF4EA674) : Colors.white)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: isActive ? const Color(0xFF4EA674).withOpacity(0.1) : Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                                      child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? const Color(0xFF4EA674) : Colors.white)),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // GRID FOTO
                    if (filteredItems.isEmpty)
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.all(24),
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(24)),
                          child: const Center(child: Text("Belum ada foto untuk kategori ini.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.all(24),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 2 Kolom untuk Mobile
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.0, // Bentuk kotak
                          ),
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              final item = displayedItems[index];
                              return _buildGridItem(item, displayedItems);
                            },
                            childCount: displayedItems.length,
                          ),
                        ),
                      ),

                    // TOMBOL LOAD MORE
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 80, top: 16),
                        child: hasMore
                            ? Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, foregroundColor: const Color(0xFF4EA674),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () => setState(() => _page++),
                            child: Text("Lihat Lebih Banyak (${filteredItems.length - displayedItems.length} foto lagi)", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        )
                            : displayedItems.isNotEmpty
                            ? const Center(child: Text("Semua foto sudah ditampilkan", style: TextStyle(color: Colors.white70)))
                            : const SizedBox.shrink(),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Desain Kartu Grid
  Widget _buildGridItem(GaleriModel item, List<GaleriModel> allDisplayed) {
    return InkWell(
      onTap: () => _showLightbox(context, item, allDisplayed),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(item.gambarUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white54, size: 40)),
            // Gradasi Gelap di Bawah
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black87]),
              ),
            ),
            // Teks Kategori & Judul
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.kategori == 'Berita' ? Colors.blue : const Color(0xFF4EA674),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(item.kategori.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                  const SizedBox(height: 6),
                  Text(item.judul, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, height: 1.2)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Lightbox Pop-up
  void _showLightbox(BuildContext context, GaleriModel initialItem, List<GaleriModel> items) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => _LightboxDialog(initialItem: initialItem, items: items),
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

// ── WIDGET DIALOG LIGHTBOX (TAMPILAN POP-UP) ──
class _LightboxDialog extends StatefulWidget {
  final GaleriModel initialItem;
  final List<GaleriModel> items;

  const _LightboxDialog({required this.initialItem, required this.items});

  @override
  State<_LightboxDialog> createState() => _LightboxDialogState();
}

class _LightboxDialogState extends State<_LightboxDialog> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.items.indexWhere((i) => i.id == widget.initialItem.id);
    if (currentIndex == -1) currentIndex = 0;
  }

  void _nav(int step) {
    setState(() {
      currentIndex += step;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.items[currentIndex];
    final hasPrev = currentIndex > 0;
    final hasNext = currentIndex < widget.items.length - 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bagian Foto dengan Tombol Navigasi
            Container(
              color: Colors.black.withOpacity(0.05),
              height: MediaQuery.of(context).size.height * 0.5,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(item.gambarUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 80, color: Colors.grey)),
                  if (hasPrev)
                    Positioned(left: 10, child: IconButton(onPressed: () => _nav(-1), icon: const Icon(Icons.chevron_left, size: 40), color: Colors.black54, style: IconButton.styleFrom(backgroundColor: Colors.white70))),
                  if (hasNext)
                    Positioned(right: 10, child: IconButton(onPressed: () => _nav(1), icon: const Icon(Icons.chevron_right, size: 40), color: Colors.black54, style: IconButton.styleFrom(backgroundColor: Colors.white70))),
                ],
              ),
            ),
            // Bagian Informasi Teks
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: item.kategori == 'Berita' ? Colors.blue.withOpacity(0.1) : const Color(0xFF4EA674), borderRadius: BorderRadius.circular(20)),
                          child: Text(item.kategori.toUpperCase(), style: TextStyle(color: item.kategori == 'Berita' ? Colors.blue[700] : Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                        Text(item.judul, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87, height: 1.2)),
                        const SizedBox(height: 8),
                        Text("Dipublikasikan pada: ${item.tanggalFormat}", style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.1), foregroundColor: Colors.red),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}