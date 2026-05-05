import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/apbdes_model.dart';
import '../../../features/auth/providers/apbdes_provider.dart';
import '../../widgets/apbdes/apbdes_form_screen.dart';

// --- BAGIAN IMPORT (Gunakan Alt + Enter jika masih ada yang merah) ---

// --------------------------------------------------------------------

class ApbdesAdminScreen extends StatefulWidget {
  const ApbdesAdminScreen({super.key});

  @override
  State<ApbdesAdminScreen> createState() => _ApbdesAdminScreenState();
}

class _ApbdesAdminScreenState extends State<ApbdesAdminScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApbdesProvider>().fetchApbdes(); // Pastikan method di provider bernama fetchAll() atau ganti jadi fetchApbdes()
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatRupiah(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  // Perbaikan Async Gap Context
  Future<void> _goToForm({ApbdesModel? existing}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ApbdesFormScreen(existing: existing),
      ),
    );

    if (!mounted) return;
    context.read<ApbdesProvider>().fetchApbdes();
  }

  void _confirmDelete(ApbdesModel item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Yakin Menghapus APBDes?',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        content: Text(
          'Data Tahun ${item.tahun} Versi ${item.versi} akan dihapus selamanya.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Pastikan fungsi di provider adalah deleteApbdes() atau remove()
              await context.read<ApbdesProvider>().deleteApbdes(item.id!);
            },
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola APBDes'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => _goToForm(),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Buat APBDes Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Cari tahun...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Consumer<ApbdesProvider>(
              builder: (_, prov, __) {
                if (prov.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Sesuaikan 'apbdesList' dengan nama list di provider Anda
                final dataList = prov.apbdesList;

                final filtered = _searchQuery.isEmpty
                    ? dataList
                    : dataList
                    .where((e) => e.tahun.toString().contains(_searchQuery))
                    .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        const Text('Belum ada data APBDes',
                            style: TextStyle(color: AppColors.textHint)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ApbdesCard(
                    item: filtered[i],
                    formatRupiah: _formatRupiah,
                    onEdit: () => _goToForm(existing: filtered[i]),
                    onDelete: () => _confirmDelete(filtered[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ApbdesCard extends StatelessWidget {
  final ApbdesModel item;
  final String Function(double) formatRupiah;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ApbdesCard({
    required this.item,
    required this.formatRupiah,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final surplus = item.surplusDefisit;
    final isPlus = surplus >= 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        // PERBAIKAN BORDER: Menggunakan Border.all, bukan tipe cast yang salah
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Text(
                  '${item.tahun}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'V.${item.versi}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: item.isAktif == true
                        ? AppColors.primarySurface
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.isAktif == true ? 'AKTIF' : 'ARSIP',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: item.isAktif == true
                          ? AppColors.primary
                          : AppColors.textHint,
                    ),
                  ),
                ),
                const Spacer(),
                if (item.isAktif == true)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        size: 20, color: AppColors.textSecondary),
                    tooltip: 'Ubah & Buat Versi Baru',
                    onPressed: onEdit,
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  tooltip: 'Hapus Permanen',
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _DataRow(
                    label: 'Total Pendapatan',
                    // PERBAIKAN KALKULASI FALLBACK
                    value: formatRupiah(item.totalPendapatan ?? item.calculatedTotalPendapatan),
                    color: AppColors.primaryLight),
                const SizedBox(height: 6),
                _DataRow(
                    label: 'Total Belanja',
                    // PERBAIKAN KALKULASI FALLBACK
                    value: formatRupiah(item.totalBelanja ?? item.calculatedTotalBelanja),
                    color: AppColors.idmTertinggal),
                const SizedBox(height: 6),
                _DataRow(
                    label: 'Pembiayaan (Netto)',
                    value: formatRupiah(item.pembiayaanNetto),
                    color: AppColors.idmMandiri),
                const Divider(height: 16),
                _DataRow(
                    label: 'Surplus / (Defisit)',
                    value: formatRupiah(surplus),
                    color: isPlus ? AppColors.primaryLight : AppColors.idmSangat,
                    isBold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;

  const _DataRow({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}