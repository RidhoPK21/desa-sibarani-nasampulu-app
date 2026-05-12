import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/kegiatan_model.dart';
import '../../../features/kegiatan/providers/kegiatan_provider.dart';
import '../../../shared/layouts/admin_layout.dart';

class KegiatanAdminScreen extends ConsumerStatefulWidget {
  const KegiatanAdminScreen({super.key});

  @override
  ConsumerState<KegiatanAdminScreen> createState() => _KegiatanAdminScreenState();
}

class _KegiatanAdminScreenState extends ConsumerState<KegiatanAdminScreen> {
  @override
  Widget build(BuildContext context) {
    final kegiatanState = ref.watch(kegiatanProvider);

    return AdminLayout(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Kegiatan Desa',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Kegiatan'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (kegiatanState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (kegiatanState.error != null)
              Center(
                child: Text(
                  kegiatanState.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: kegiatanState.kegiatans.length,
                  itemBuilder: (context, index) {
                    final kegiatan = kegiatanState.kegiatans[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(kegiatan.nama),
                        subtitle: Text('${kegiatan.tanggal} - ${kegiatan.deskripsi}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showAddEditDialog(context, ref, kegiatan: kegiatan),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _showDeleteDialog(context, ref, kegiatan.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, WidgetRef ref, {KegiatanModel? kegiatan}) {
    final isEditing = kegiatan != null;
    final namaController = TextEditingController(text: kegiatan?.nama ?? '');
    final tanggalController = TextEditingController(text: kegiatan?.tanggal ?? '');
    final deskripsiController = TextEditingController(text: kegiatan?.deskripsi ?? '');
    final lokasiController = TextEditingController(text: kegiatan?.lokasi ?? '');
    final penyelenggaraController = TextEditingController(text: kegiatan?.penyelenggara ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Kegiatan' : 'Tambah Kegiatan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Kegiatan'),
              ),
              TextField(
                controller: tanggalController,
                decoration: const InputDecoration(labelText: 'Tanggal'),
              ),
              TextField(
                controller: deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
              ),
              TextField(
                controller: lokasiController,
                decoration: const InputDecoration(labelText: 'Lokasi'),
              ),
              TextField(
                controller: penyelenggaraController,
                decoration: const InputDecoration(labelText: 'Penyelenggara'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newKegiatan = KegiatanModel(
                id: kegiatan?.id ?? '',
                nama: namaController.text,
                tanggal: tanggalController.text,
                deskripsi: deskripsiController.text,
                lokasi: lokasiController.text.isEmpty ? null : lokasiController.text,
                penyelenggara: penyelenggaraController.text.isEmpty ? null : penyelenggaraController.text,
              );

              if (isEditing) {
                await ref.read(kegiatanProvider.notifier).updateKegiatan(kegiatan!.id, newKegiatan);
              } else {
                await ref.read(kegiatanProvider.notifier).addKegiatan(newKegiatan);
              }

              if (!mounted) return;
              Navigator.of(context).pop();
            },
            child: Text(isEditing ? 'Update' : 'Tambah'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kegiatan'),
        content: const Text('Apakah Anda yakin ingin menghapus kegiatan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(kegiatanProvider.notifier).deleteKegiatan(id);
              if (!mounted) return;
              Navigator.of(context).pop();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}