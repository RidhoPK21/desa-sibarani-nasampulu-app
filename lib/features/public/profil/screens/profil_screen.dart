import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profil_provider.dart';
import '../models/profil_model.dart';

class ProfilScreen extends ConsumerWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilAsync = ref.watch(profilProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: profilAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF57A677))),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text("Gagal memuat: $err", textAlign: TextAlign.center),
              TextButton(
                onPressed: () => ref.refresh(profilProvider),
                child: const Text("Coba Lagi"),
              )
            ],
          ),
        ),
        data: (data) => RefreshIndicator(
          color: const Color(0xFF57A677),
          onRefresh: () async => ref.refresh(profilProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildSejarahDanVisiMisi(data.visiMisi),
                _buildStrukturOrganisasi(),
                _buildPerangkatDesa(data.perangkatList),
                _buildPetaLokasi(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1 & 2. SEJARAH & VISI MISI SECTION
  // ==========================================
  Widget _buildSejarahDanVisiMisi(VisiMisiModel data) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF57A677),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        children: [
          // Sejarah
          const Text(
            "Sejarah Desa",
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, fontStyle: FontStyle.italic, fontFamily: 'serif'),
          ),
          const SizedBox(height: 16),
          const Text(
            "kosong", // Sesuai dengan React-mu
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 60),

          // Visi
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("VISI", style: TextStyle(fontSize: 24, color: Colors.white, letterSpacing: 2)),
                    const SizedBox(height: 16),
                    const Text(
                      "Membangun desa yang sejahtera\ndan berdaya saing tinggi.",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Text(data.visi, style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              _buildPlaceholderLogo(),
            ],
          ),
          const SizedBox(height: 60),

          // Misi
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildPlaceholderLogo(),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("MISI", style: TextStyle(fontSize: 24, color: Colors.white, letterSpacing: 2)),
                    const SizedBox(height: 16),
                    const Text(
                      "Meningkatkan pelayanan publik dan\nkesejahteraan masyarakat.",
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Text(data.misi, textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. STRUKTUR ORGANISASI SECTION
  // ==========================================
  Widget _buildStrukturOrganisasi() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.business, color: Color(0xFF4EA674), size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Struktur Organisasi Pemerintahan",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // PLACEHOLDER GAMBAR STRUKTUR
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Center(
              child: Text("Gambar Struktur Organisasi\n(strukturOrganisasi.jpg)", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. PERANGKAT DESA SECTION
  // ==========================================
  Widget _buildPerangkatDesa(List<PerangkatDesaModel> perangkatList) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, const Color(0xFF4EA674).withOpacity(0.1)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Data Perangkat Desa",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF4EA674)),
            ),
          ),
          const SizedBox(height: 24),
          if (perangkatList.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text("Data perangkat desa belum tersedia.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
            )
          else
            SizedBox(
              height: 280,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: perangkatList.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final item = perangkatList[index];
                  return _buildPerangkatCard(item);
                },
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // 5. PETA LOKASI SECTION
  // ==========================================
  Widget _buildPetaLokasi() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF4EA674),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.location_on, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text("Peta Lokasi Desa", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 24),
          // PLACEHOLDER GAMBAR PETA
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)],
            ),
            child: const Center(
              child: Text("Gambar Peta\n(peta.jpg)", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN BANTUAN ---

  Widget _buildPlaceholderLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
      child: const Center(child: Icon(Icons.shield, color: Colors.white, size: 48)),
    );
  }

  Widget _buildPerangkatCard(PerangkatDesaModel item) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: item.fotoUrl != null && item.fotoUrl!.isNotEmpty
                  ? Image.network(
                _formatImageUrl(item.fotoUrl),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFallbackUser(),
              )
                  : _buildFallbackUser(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(item.nama, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(item.jabatan, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF4EA674), fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackUser() {
    return Container(
      color: Colors.grey[200],
      child: const Center(child: Icon(Icons.person, color: Colors.grey, size: 64)),
    );
  }

  // Fungsi penjinak gambar localhost
  String _formatImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http') && !url.contains('localhost') && !url.contains('127.0.0.1')) return url;
    String host = kIsWeb ? "localhost" : "10.0.2.2";
    if (url.contains('localhost') || url.contains('127.0.0.1')) {
      try { return "http://$host:9000${Uri.parse(url).path}"; } catch (_) {}
    }
    if (!url.startsWith('storage/') && !url.startsWith('/storage/')) {
      return "http://$host:9000/storage/$url";
    }
    return "http://$host:9000/${url.startsWith('/') ? url.substring(1) : url}";
  }
}