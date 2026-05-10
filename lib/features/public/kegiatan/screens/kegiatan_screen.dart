// lib/features/public/kegiatan/screens/kegiatan_screen.dart
// Halaman Kegiatan untuk masyarakat umum - Desa Sibarani Nasampulu

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Wajib untuk kIsWeb
import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';

// 🔥 KELAS PENYELAMAT: Pengganti AppColors yang hilang
class AppColors {
  static const Color primary = Color(0xFF4EA674);
  static const Color primarySurface = Color(0xFFE8F5E9);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
}

// ─── Model ───────────────────────────────────────────────────────────────────

class KegiatanModel {
  final String id;
  final String judul;
  final String keterangan;
  final String? gambar;
  final String? tanggal;
  final String? status;

  const KegiatanModel({
    required this.id,
    required this.judul,
    required this.keterangan,
    this.gambar,
    this.tanggal,
    this.status,
  });

  factory KegiatanModel.fromJson(Map<String, dynamic> json) => KegiatanModel(
    id: '${json['id'] ?? ''}',
    // 🔥 Menggunakan key dari Laravel
    judul: json['judul_kegiatan'] ?? json['judul'] ?? json['nama'] ?? 'Tanpa Judul',
    keterangan: json['deskripsi_kegiatan'] ?? json['keterangan'] ?? json['deskripsi'] ?? '',
    gambar: json['gambar_url'] ?? json['gambar'],
    tanggal: json['tanggal_pelaksana'] ?? json['tanggal'] ?? json['created_at'],
    status: json['status_kegiatan'] ?? json['status'],
  );
}

class ProgramKerjaModel {
  final String id;
  final String nama;
  final String keterangan;
  final String? gambar;
  final String? tahun;
  final String? status;

  const ProgramKerjaModel({
    required this.id,
    required this.nama,
    required this.keterangan,
    this.gambar,
    this.tahun,
    this.status,
  });

  factory ProgramKerjaModel.fromJson(Map<String, dynamic> json) =>
      ProgramKerjaModel(
        id: '${json['id'] ?? ''}',
        nama: json['judul_kegiatan'] ?? json['nama'] ?? json['judul'] ?? 'Tanpa Nama',
        keterangan: json['deskripsi_kegiatan'] ?? json['keterangan'] ?? json['deskripsi'] ?? '',
        gambar: json['gambar_url'] ?? json['gambar'],
        // Mengambil 4 digit pertama dari tanggal_pelaksana untuk mendapatkan tahun
        tahun: json['tanggal_pelaksana'] != null
            ? json['tanggal_pelaksana'].toString().substring(0, 4)
            : json['tahun']?.toString(),
        status: json['status_kegiatan'] ?? json['status'],
      );
}

class BantuanSosialModel {
  final String id;
  final String nama;
  final String keterangan;
  final String? gambar;
  final String? jenis;
  final String? penerima;

  const BantuanSosialModel({
    required this.id,
    required this.nama,
    required this.keterangan,
    this.gambar,
    this.jenis,
    this.penerima,
  });

  factory BantuanSosialModel.fromJson(Map<String, dynamic> json) =>
      BantuanSosialModel(
        id: '${json['id'] ?? ''}',
        nama: json['judul_kegiatan'] ?? json['nama'] ?? json['judul'] ?? 'Tanpa Nama',
        keterangan: json['deskripsi_kegiatan'] ?? json['keterangan'] ?? json['deskripsi'] ?? '',
        gambar: json['gambar_url'] ?? json['gambar'],
        jenis: json['jenis_kegiatan'] ?? json['jenis'] ?? json['tipe'],
        penerima: json['jumlah_penerima']?.toString() ?? json['penerima']?.toString(),
      );
}

// ─── Main Screen ─────────────────────────────────────────────────────────────

class KegiatanScreen extends StatefulWidget {
  const KegiatanScreen({super.key});

  @override
  State<KegiatanScreen> createState() => _KegiatanScreenState();
}

class _KegiatanScreenState extends State<KegiatanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Sub-Tab Bar ──────────────────────────────────────────────
        Container(
          color: AppColors.primary,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: Colors.white,
            indicatorWeight: 2.5,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            dividerColor: Colors.white24,
            tabs: const [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_rounded, size: 16),
                    SizedBox(width: 6),
                    Text('Daftar Kegiatan Desa'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.task_alt_rounded, size: 16),
                    SizedBox(width: 6),
                    Text('Daftar Program Kerja'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.volunteer_activism_rounded, size: 16),
                    SizedBox(width: 6),
                    Text('Daftar Bantuan Sosial'),
                  ],
                ),
              ),
            ],
          ),
        ),
        // ── Tab Content ──────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _DaftarKegiatanTab(),
              _DaftarProgramKerjaTab(),
              _DaftarBantuanSosialTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Tab 1: Daftar Kegiatan Desa ─────────────────────────────────────────────

class _DaftarKegiatanTab extends StatefulWidget {
  const _DaftarKegiatanTab();

  @override
  State<_DaftarKegiatanTab> createState() => _DaftarKegiatanTabState();
}

class _DaftarKegiatanTabState extends State<_DaftarKegiatanTab>
    with AutomaticKeepAliveClientMixin {
  bool _loading = true;
  String? _error;
  List<KegiatanModel> _items = const [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // 🔥 Menembak 1 URL Utama
      final response = await api.get('/info/kegiatan');
      final list = _extractList(response.data);
      if (!mounted) return;

      setState(() {
        _items = list
            .whereType<Map>()
        // 🔥 Memfilter hanya untuk Tab Kegiatan
            .where((e) => e['jenis_kegiatan'] == 'kegiatan kerja')
            .map((e) => KegiatanModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data. Periksa koneksi API.\n(${e.toString()})';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _loadData);
    }
    if (_items.isEmpty) {
      return const _EmptyState(message: 'Belum ada kegiatan desa.');
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionTitle(
          title: 'Kegiatan Desa',
          subtitle: 'Informasi kegiatan yang telah & akan dilaksanakan',
          icon: Icons.event_rounded,
        ),
        const SizedBox(height: 12),
        ..._items.map((item) => _KegiatanCard(item: item)),
      ],
    );
  }
}

// ─── Tab 2: Daftar Program Kerja ─────────────────────────────────────────────

class _DaftarProgramKerjaTab extends StatefulWidget {
  const _DaftarProgramKerjaTab();

  @override
  State<_DaftarProgramKerjaTab> createState() => _DaftarProgramKerjaTabState();
}

class _DaftarProgramKerjaTabState extends State<_DaftarProgramKerjaTab>
    with AutomaticKeepAliveClientMixin {
  bool _loading = true;
  String? _error;
  List<ProgramKerjaModel> _items = const [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // 🔥 Menembak 1 URL Utama
      final response = await api.get('/info/kegiatan');
      final list = _extractList(response.data);
      if (!mounted) return;
      setState(() {
        _items = list
            .whereType<Map>()
        // 🔥 Memfilter hanya untuk Tab Program Kerja
            .where((e) => e['jenis_kegiatan'] == 'program kerja')
            .map((e) => ProgramKerjaModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data program kerja.\n(${e.toString()})';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _loadData);
    }
    if (_items.isEmpty) {
      return const _EmptyState(message: 'Belum ada program kerja.');
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionTitle(
          title: 'Program Kerja',
          subtitle: 'Rencana & realisasi program kerja desa',
          icon: Icons.task_alt_rounded,
        ),
        const SizedBox(height: 12),
        ..._items.map((item) => _ProgramKerjaCard(item: item)),
      ],
    );
  }
}

// ─── Tab 3: Daftar Bantuan Sosial ────────────────────────────────────────────

class _DaftarBantuanSosialTab extends StatefulWidget {
  const _DaftarBantuanSosialTab();

  @override
  State<_DaftarBantuanSosialTab> createState() =>
      _DaftarBantuanSosialTabState();
}

class _DaftarBantuanSosialTabState extends State<_DaftarBantuanSosialTab>
    with AutomaticKeepAliveClientMixin {
  bool _loading = true;
  String? _error;
  List<BantuanSosialModel> _items = const [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // 🔥 Menembak 1 URL Utama
      final response = await api.get('/info/kegiatan');
      final list = _extractList(response.data);
      if (!mounted) return;
      setState(() {
        _items = list
            .whereType<Map>()
        // 🔥 Memfilter hanya untuk Tab Bantuan Sosial
            .where((e) => e['jenis_kegiatan'] == 'bantuan sosial')
            .map((e) => BantuanSosialModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data bantuan sosial.\n(${e.toString()})';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _loadData);
    }
    if (_items.isEmpty) {
      return const _EmptyState(message: 'Belum ada data bantuan sosial.');
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionTitle(
          title: 'Bantuan Sosial',
          subtitle: 'Data penyaluran bantuan sosial kepada warga',
          icon: Icons.volunteer_activism_rounded,
        ),
        const SizedBox(height: 12),
        ..._items.map((item) => _BantuanSosialCard(item: item)),
      ],
    );
  }
}

// ─── Shared Widgets ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Kegiatan Card ───────────────────────────────────────────────────────────

class _KegiatanCard extends StatelessWidget {
  final KegiatanModel item;

  const _KegiatanCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetail(context, item.gambar),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Konten Teks ─────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.judul,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.keterangan,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.tanggal != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTanggal(item.tanggal!),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // ── Gambar ─────────────────────────────────────
              _KegiatanImage(gambar: item.gambar),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, String? rawGambar) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _KegiatanDetailSheet(
          item: item,
          safeUrl: _formatImageUrl(rawGambar)
      ),
    );
  }
}

class _KegiatanImage extends StatelessWidget {
  final String? gambar;

  const _KegiatanImage({this.gambar});

  @override
  Widget build(BuildContext context) {
    final String safeUrl = _formatImageUrl(gambar);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 110,
        height: 90,
        child: safeUrl.isNotEmpty
            ? Image.network(
          safeUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.primarySurface,
      child: const Icon(
        Icons.image_rounded,
        color: AppColors.primary,
        size: 36,
      ),
    );
  }
}

// ─── Program Kerja Card ───────────────────────────────────────────────────────

class _ProgramKerjaCard extends StatelessWidget {
  final ProgramKerjaModel item;

  const _ProgramKerjaCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(item.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge + nama
                  if (item.status != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: statusColor.withOpacity(0.4), width: 1),
                      ),
                      child: Text(
                        item.status!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  Text(
                    item.nama,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.keterangan,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.tahun != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded,
                            size: 12, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Tahun ${item.tahun}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            _KegiatanImage(gambar: item.gambar),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'selesai':
      case 'terlaksana':
        return const Color(0xFF15803D);
      case 'berjalan':
      case 'sedang berlangsung':
      case 'berlangsung':
        return const Color(0xFF1D4ED8);
      case 'belum dimulai':
      case 'rencana':
      case 'akan datang':
        return const Color(0xFFA16207);
      default:
        return AppColors.primary;
    }
  }
}

// ─── Bantuan Sosial Card ──────────────────────────────────────────────────────

class _BantuanSosialCard extends StatelessWidget {
  final BantuanSosialModel item;

  const _BantuanSosialCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Jenis badge
                  if (item.jenis != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE65100).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFE65100).withOpacity(0.3)),
                      ),
                      child: Text(
                        item.jenis!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ),
                  Text(
                    item.nama,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.keterangan,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.penerima != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.people_rounded,
                            size: 13, color: Color(0xFFE65100)),
                        const SizedBox(width: 4),
                        Text(
                          '${item.penerima} penerima',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFE65100),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            _BantuanImage(gambar: item.gambar),
          ],
        ),
      ),
    );
  }
}

class _BantuanImage extends StatelessWidget {
  final String? gambar;

  const _BantuanImage({this.gambar});

  @override
  Widget build(BuildContext context) {
    final String safeUrl = _formatImageUrl(gambar);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 110,
        height: 90,
        child: safeUrl.isNotEmpty
            ? Image.network(
          safeUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFE65100).withOpacity(0.08),
      child: const Icon(
        Icons.volunteer_activism_rounded,
        color: Color(0xFFE65100),
        size: 36,
      ),
    );
  }
}

// ─── Detail Bottom Sheet ─────────────────────────────────────────────────────

class _KegiatanDetailSheet extends StatelessWidget {
  final KegiatanModel item;
  final String safeUrl;

  const _KegiatanDetailSheet({required this.item, required this.safeUrl});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  children: [
                    // Gambar
                    if (safeUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          safeUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 120,
                            color: AppColors.primarySurface,
                            child: const Icon(Icons.image_rounded,
                                color: AppColors.primary, size: 48),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(Icons.event_rounded,
                              color: AppColors.primary, size: 52),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Header info
                    if (item.tanggal != null)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today_rounded,
                                    size: 12, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  _formatTanggal(item.tanggal!),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    Text(
                      item.judul,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 12),
                    Text(
                      item.keterangan.isEmpty
                          ? 'Tidak ada keterangan lebih lanjut.'
                          : item.keterangan,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded,
                  color: Colors.red.shade400, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inbox_rounded,
                  color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Global Helpers ─────────────────────────────────────────────────────────────────

List<dynamic> _extractList(dynamic data) {
  if (data is List) return data;
  if (data is Map && data['data'] is List) return data['data'] as List;
  return const [];
}

String _formatTanggal(String raw) {
  try {
    final dt = DateTime.parse(raw);
    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day} ${bulan[dt.month]} ${dt.year}';
  } catch (_) {
    return raw;
  }
}

// 🔥 Fungsi Sakti untuk Menjinakkan Gambar dari Localhost Laravel
String _formatImageUrl(String? url) {
  if (url == null || url.isEmpty) return '';

  if (url.startsWith('http') && !url.contains('localhost') && !url.contains('127.0.0.1')) {
    return url;
  }

  String host = kIsWeb ? "localhost" : "10.0.2.2";

  if (url.contains('localhost') || url.contains('127.0.0.1')) {
    try {
      return "http://$host:9000${Uri.parse(url).path}";
    } catch (_) {}
  }

  if (!url.startsWith('storage/') && !url.startsWith('/storage/')) {
    return "http://$host:9000/storage/$url";
  }

  return "http://$host:9000/${url.startsWith('/') ? url.substring(1) : url}";
}