import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:url_launcher/url_launcher.dart';

import '../providers/admin_ppid_provider.dart';

class AdminPpidScreen extends ConsumerStatefulWidget {
  const AdminPpidScreen({super.key});

  @override
  ConsumerState<AdminPpidScreen> createState() => _AdminPpidScreenState();
}

class _AdminPpidScreenState extends ConsumerState<AdminPpidScreen> {
  String _viewMode = 'list';
  Map<String, dynamic>? _selectedItem;

  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  String _jenisPpid = 'Informasi Berkala';
  fp.PlatformFile? _selectedFile;

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  void _openAddForm() {
    setState(() {
      _selectedItem = null;
      _namaController.clear();
      _deskripsiController.clear();
      _jenisPpid = 'Informasi Berkala';
      _selectedFile = null;
      _viewMode = 'form';
    });
  }

  void _openEditForm(Map<String, dynamic> item) {
    setState(() {
      _selectedItem = item;
      _namaController.text = item['nama_ppid'] ?? '';
      _deskripsiController.text = item['deskripsi_ppid'] ?? '';
      _jenisPpid = item['jenis_ppid'] ?? 'Informasi Berkala';
      _selectedFile = null;
      _viewMode = 'form';
    });
  }

  Future<void> _pickFile() async {
    fp.FilePickerResult? result = await fp.FilePicker.platform.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _handleSave() async {
    if (_namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dokumen wajib diisi!')),
      );
      return;
    }

    await ref.read(adminPpidControllerProvider).saveDokumen(
      id: _selectedItem?['id']?.toString(),
      nama: _namaController.text.trim(),
      jenis: _jenisPpid,
      deskripsi: _deskripsiController.text.trim(),
      file: _selectedFile,
    );

    if (mounted) {
      final controller = ref.read(adminPpidControllerProvider);
      if (controller.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dokumen berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(adminDokumenProvider);
        setState(() => _viewMode = 'list');
      }
    }
  }

  Future<void> _confirmDelete(String id, String nama) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Dokumen?'),
        content: Text('Yakin ingin menghapus dokumen "$nama"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(adminPpidControllerProvider).deleteDokumen(id);
      if (mounted) {
        final controller = ref.read(adminPpidControllerProvider);
        if (controller.errorMessage == null) {
          ref.invalidate(adminDokumenProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dokumen berhasil dihapus!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(controller.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(adminPpidControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          _viewMode == 'list'
              ? 'Kelola PPID Desa'
              : (_selectedItem == null ? 'Tambah Dokumen Baru' : 'Edit Dokumen'),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF064E3B),
        elevation: 0,
        leading: _viewMode == 'form'
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _viewMode = 'list'),
        )
            : null,
      ),
      body: _viewMode == 'list' ? _buildList() : _buildForm(isLoading),
      floatingActionButton: _viewMode == 'list'
          ? FloatingActionButton.extended(
        onPressed: _openAddForm,
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Dokumen',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      )
          : null,
    );
  }

  Widget _buildList() {
    final dokumenAsync = ref.watch(adminDokumenProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(adminDokumenProvider),
      child: dokumenAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Gagal memuat data: $err')),
        data: (dokumen) {
          if (dokumen.isEmpty) {
            return const Center(child: Text('Belum ada dokumen PPID.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: dokumen.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = dokumen[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item['jenis_ppid'] ?? '',
                                    style: TextStyle(
                                      color: Colors.teal.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['nama_ppid'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert, color: Colors.grey),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 18),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 18, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Hapus', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') _openEditForm(item);
                              if (value == 'delete') {
                                _confirmDelete(
                                  item['id'].toString(),
                                  item['nama_ppid'],
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['deskripsi_ppid'] ?? 'Tidak ada deskripsi',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['tanggal_upload']?.toString().split(' ')[0] ?? '-',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          if (item['file_url'] != null)
                            TextButton.icon(
                              onPressed: () => launchUrl(Uri.parse(item['file_url'])),
                              icon: const Icon(Icons.download, size: 16),
                              label: const Text(
                                'Unduh File',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
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

  Widget _buildForm(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Jenis PPID',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _jenisPpid,
                isExpanded: true,
                items: ['Informasi Berkala', 'Informasi Serta Merta', 'Informasi Setiap Saat']
                    .map((jenis) => DropdownMenuItem(value: jenis, child: Text(jenis)))
                    .toList(),
                onChanged: (val) => setState(() => _jenisPpid = val!),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Nama / Judul Dokumen',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _namaController,
            decoration: InputDecoration(
              hintText: 'Contoh: Laporan APBDes 2026',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Deskripsi (Opsional)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _deskripsiController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Tuliskan keterangan singkat...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Upload File Dokumen',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickFile,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.upload_file, size: 40, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    _selectedFile != null
                        ? _selectedFile!.name
                        : (_selectedItem != null && _selectedItem!['file_url'] != null
                        ? 'Dokumen sudah terunggah (Pilih baru untuk mengganti)'
                        : 'Klik untuk memilih file'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _selectedFile != null
                          ? Colors.teal.shade700
                          : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'PDF, DOC, XLS (Max 5MB)',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text(
                _selectedItem == null ? 'Simpan Dokumen' : 'Simpan Perubahan',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}