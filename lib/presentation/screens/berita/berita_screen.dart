import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import '../../../features/public/berita/providers/berita_provider.dart';
import '../../../features/public/berita/models/berita.dart';
import 'berita_detail_screen.dart';

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
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 40, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Berita",
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Kumpulan informasi, pengumuman, dan kabar terbaru dari Pemerintah",
                    style: TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
                  ),
                  Text(
                    "Desa Sibarani Nasampuluh",
                    style: TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),

            Expanded(
              child: beritaAsync.when(
                data: (beritaList) => RefreshIndicator(
                  onRefresh: () => ref.read(beritaProvider.notifier).fetchBerita(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: beritaList.length,
                    itemBuilder: (context, index) {
                      return _buildBeritaCard(context, ref, beritaList[index]);
                    },
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $err', style: const TextStyle(color: Colors.white)),
                      ElevatedButton(
                        onPressed: () => ref.read(beritaProvider.notifier).fetchBerita(),
                        child: const Text('Coba Lagi'),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeritaCard(BuildContext context, WidgetRef ref, Berita berita) {
    String imageUrl = berita.gambarUrl ?? "";
    
    if (imageUrl.isNotEmpty) {
      // 🔥 LOGIKA BARU: Parsing URL untuk mendapatkan path murni
      if (imageUrl.contains('localhost') || imageUrl.contains('127.0.0.1')) {
        try {
          Uri uri = Uri.parse(imageUrl);
          String path = uri.path;
          
          String host = kIsWeb ? "localhost" : "10.0.2.2";
          imageUrl = "http://$host:9000$path";
        } catch (e) {
          debugPrint("Error parsing image URL: $e");
        }
      } 
      else if (!imageUrl.startsWith('http')) {
        String host = kIsWeb ? "localhost" : "10.0.2.2";
        if (!imageUrl.startsWith('storage/') && !imageUrl.startsWith('/storage/')) {
          imageUrl = "http://$host:9000/storage/$imageUrl";
        } else {
          imageUrl = "http://$host:9000/${imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl}";
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                child: imageUrl.isEmpty 
                  ? Container(height: 220, color: Colors.grey[300], child: const Icon(Icons.image_not_supported, size: 50))
                  : kIsWeb 
                    ? Image.network(
                        imageUrl,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildErrorImage(imageUrl),
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(height: 220, color: Colors.grey[200], child: const Center(child: CircularProgressIndicator())),
                        errorWidget: (context, url, error) => _buildErrorImage(imageUrl),
                      ),
              ),
              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(berita.judul, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BeritaDetailScreen(berita: berita))),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("View Details", style: TextStyle(color: Color(0xFF4EA674), fontSize: 14, fontWeight: FontWeight.w600)),
                            SizedBox(width: 5),
                            Icon(Icons.arrow_forward, color: Color(0xFF4EA674), size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF4EA674)),
                const SizedBox(width: 8),
                Text(DateFormat('MMM dd, yyyy').format(berita.createdAt), style: const TextStyle(color: Color(0xFFA0A0A0), fontSize: 14)),
                const SizedBox(width: 20),
                const Icon(Icons.access_time, size: 18, color: Color(0xFF4EA674)),
                const SizedBox(width: 8),
                Text(DateFormat('h:mm a').format(berita.createdAt), style: const TextStyle(color: Color(0xFFA0A0A0), fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorImage(String url) {
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image, color: Colors.grey, size: 50),
          const SizedBox(height: 8),
          const Text("Gagal memuat gambar", style: TextStyle(color: Colors.grey, fontSize: 10)),
          if (kDebugMode) Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(url, textAlign: TextAlign.center, style: const TextStyle(fontSize: 8, color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
