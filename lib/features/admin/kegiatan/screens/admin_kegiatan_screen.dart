import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import '../providers/admin_kegiatan_provider.dart';

class AdminKegiatanScreen extends ConsumerStatefulWidget {
  const AdminKegiatanScreen({super.key});

  @override
  ConsumerState<AdminKegiatanScreen> createState() => _AdminKegiatanScreenState();
}

class _AdminKegiatanScreenState extends ConsumerState<AdminKegiatanScreen> {
  String _viewMode = 'list';
  Map<String, dynamic>? _selectedItem;

  // Controller & State Form
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();

  String _jenisKegiatan = 'kegiatan kerja';
  String _statusKegiatan = 'Akan Datang';
  DateTime? _tanggalPelaksana;
  DateTime? _tanggalBerakhir;
  PlatformFile? _selectedImage;

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  // Helper Format URL Gambar (Localhost ke Emulator)
  String _formatImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http') && !url.contains('localhost') && !url.contains('127.0.0.1')) return url;
    String host = kIsWeb ? "localhost" : "10.0.2.2";
    if (url.contains('localhost') || url.contains('127.0.0.1')) {
      try { return "http://$host:9000${Uri.parse(url).path}"; } catch (_) {}
    }
    return "http://$host:9000/${url.startsWith('/') ? url.substring(1) : url}";
  }

  void _openAddForm() {
    setState(() {
      _selectedItem = null;
      _jenisKegiatan = 'kegiatan kerja';
      _judulController.clear();
      _deskripsiController.clear();
      _tanggalPelaksana = null;
      _tanggalBerakhir = null;
      _statusKegiatan = 'Akan Datang';
      _selectedImage = null;
      _viewMode = 'form';
    });
  }

  void _openEditForm(Map<String, dynamic> item) {
    setState(() {
      _selectedItem = item;
      _jenisKegiatan = item['jenis_kegiatan'] ?? 'kegiatan kerja';
      _judulController.text = item['judul_kegiatan'] ?? '';
      _deskripsiController.text = item['deskripsi_kegiatan'] ?? '';
      _statusKegiatan = item['status_kegiatan'] ?? 'Akan Datang';

      try {
        _tanggalPelaksana = item['tanggal_pelaksana'] != null ? DateTime.parse(item['tanggal_pelaksana'].toString().split(' ')[0]) : null;
        _tanggalBerakhir = item['tanggal_berakhir'] != null ? DateTime.parse(item['tanggal_berakhir'].toString().split(' ')[0]) : null;
      } catch (_) {}

      _selectedImage = null;
      _viewMode = 'form';
    });
  }

  // Buka Pemilih Tanggal
  Future<void> _selectDate(BuildContext context, bool isPelaksana) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isPelaksana) {
          _tanggalPelaksana = picked;
        } else {
          _tanggalBerakhir = picked;
        }
      });
    }
  }

  // Pilih Gambar Poster
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Khusus gambar
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedImage = result.files.first;
      });
    }
  }

  Future<void> _handleSave() async {
    if (_judulController.text.trim().isEmpty || _tanggalPelaksana == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul dan Tanggal Pelaksana wajib diisi!')));
      return;
    }

    final datePelaksanaFormat = DateFormat('yyyy-MM-dd').format(_tanggalPelaksana!);
    final dateBerakhirFormat = _tanggalBerakhir != null ? DateFormat('yyyy-MM-dd').format(_tanggalBerakhir!) : '';

    await ref.read(adminKegiatanControllerProvider).saveKegiatan(
      id: _selectedItem?['id']?.toString(),
      jenisKegiatan: _jenisKegiatan,
      judulKegiatan: _judulController.text.trim(),
      deskripsiKegiatan: _deskripsiController.text.trim(),
      tanggalPelaksana: datePelaksanaFormat,
      tanggalBerakhir: dateBerakhirFormat,
      statusKegiatan: _statusKegiatan,
      gambar: _selectedImage,
    );

    if (mounted) {
      final controller = ref.read(adminKegiatanControllerProvider);
      if (controller.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(controller.errorMessage!), backgroundColor: Colors.red));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kegiatan berhasil disimpan!'), backgroundColor: Colors.green));
        ref.invalidate(adminKegiatanProvider);
        setState(() => _viewMode = 'list');
      }
    }
  }

  Future<void> _confirmDelete(String id, String judul) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kegiatan?'),
        content: Text('Yakin ingin menghapus kegiatan "$judul"?'),
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
      await ref.read(adminKegiatanControllerProvider).deleteKegiatan(id);
      if (mounted) {
        final controller = ref.read(adminKegiatanControllerProvider);
        if (controller.errorMessage == null) {
          ref.invalidate(adminKegiatanProvider);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kegiatan berhasil dihapus!'), backgroundColor: Colors.green));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(controller.errorMessage!), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(adminKegiatanControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(_viewMode == 'list' ? 'Kelola Kegiatan Desa' : (_selectedItem == null ? 'Tambah Kegiatan' : 'Edit Kegiatan')),
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
        backgroundColor: const Color(0xFF10B981), // emerald-500
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Kegiatan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      )
          : null,
    );
  }

  // ─── TAMPILAN MODE DAFTAR (LIST) ───
  Widget _buildList() {
    final kegiatanAsync = ref.watch(adminKegiatanProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(adminKegiatanProvider),
      child: kegiatanAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Gagal memuat data: $err')),
        data: (kegiatanList) {
          if (kegiatanList.isEmpty) {
            return const Center(child: Text('Belum ada data kegiatan.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: kegiatanList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = kegiatanList[index];

              // Tentukan Warna Status
              Color statusBgColor = Colors.blue.shade50;
              Color statusTextColor = Colors.blue.shade700;
              if (item['status_kegiatan'] == 'Selesai') {
                statusBgColor = Colors.green.shade50;
                statusTextColor = Colors.green.shade700;
              } else if (item['status_kegiatan'] == 'Batal') {
                statusBgColor = Colors.red.shade50;
                statusTextColor = Colors.red.shade700;
              }

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail Gambar
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                        clipBehavior: Clip.antiAlias,
                        child: item['gambar_url'] != null
                            ? Image.network(_formatImageUrl(item['gambar_url']), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.grey))
                            : const Icon(Icons.image, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      // Info Teks
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['jenis_kegiatan'] ?? '', style: TextStyle(color: Colors.teal.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(item['judul_kegiatan'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(item['tanggal_pelaksana']?.toString().split(' ')[0] ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(12)),
                                  child: Text(item['status_kegiatan'] ?? '-', style: TextStyle(color: statusTextColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Aksi
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))])),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') _openEditForm(item);
                          if (value == 'delete') _confirmDelete(item['id'].toString(), item['judul_kegiatan']);
                        },
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

  // ─── TAMPILAN MODE FORM ───
  Widget _buildForm(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // DROPDOWN JENIS KEGIATAN
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Jenis Kegiatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12), color: Colors.white),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _jenisKegiatan,
                          isExpanded: true,
                          items: ['kegiatan kerja', 'program kerja', 'bantuan sosial'].map((j) => DropdownMenuItem(value: j, child: Text(j))).toList(),
                          onChanged: (val) => setState(() => _jenisKegiatan = val!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // DROPDOWN STATUS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Status Kegiatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12), color: Colors.white),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _statusKegiatan,
                          isExpanded: true,
                          items: ['Akan Datang', 'Berlangsung', 'Selesai', 'Batal'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (val) => setState(() => _statusKegiatan = val!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // NAMA KEGIATAN
          const Text('Judul Kegiatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _judulController,
            decoration: InputDecoration(
              hintText: 'Contoh: Gotong Royong Desa',
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
          const SizedBox(height: 16),

          // DESKRIPSI
          const Text('Deskripsi Kegiatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _deskripsiController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Tuliskan keterangan detail kegiatan...',
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
          const SizedBox(height: 16),

          // TANGGAL
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tgl Pelaksana', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12), color: Colors.white),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_tanggalPelaksana != null ? DateFormat('yyyy-MM-dd').format(_tanggalPelaksana!) : 'Pilih Tanggal', style: TextStyle(color: _tanggalPelaksana != null ? Colors.black87 : Colors.grey)),
                            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tgl Berakhir (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12), color: Colors.white),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_tanggalBerakhir != null ? DateFormat('yyyy-MM-dd').format(_tanggalBerakhir!) : 'Pilih Tanggal', style: TextStyle(color: _tanggalBerakhir != null ? Colors.black87 : Colors.grey)),
                            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // UPLOAD GAMBAR
          const Text('Upload Poster / Gambar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickImage,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
                    ? Image.memory(_selectedImage!.bytes!, fit: BoxFit.cover, width: double.infinity) // Preview Web
                    : const Center(child: Text("Gambar terpilih", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold))), // Preview Android/iOS
              )
                  : (_selectedItem != null && _selectedItem!['gambar_url'] != null)
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(_formatImageUrl(_selectedItem!['gambar_url']), fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50, color: Colors.grey)),
              )
                  : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Klik untuk memilih gambar', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // TOMBOL SIMPAN
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
                  : Text(_selectedItem == null ? 'Simpan Kegiatan' : 'Simpan Perubahan', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}