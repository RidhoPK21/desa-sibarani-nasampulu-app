import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../providers/admin_berita_provider.dart';

class AdminBeritaScreen extends ConsumerStatefulWidget {
  const AdminBeritaScreen({super.key});

  @override
  ConsumerState<AdminBeritaScreen> createState() => _AdminBeritaScreenState();
}

class _AdminBeritaScreenState extends ConsumerState<AdminBeritaScreen> {
  String _viewMode = 'list';
  Map<String, dynamic>? _selectedItem;

  // Controllers Form
  final _judulController = TextEditingController();
  final _kontenController = TextEditingController();
  int _isPublished = 1; // 1 = Publish, 0 = Draft
  PlatformFile? _selectedImage;

  @override
  void dispose() {
    _judulController.dispose();
    _kontenController.dispose();
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
      _judulController.clear();
      _kontenController.clear();
      _isPublished = 1;
      _selectedImage = null;
      _viewMode = 'form';
    });
  }

  void _openEditForm(Map<String, dynamic> item) {
    setState(() {
      _selectedItem = item;
      _judulController.text = item['judul'] ?? '';
      _kontenController.text = item['konten'] ?? '';

      // Parse status is_published dengan aman
      if (item['is_published'] is bool) {
        _isPublished = item['is_published'] ? 1 : 0;
      } else {
        _isPublished = int.tryParse(item['is_published']?.toString() ?? '1') ?? 1;
      }

      _selectedImage = null;
      _viewMode = 'form';
    });
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedImage = result.files.first;
      });
    }
  }

  Future<void> _handleSave() async {
    if (_judulController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul berita wajib diisi!')));
      return;
    }

    await ref.read(adminBeritaControllerProvider).saveBerita(
      id: _selectedItem?['id']?.toString(),
      judul: _judulController.text.trim(),
      konten: _kontenController.text.trim(),
      isPublished: _isPublished,
      gambarUrl: _selectedImage,
    );

    if (mounted) {
      final controller = ref.read(adminBeritaControllerProvider);
      if (controller.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(controller.errorMessage!), backgroundColor: Colors.red));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berita berhasil disimpan!'), backgroundColor: Colors.green));
        ref.invalidate(adminBeritaListProvider);
        setState(() => _viewMode = 'list');
      }
    }
  }

  Future<void> _confirmDelete(String id, String judul) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Berita?'),
        content: Text('Yakin ingin menghapus berita "$judul"?'),
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
      await ref.read(adminBeritaControllerProvider).deleteBerita(id);
      if (mounted) {
        final controller = ref.read(adminBeritaControllerProvider);
        if (controller.errorMessage == null) {
          ref.invalidate(adminBeritaListProvider);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berita berhasil dihapus!'), backgroundColor: Colors.green));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(controller.errorMessage!), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(adminBeritaControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(_viewMode == 'list' ? 'Kelola Berita Desa' : (_selectedItem == null ? 'Tambah Berita' : 'Edit Berita')),
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
        backgroundColor: const Color(0xFF10B981), // emerald/teal
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Berita', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      )
          : null,
    );
  }

  // ─── TAMPILAN DAFTAR BERITA ───
  Widget _buildList() {
    final beritaAsync = ref.watch(adminBeritaListProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(adminBeritaListProvider),
      child: beritaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Gagal memuat data: $err')),
        data: (beritaList) {
          if (beritaList.isEmpty) return const Center(child: Text('Belum ada data berita.'));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: beritaList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = beritaList[index];
              final isPublished = item['is_published'] == 1 || item['is_published'] == true;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail Gambar Berita
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                        clipBehavior: Clip.antiAlias,
                        child: item['gambar_url'] != null
                            ? Image.network(_formatImageUrl(item['gambar_url']), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.grey))
                            : const Icon(Icons.image, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['judul'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 6),
                            Text(item['konten'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(item['created_at']?.toString().split('T')[0] ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: isPublished ? Colors.teal.shade50 : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12)
                                  ),
                                  child: Text(isPublished ? 'Publish' : 'Draft', style: TextStyle(color: isPublished ? Colors.teal.shade700 : Colors.grey.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
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
                          if (value == 'delete') _confirmDelete(item['id'].toString(), item['judul']);
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

  // ─── TAMPILAN FORM BERITA ───
  Widget _buildForm(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // JUDUL
          const Text('Judul Berita', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _judulController,
            decoration: InputDecoration(
              hintText: 'Masukkan judul berita...',
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
          const SizedBox(height: 16),

          // STATUS PUBLIKASI
          const Text('Status Publikasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12), color: Colors.white),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _isPublished,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 1, child: Text("Publish")),
                  DropdownMenuItem(value: 0, child: Text("Draft")),
                ],
                onChanged: (val) => setState(() => _isPublished = val!),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // KONTEN
          const Text('Isi Berita', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _kontenController,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'Tuliskan detail berita di sini...',
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
          const SizedBox(height: 24),

          // UPLOAD GAMBAR
          const Text('Upload Gambar Berita', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickImage,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
                    ? Image.memory(_selectedImage!.bytes!, fit: BoxFit.cover, width: double.infinity)
                    : const Center(child: Text("Gambar terpilih", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold))),
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
                  Text('Klik untuk memilih gambar utama berita', style: TextStyle(color: Colors.grey)),
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
                  : Text(_selectedItem == null ? 'Simpan Berita' : 'Simpan Perubahan', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}