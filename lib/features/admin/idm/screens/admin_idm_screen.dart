import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_idm_provider.dart';

class AdminIdmScreen extends ConsumerStatefulWidget {
  const AdminIdmScreen({super.key});

  @override
  ConsumerState<AdminIdmScreen> createState() => _AdminIdmScreenState();
}

class _AdminIdmScreenState extends ConsumerState<AdminIdmScreen> {
  String _viewMode = 'list';
  Map<String, dynamic>? _selectedItem;

  // Controllers Form
  final _tahunController = TextEditingController();
  final _scoreController = TextEditingController();
  final _sosialController = TextEditingController();
  final _ekonomiController = TextEditingController();
  final _lingkunganController = TextEditingController();
  String _statusIdm = 'Berkembang';

  final List<String> _statusOptions = [
    "Sangat Tertinggal",
    "Tertinggal",
    "Berkembang",
    "Maju",
    "Mandiri",
  ];

  @override
  void dispose() {
    _tahunController.dispose();
    _scoreController.dispose();
    _sosialController.dispose();
    _ekonomiController.dispose();
    _lingkunganController.dispose();
    super.dispose();
  }

  void _openAddForm() {
    setState(() {
      _selectedItem = null;
      _tahunController.text = DateTime.now().year.toString();
      _statusIdm = 'Berkembang';
      _scoreController.text = '0';
      _sosialController.text = '0';
      _ekonomiController.text = '0';
      _lingkunganController.text = '0';
      _viewMode = 'form';
    });
  }

  void _openEditForm(Map<String, dynamic> item) {
    setState(() {
      _selectedItem = item;
      _tahunController.text = item['tahun_idm']?.toString() ?? '';
      _statusIdm = item['status_idm'] ?? 'Berkembang';
      _scoreController.text = item['score_idm']?.toString() ?? '0';
      _sosialController.text = item['sosial_idm']?.toString() ?? '0';
      _ekonomiController.text = item['ekonomi_idm']?.toString() ?? '0';
      _lingkunganController.text = item['lingkungan_idm']?.toString() ?? '0';
      _viewMode = 'form';
    });
  }

  Future<void> _handleSave() async {
    if (_tahunController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tahun IDM wajib diisi!')));
      return;
    }

    final payload = {
      'tahun_idm': int.tryParse(_tahunController.text.trim()) ?? DateTime.now().year,
      'status_idm': _statusIdm,
      'score_idm': double.tryParse(_scoreController.text.trim()) ?? 0.0,
      'sosial_idm': double.tryParse(_sosialController.text.trim()) ?? 0.0,
      'ekonomi_idm': double.tryParse(_ekonomiController.text.trim()) ?? 0.0,
      'lingkungan_idm': double.tryParse(_lingkunganController.text.trim()) ?? 0.0,
    };

    await ref.read(adminIdmControllerProvider).saveIdm(payload, _selectedItem?['id']?.toString());

    if (mounted) {
      final controller = ref.read(adminIdmControllerProvider);
      if (controller.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(controller.errorMessage!), backgroundColor: Colors.red));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data IDM berhasil disimpan!'), backgroundColor: Colors.green));
        ref.invalidate(adminIdmListProvider);
        setState(() => _viewMode = 'list');
      }
    }
  }

  Future<void> _confirmDelete(String id, String tahun) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data IDM?'),
        content: Text('Yakin ingin menghapus data IDM Tahun $tahun?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(adminIdmControllerProvider).deleteIdm(id);
      if (mounted) {
        final controller = ref.read(adminIdmControllerProvider);
        if (controller.errorMessage == null) {
          ref.invalidate(adminIdmListProvider);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil dihapus!'), backgroundColor: Colors.green));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(controller.errorMessage!), backgroundColor: Colors.red));
        }
      }
    }
  }

  // Taktik Warna Status (Mirip getStatusColor di React)
  Color _getStatusColor(String status) {
    switch (status) {
      case "Mandiri": return Colors.green;
      case "Maju": return Colors.blue;
      case "Berkembang": return Colors.orange;
      case "Tertinggal": return Colors.deepOrange;
      case "Sangat Tertinggal": return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(adminIdmControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(_viewMode == 'list' ? 'Kelola Skor IDM' : (_selectedItem == null ? 'Input IDM Baru' : 'Edit IDM')),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF064E3B), // teal-900
        elevation: 0,
        leading: _viewMode == 'form'
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _viewMode = 'list'))
            : null,
      ),
      body: _viewMode == 'list' ? _buildList() : _buildForm(isLoading),
      floatingActionButton: _viewMode == 'list'
          ? FloatingActionButton.extended(
        onPressed: _openAddForm,
        backgroundColor: const Color(0xFF10B981), // green-500
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Input Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      )
          : null,
    );
  }

  // ─── DAFTAR IDM ───
  Widget _buildList() {
    final idmAsync = ref.watch(adminIdmListProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(adminIdmListProvider),
      child: idmAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Gagal memuat data: $err')),
        data: (listData) {
          if (listData.isEmpty) return const Center(child: Text('Belum ada data IDM.'));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: listData.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = listData[index];
              final statusColor = _getStatusColor(item['status_idm'] ?? '');

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
                            child: Text(item['tahun_idm']?.toString() ?? '', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.teal.shade900)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: statusColor.withOpacity(0.3))),
                                  child: Text(item['status_idm'] ?? '-', style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(height: 4),
                                Text('Skor Akhir: ${item['score_idm'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ),
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert, color: Colors.grey),
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))])),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') _openEditForm(item);
                              if (value == 'delete') _confirmDelete(item['id'].toString(), item['tahun_idm'].toString());
                            },
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMiniScore('IKS (Sosial)', item['sosial_idm']),
                          _buildMiniScore('IKE (Ekonomi)', item['ekonomi_idm']),
                          _buildMiniScore('IKL (Lingkungan)', item['lingkungan_idm']),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMiniScore(String label, dynamic value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value?.toString() ?? '0', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
      ],
    );
  }

  // ─── FORM INPUT IDM ───
  Widget _buildForm(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.teal.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Informasi Dasar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(),
                const SizedBox(height: 8),
                const Text('Tahun IDM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _tahunController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Contoh: 2026'),
                ),
                const SizedBox(height: 16),
                const Text('Status Desa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12), color: Colors.grey.shade50),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _statusIdm,
                      isExpanded: true,
                      items: _statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setState(() => _statusIdm = val!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Skor Akhir IDM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _scoreController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration('0.xxxx'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Indeks Komposit Pembentuk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(),
                const SizedBox(height: 8),
                const Text('IKS (Sosial)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _sosialController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration('0.xxxx'),
                ),
                const SizedBox(height: 16),
                const Text('IKE (Ekonomi)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _ekonomiController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration('0.xxxx'),
                ),
                const SizedBox(height: 16),
                const Text('IKL (Lingkungan)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _lingkunganController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration('0.xxxx'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_selectedItem == null ? 'Simpan Data Baru' : 'Simpan Perubahan', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }
}