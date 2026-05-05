import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/apbdes_model.dart';
import '../../../features/auth/providers/apbdes_provider.dart';
import '../../widgets/apbdes/apbdes_form_screen.dart';

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
      context.read<ApbdesProvider>().fetchAll();
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

  void _goToForm({ApbdesModel? existing}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ApbdesFormScreen(existing: existing),
      ),
    ).then((_) => context.read<ApbdesProvider>().fetchAll());
  }

  void _confirmDelete(ApbdesModel item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Yakin Menghapus APBDes?',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
              fontSize: 18),
        ),
        content: Text(
          'Data Tahun ${item.tahun} Versi ${item.versi} akan dihapus selamanya.',
          style: const TextStyle(color: AppTheme.primaryGreen),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGreen),
            onPressed: () async {
              Navigator.pop(context);
              await context.read<ApbdesProvider>().remove(item.id!);
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
      backgroundColor: AppTheme.bgGray,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.menu, color: AppTheme.primaryGreen),
            SizedBox(width: 8),
            Text('Kelola APBDes'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => _goToForm(),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Buat APBDes Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // List
          Expanded(
            child: Consumer<ApbdesProvider>(
              builder: (_, prov, __) {
                if (prov.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final filtered = _searchQuery.isEmpty
                    ? prov.list
                    : prov.list
                        .where((e) =>
                            e.tahun.toString().contains(_searchQuery))
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text(
                          'Belum ada data APBDes',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) =>
                      _ApbdesCard(
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

// ─────────────────────────────────────────────────────────────
// CARD WIDGET
// ─────────────────────────────────────────────────────────────
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.lightGreen,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Text(
                  '${item.tahun}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: item.isAktif == true
                        ? AppTheme.lightGreen
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.isAktif == true ? 'AKTIF' : 'ARSIP',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: item.isAktif == true
                          ? AppTheme.primaryGreen
                          : Colors.grey,
                    ),
                  ),
                ),
                const Spacer(),
                if (item.isAktif == true)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        size: 20, color: Colors.blueGrey),
                    tooltip: 'Ubah & Buat Versi Baru',
                    onPressed: onEdit,
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: Colors.red),
                  tooltip: 'Hapus Permanen',
                  onPressed: onDelete,
                ),
              ],
            ),
          ),

          // Data rows
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _DataRow(
                    label: 'Total Pendapatan',
                    value: formatRupiah(item.totalPendapatan ?? 0),
                    color: AppTheme.accentGreen),
                const SizedBox(height: 6),
                _DataRow(
                    label: 'Total Belanja',
                    value: formatRupiah(item.totalBelanja ?? 0),
                    color: AppTheme.orange),
                const SizedBox(height: 6),
                _DataRow(
                    label: 'Pembiayaan (Netto)',
                    value: formatRupiah(item.pembiayaanNetto),
                    color: AppTheme.blue),
                const Divider(height: 16),
                _DataRow(
                    label: 'Surplus / (Defisit)',
                    value: formatRupiah(surplus),
                    color: isPlus ? AppTheme.accentGreen : Colors.red,
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
                color: Colors.grey.shade600,
                fontWeight:
                    isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color)),
      ],
    );
  }
}
