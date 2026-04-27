// lib/features/public/kegiatan/screens/kegiatan_screen.dart
//
// Halaman Kegiatan untuk masyarakat umum - Desa Sibarani Nasampulu
// Terdiri dari 3 sub-tab: Daftar Kegiatan Desa, Daftar Program Kerja, Daftar Bantuan Sosial

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';

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
        judul: json['judul'] ?? json['nama'] ?? json['title'] ?? 'Tanpa Judul',
        keterangan: json['keterangan'] ??
            json['deskripsi'] ??
            json['description'] ??
            '',
        gambar: json['gambar'] ?? json['foto'] ?? json['image'],
        tanggal: json['tanggal'] ?? json['created_at'],
        status: json['status'],
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
        nama: json['nama'] ?? json['judul'] ?? json['title'] ?? 'Tanpa Nama',
        keterangan: json['keterangan'] ?? json['deskripsi'] ?? '',
        gambar: json['gambar'] ?? json['foto'] ?? json['image'],
        tahun: json['tahun']?.toString(),
        status: json['status'],
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
        nama: json['nama'] ?? json['judul'] ?? 'Tanpa Nama',
        keterangan: json['keterangan'] ?? json['deskripsi'] ?? '',
        gambar: json['gambar'] ?? json['foto'] ?? json['image'],
        jenis: json['jenis'] ?? json['tipe'],
        penerima: json['penerima']?.toString() ?? json['jumlah_penerima']?.toString(),
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
      // Endpoint kegiatan — sesuaikan dengan route backend Laravel Anda
      final response = await api.get('/content/kegiatan');
      final list = _extractList(response.data);
      if (!mounted) return;
      setState(() {
        _items = list
            .whereType<Map>()
            .map((e) => KegiatanModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _loading = false;
      });
    } on DioException catch (_) {
      if (!mounted) return;
      // Fallback: tampilkan data dummy agar UI tetap terlihat
      setState(() {
        _items = _dummyKegiatan();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data kegiatan.';
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
        _SectionTitle(
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
      final response = await api.get('/content/program-kerja');
      final list = _extractList(response.data);
      if (!mounted) return;
      setState(() {
        _items = list
            .whereType<Map>()
            .map((e) =>
                ProgramKerjaModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _loading = false;
      });
    } on DioException catch (_) {
      if (!mounted) return;
      setState(() {
        _items = _dummyProgramKerja();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data program kerja.';
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
        _SectionTitle(
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
      final response = await api.get('/content/bantuan-sosial');
      final list = _extractList(response.data);
      if (!mounted) return;
      setState(() {
        _items = list
            .whereType<Map>()
            .map((e) =>
                BantuanSosialModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _loading = false;
      });
    } on DioException catch (_) {
      if (!mounted) return;
      setState(() {
        _items = _dummyBantuanSosial();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data bantuan sosial.';
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
        _SectionTitle(
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
        onTap: () => _showDetail(context),
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
                          Icon(
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

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _KegiatanDetailSheet(item: item),
    );
  }
}

class _KegiatanImage extends StatelessWidget {
  final String? gambar;

  const _KegiatanImage({this.gambar});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 110,
        height: 90,
        child: gambar != null && gambar!.isNotEmpty
            ? Image.network(
                gambar!,
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
      case 'sedang berjalan':
        return const Color(0xFF1D4ED8);
      case 'belum dimulai':
      case 'rencana':
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 110,
        height: 90,
        child: gambar != null && gambar!.isNotEmpty
            ? Image.network(
                gambar!,
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

  const _KegiatanDetailSheet({required this.item});

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
                    if (item.gambar != null && item.gambar!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          item.gambar!,
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
              decoration: BoxDecoration(
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

// ─── Helpers ─────────────────────────────────────────────────────────────────

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

// ─── Dummy Data (Fallback saat API belum tersedia) ────────────────────────────

List<KegiatanModel> _dummyKegiatan() => [
      const KegiatanModel(
        id: '1',
        judul: 'Musyawarah Desa (Musdes)',
        keterangan:
            'Musyawarah desa membahas rencana pembangunan desa tahun 2025 dan evaluasi kegiatan tahun sebelumnya bersama seluruh perangkat desa dan tokoh masyarakat.',
        tanggal: '2025-03-15',
      ),
      const KegiatanModel(
        id: '2',
        judul: 'Gotong Royong Bersih Desa',
        keterangan:
            'Kegiatan gotong royong rutin setiap bulan untuk membersihkan lingkungan desa, jalan, dan fasilitas umum bersama warga.',
        tanggal: '2025-04-10',
      ),
      const KegiatanModel(
        id: '3',
        judul: 'Posyandu Balita & Lansia',
        keterangan:
            'Kegiatan posyandu rutin bulanan untuk pemeriksaan kesehatan balita dan lansia di Desa Sibarani Nasampulu.',
        tanggal: '2025-04-20',
      ),
    ];

List<ProgramKerjaModel> _dummyProgramKerja() => [
      const ProgramKerjaModel(
        id: '1',
        nama: 'Pembangunan Jalan Desa',
        keterangan:
            'Program pembangunan dan perbaikan jalan desa sepanjang 2 km untuk memperlancar akses transportasi warga.',
        tahun: '2025',
        status: 'Berjalan',
      ),
      const ProgramKerjaModel(
        id: '2',
        nama: 'Pelatihan Kewirausahaan',
        keterangan:
            'Program pelatihan kewirausahaan bagi pemuda desa untuk meningkatkan kemampuan dan kemandirian ekonomi.',
        tahun: '2025',
        status: 'Rencana',
      ),
      const ProgramKerjaModel(
        id: '3',
        nama: 'Pengelolaan Sampah Organik',
        keterangan:
            'Program pengelolaan sampah organik menjadi pupuk kompos untuk mendukung pertanian warga dan kebersihan desa.',
        tahun: '2024',
        status: 'Selesai',
      ),
    ];

List<BantuanSosialModel> _dummyBantuanSosial() => [
      const BantuanSosialModel(
        id: '1',
        nama: 'BLT Dana Desa',
        keterangan:
            'Penyaluran Bantuan Langsung Tunai Dana Desa kepada keluarga penerima manfaat di Desa Sibarani Nasampulu.',
        jenis: 'Tunai',
        penerima: '45',
      ),
      const BantuanSosialModel(
        id: '2',
        nama: 'Program Keluarga Harapan (PKH)',
        keterangan:
            'Bantuan sosial bersyarat bagi keluarga kurang mampu untuk meningkatkan akses pendidikan dan kesehatan.',
        jenis: 'Bersyarat',
        penerima: '32',
      ),
      const BantuanSosialModel(
        id: '3',
        nama: 'Bantuan Pangan Non Tunai (BPNT)',
        keterangan:
            'Bantuan pangan berupa beras, telur, dan bahan kebutuhan pokok yang disalurkan kepada keluarga penerima manfaat.',
        jenis: 'Pangan',
        penerima: '58',
      ),
    ];