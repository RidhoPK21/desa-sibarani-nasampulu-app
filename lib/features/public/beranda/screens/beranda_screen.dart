import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/beranda_provider.dart';

class BerandaScreen extends ConsumerStatefulWidget {
  const BerandaScreen({super.key});

  @override
  ConsumerState<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends ConsumerState<BerandaScreen> {
  final PageController _pageController = PageController();
  Timer? _sliderTimer;
  int _currentSlide = 0;

  void _startSliderTimer(int bannerCount) {
    _sliderTimer?.cancel();
    if (bannerCount <= 1) return;
    _sliderTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextSlide = (_currentSlide + 1) % bannerCount;
        _pageController.animateToPage(
          nextSlide,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Helper Hapus Tag HTML
  String _stripHtml(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').trim();
  }

  // Format Tanggal
  String _formatTanggal(String? dateStr) {
    if (dateStr == null) return "-";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    final berandaAsync = ref.watch(berandaProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // slate-50
      body: RefreshIndicator(
        color: const Color(0xFF4EA674),
        onRefresh: () async => ref.refresh(berandaProvider),
        child: berandaAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF4EA674))),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Gagal memuat beranda:\n$error', textAlign: TextAlign.center),
                TextButton(onPressed: () => ref.refresh(berandaProvider), child: const Text('Coba Lagi'))
              ],
            ),
          ),
          data: (data) {
            // Jalankan timer saat data banner berhasil diload
            if (_sliderTimer == null && data.banners.length > 1) {
              _startSliderTimer(data.banners.length);
            }

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                // ── 1. HERO / BANNER SLIDER ──
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Stack(
                    children: [
                      if (data.banners.isEmpty)
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0xFF57A677), Color(0xFF4EA674)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Selamat Datang di", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, fontStyle: FontStyle.italic, fontFamily: 'Georgia')),
                                SizedBox(height: 8),
                                Text("Desa Sibarani Nasampulu", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                              ],
                            ),
                          ),
                        )
                      else
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) => setState(() => _currentSlide = index),
                          itemCount: data.banners.length,
                          itemBuilder: (context, index) {
                            final banner = data.banners[index];
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  formatImageUrl(banner['gambar_url']),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: Colors.grey[800], child: const Icon(Icons.broken_image, color: Colors.white54, size: 50)),
                                ),
                                // Gradient Overlay
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                      colors: [Colors.black87, Colors.transparent],
                                      stops: [0.0, 0.5],
                                    ),
                                  ),
                                ),
                                // Teks Banner
                                Positioned(
                                  bottom: 40, left: 24, right: 24,
                                  child: Text(
                                    banner['nama_banner'] ?? '',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'Georgia', fontStyle: FontStyle.italic, shadows: [Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 3))]),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                      // Indikator Titik
                      if (data.banners.length > 1)
                        Positioned(
                          bottom: 16, left: 0, right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              data.banners.length,
                                  (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentSlide == index ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentSlide == index ? const Color(0xFF4EA674) : Colors.white54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── 2. KATA SAMBUTAN ──
                if (data.sambutan.isNotEmpty)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    child: Column(
                      children: [
                        const Icon(Icons.format_quote_rounded, size: 48, color: Color(0xFFE8F5E9)),
                        const SizedBox(height: 12),
                        const Text("Kata Sambutan Kepala Desa", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Georgia', color: Color(0xFF1E293B))),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFF1F5F9))),
                          child: Text(data.sambutan, style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF475569), fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),

                // ── 3. BERITA TERKINI ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Berita Terkini", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Georgia', color: Color(0xFF1E293B))),
                                SizedBox(height: 4),
                                Text("Informasi terbaru dari desa.", style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/berita'),
                            style: TextButton.styleFrom(foregroundColor: const Color(0xFF4EA674)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [Text("Lihat Semua", style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(width: 4), Icon(Icons.arrow_right_alt_rounded, size: 18)],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (data.berita.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: const Center(child: Text("Belum ada berita yang diterbitkan.", style: TextStyle(color: Color(0xFF94A3B8)))),
                        )
                      else
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: data.berita.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final b = data.berita[index];
                            return InkWell(
                              onTap: () => context.go('/berita/${b['id']}'),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 180, width: double.infinity,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(formatImageUrl(b['gambar_url']), fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.newspaper, color: Colors.grey, size: 40))),
                                          Positioned(top: 12, left: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF4EA674), borderRadius: BorderRadius.circular(20)), child: const Text("Berita Desa", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF94A3B8)), const SizedBox(width: 6), Text(_formatTanggal(b['created_at']), style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600))]),
                                          const SizedBox(height: 8),
                                          Text(b['judul'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), height: 1.3)),
                                          const SizedBox(height: 8),
                                          Text(_stripHtml(b['isi_berita'] ?? 'Baca selengkapnya...'), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),

                // ── 4. RINGKASAN DEMOGRAFI ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF57A677), Color(0xFF4EA674)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                  child: Column(
                    children: [
                      const Text("Ringkasan Demografi Desa", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Georgia', fontStyle: FontStyle.italic, color: Colors.white)),
                      const SizedBox(height: 12),
                      Text("Data rekapitulasi jumlah penduduk (Real-time).", textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                      const SizedBox(height: 32),

                      // Stat Cards
                      _buildStatCard("Total Penduduk", data.statistik['total'] ?? 0, Icons.people_alt_rounded, Colors.white),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard("Laki-Laki", data.statistik['laki'] ?? 0, Icons.person_rounded, Colors.blue[100]!)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildStatCard("Perempuan", data.statistik['perempuan'] ?? 0, Icons.person_rounded, Colors.pink[100]!)),
                        ],
                      ),

                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: () => context.go('/infografis'),
                        style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF4EA674), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                        child: const Text("Lihat Detail Infografis", style: TextStyle(fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Desain Kartu Statistik
  Widget _buildStatCard(String title, int count, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.2))),
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: iconColor.withOpacity(0.2), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 28)),
          const SizedBox(height: 16),
          Text(title.toUpperCase(), style: TextStyle(color: iconColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(NumberFormat('#,###', 'id_ID').format(count), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          const Text("Jiwa", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}