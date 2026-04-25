import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/idm_model.dart';
import '../../../data/repositories/idm_repository.dart';
import '../../../data/services/api_service.dart';

class IdmAdminScreen extends StatefulWidget {
  const IdmAdminScreen({super.key});

  @override
  State<IdmAdminScreen> createState() => _IdmAdminScreenState();
}

class _IdmAdminScreenState extends State<IdmAdminScreen> {
  final IdmRepository _repository = IdmRepository(ApiService());

  bool _loading = false;
  bool _submitting = false;
  String? _error;
  List<IdmModel> _items = const [];

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
      final items = await _repository.getIdmHistory();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _readableError(error, fallback: 'Gagal memuat data IDM.');
        _loading = false;
      });
    }
  }

  Future<void> _openForm({IdmModel? item}) async {
    final result = await showDialog<_IdmFormValue>(
      context: context,
      barrierDismissible: !_submitting,
      builder: (context) => _IdmFormDialog(initialData: item),
    );

    if (result == null) return;

    setState(() => _submitting = true);
    try {
      if (item == null) {
        await _repository.createIdm(
          tahun: result.tahun,
          skorIdm: result.skorIdm,
          statusIdm: result.statusIdm,
          skorIks: result.skorIks,
          skorIke: result.skorIke,
          skorIkl: result.skorIkl,
          catatan: result.catatan,
        );
        _showMessage('Data IDM berhasil ditambahkan.');
      } else {
        await _repository.updateIdm(
          id: item.id,
          tahun: result.tahun,
          skorIdm: result.skorIdm,
          statusIdm: result.statusIdm,
          skorIks: result.skorIks,
          skorIke: result.skorIke,
          skorIkl: result.skorIkl,
          catatan: result.catatan,
        );
        _showMessage('Data IDM berhasil diperbarui.');
      }
      await _loadData();
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        _readableError(error, fallback: 'Proses simpan data IDM gagal.'),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _deleteItem(IdmModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus data IDM'),
        content: Text(
          'Yakin ingin menghapus data tahun ${item.tahun}? Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _submitting = true);
    try {
      await _repository.deleteIdm(item.id);
      _showMessage('Data IDM tahun ${item.tahun} berhasil dihapus.');
      await _loadData();
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        _readableError(error, fallback: 'Gagal menghapus data IDM.'),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final latest = _items.isEmpty ? null : _items.first;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _AdminHeader(
              latest: latest,
              loading: _submitting,
              onAdd: () => _openForm(),
              onRefresh: _loadData,
            ),
            const SizedBox(height: 18),
            _AdminSummary(items: _items),
            const SizedBox(height: 18),
            _AdminTableCard(
              loading: _loading,
              submitting: _submitting,
              error: _error,
              items: _items,
              onEdit: _openForm,
              onDelete: _deleteItem,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  final IdmModel? latest;
  final bool loading;
  final VoidCallback onAdd;
  final Future<void> Function() onRefresh;

  const _AdminHeader({
    required this.latest,
    required this.loading,
    required this.onAdd,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF123524), Color(0xFF1B5E20), Color(0xFF4EA674)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final vertical = constraints.maxWidth < 760;
          final content = <Widget>[
            Expanded(
              flex: vertical ? 0 : 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'ADMIN IDM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Kelola data IDM desa dalam satu panel.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    latest == null
                        ? 'Belum ada data IDM yang tersimpan.'
                        : 'Data terbaru ${latest!.tahun} dengan status ${latest!.statusIdm} dan skor ${latest!.skorIdm.toStringAsFixed(4)}.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: vertical ? 0 : 16, height: vertical ? 16 : 0),
            Expanded(
              flex: vertical ? 0 : 2,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aksi Cepat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: loading ? null : onAdd,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF123524),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Tambah Data IDM'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: loading ? null : onRefresh,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Muat Ulang Data'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];

          return vertical
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: content,
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: content,
                );
        },
      ),
    );
  }
}

class _AdminSummary extends StatelessWidget {
  final List<IdmModel> items;

  const _AdminSummary({required this.items});

  @override
  Widget build(BuildContext context) {
    final latest = items.isEmpty ? null : items.first;
    final highest = items.isEmpty
        ? null
        : items.reduce((a, b) => a.skorIdm >= b.skorIdm ? a : b);

    final cards = [
      _SummaryItem(
        title: 'Total Rekaman',
        value: items.length.toString(),
        subtitle: 'Jumlah seluruh data IDM',
        icon: Icons.inventory_2_rounded,
      ),
      _SummaryItem(
        title: 'Tahun Terbaru',
        value: latest?.tahun.toString() ?? '-',
        subtitle: latest?.statusIdm ?? 'Belum ada data',
        icon: Icons.calendar_month_rounded,
      ),
      _SummaryItem(
        title: 'Skor Tertinggi',
        value: highest == null ? '-' : highest.skorIdm.toStringAsFixed(4),
        subtitle: highest == null ? 'Belum ada data' : 'Tahun ${highest.tahun}',
        icon: Icons.trending_up_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 900;
        return GridView.builder(
          itemCount: cards.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: compact ? 1 : 3,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: compact ? 3.9 : 2.4,
          ),
          itemBuilder: (context, index) => cards[index],
        );
      },
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF123524),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminTableCard extends StatelessWidget {
  final bool loading;
  final bool submitting;
  final String? error;
  final List<IdmModel> items;
  final Future<void> Function({IdmModel? item}) onEdit;
  final Future<void> Function(IdmModel item) onDelete;

  const _AdminTableCard({
    required this.loading,
    required this.submitting,
    required this.error,
    required this.items,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daftar Data IDM',
                        style: TextStyle(
                          color: Color(0xFF123524),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Edit atau hapus data langsung dari tabel ini.',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                if (submitting)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            if (loading)
              const _TableState(message: 'Memuat data IDM...')
            else if (error != null)
              _TableState(message: error!, isError: true)
            else if (items.isEmpty)
              const _TableState(message: 'Belum ada data IDM.')
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xFFF0FDF4),
                  ),
                  columnSpacing: 18,
                  columns: const [
                    DataColumn(label: Text('Tahun')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Skor IDM')),
                    DataColumn(label: Text('IKS')),
                    DataColumn(label: Text('IKE')),
                    DataColumn(label: Text('IKL')),
                    DataColumn(label: Text('Catatan')),
                    DataColumn(label: Text('Aksi')),
                  ],
                  rows: items.map((item) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            item.tahun.toString(),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        DataCell(_StatusChip(status: item.statusIdm)),
                        DataCell(Text(item.skorIdm.toStringAsFixed(4))),
                        DataCell(Text(item.skorIks.toStringAsFixed(4))),
                        DataCell(Text(item.skorIke.toStringAsFixed(4))),
                        DataCell(Text(item.skorIkl.toStringAsFixed(4))),
                        DataCell(
                          SizedBox(
                            width: 220,
                            child: Text(
                              item.catatan?.trim().isNotEmpty == true
                                  ? item.catatan!
                                  : '-',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                tooltip: 'Edit',
                                onPressed: submitting
                                    ? null
                                    : () => onEdit(item: item),
                                icon: const Icon(Icons.edit_rounded),
                                color: const Color(0xFF0F766E),
                              ),
                              IconButton(
                                tooltip: 'Hapus',
                                onPressed: submitting
                                    ? null
                                    : () => onDelete(item),
                                icon: const Icon(Icons.delete_rounded),
                                color: Colors.red.shade700,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TableState extends StatelessWidget {
  final String message;
  final bool isError;

  const _TableState({required this.message, this.isError = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isError ? Colors.red.shade700 : const Color(0xFF64748B),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.$3),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: colors.$2,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _IdmFormDialog extends StatefulWidget {
  final IdmModel? initialData;

  const _IdmFormDialog({this.initialData});

  @override
  State<_IdmFormDialog> createState() => _IdmFormDialogState();
}

class _IdmFormDialogState extends State<_IdmFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tahunController;
  late final TextEditingController _skorIdmController;
  late final TextEditingController _skorIksController;
  late final TextEditingController _skorIkeController;
  late final TextEditingController _skorIklController;
  late final TextEditingController _catatanController;
  late String _status;

  static const _statuses = [
    'Mandiri',
    'Maju',
    'Berkembang',
    'Tertinggal',
    'Sangat Tertinggal',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.initialData;
    _tahunController = TextEditingController(
      text: item?.tahun.toString() ?? '',
    );
    _skorIdmController = TextEditingController(
      text: item == null ? '' : item.skorIdm.toStringAsFixed(4),
    );
    _skorIksController = TextEditingController(
      text: item == null ? '' : item.skorIks.toStringAsFixed(4),
    );
    _skorIkeController = TextEditingController(
      text: item == null ? '' : item.skorIke.toStringAsFixed(4),
    );
    _skorIklController = TextEditingController(
      text: item == null ? '' : item.skorIkl.toStringAsFixed(4),
    );
    _catatanController = TextEditingController(text: item?.catatan ?? '');
    _status = _statuses.contains(item?.statusIdm)
        ? item!.statusIdm
        : _statuses[2];
  }

  @override
  void dispose() {
    _tahunController.dispose();
    _skorIdmController.dispose();
    _skorIksController.dispose();
    _skorIkeController.dispose();
    _skorIklController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      _IdmFormValue(
        tahun: int.parse(_tahunController.text.trim()),
        skorIdm: double.parse(_skorIdmController.text.trim()),
        statusIdm: _status,
        skorIks: double.parse(_skorIksController.text.trim()),
        skorIke: double.parse(_skorIkeController.text.trim()),
        skorIkl: double.parse(_skorIklController.text.trim()),
        catatan: _catatanController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialData != null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEdit ? 'Edit Data IDM' : 'Tambah Data IDM',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF123524),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isEdit
                        ? 'Perbarui nilai dan status IDM untuk tahun terkait.'
                        : 'Isi seluruh field untuk menambahkan rekaman IDM baru.',
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      _FormFieldBox(
                        width: 160,
                        child: TextFormField(
                          controller: _tahunController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Tahun'),
                          validator: (value) {
                            final parsed = int.tryParse(value?.trim() ?? '');
                            if (parsed == null) return 'Tahun wajib angka';
                            if (parsed < 2000 || parsed > 2100) {
                              return 'Tahun tidak valid';
                            }
                            return null;
                          },
                        ),
                      ),
                      _FormFieldBox(
                        width: 220,
                        child: DropdownButtonFormField<String>(
                          initialValue: _status,
                          decoration: const InputDecoration(
                            labelText: 'Status IDM',
                          ),
                          items: _statuses
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) setState(() => _status = value);
                          },
                        ),
                      ),
                      _FormFieldBox(
                        width: 160,
                        child: _ScoreField(
                          controller: _skorIdmController,
                          label: 'Skor IDM',
                        ),
                      ),
                      _FormFieldBox(
                        width: 160,
                        child: _ScoreField(
                          controller: _skorIksController,
                          label: 'Skor IKS',
                        ),
                      ),
                      _FormFieldBox(
                        width: 160,
                        child: _ScoreField(
                          controller: _skorIkeController,
                          label: 'Skor IKE',
                        ),
                      ),
                      _FormFieldBox(
                        width: 160,
                        child: _ScoreField(
                          controller: _skorIklController,
                          label: 'Skor IKL',
                        ),
                      ),
                      _FormFieldBox(
                        width: 666,
                        child: TextFormField(
                          controller: _catatanController,
                          minLines: 3,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Catatan',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Batal'),
                      ),
                      const SizedBox(width: 10),
                      FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.save_rounded),
                        label: Text(
                          isEdit ? 'Simpan Perubahan' : 'Tambah Data',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormFieldBox extends StatelessWidget {
  final double width;
  final Widget child;

  const _FormFieldBox({required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, child: child);
  }
}

class _ScoreField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _ScoreField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        final parsed = double.tryParse((value ?? '').trim());
        if (parsed == null) return 'Wajib angka';
        if (parsed < 0 || parsed > 1) return 'Isi 0.0 - 1.0';
        return null;
      },
    );
  }
}

class _IdmFormValue {
  final int tahun;
  final double skorIdm;
  final String statusIdm;
  final double skorIks;
  final double skorIke;
  final double skorIkl;
  final String? catatan;

  const _IdmFormValue({
    required this.tahun,
    required this.skorIdm,
    required this.statusIdm,
    required this.skorIks,
    required this.skorIke,
    required this.skorIkl,
    required this.catatan,
  });
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: const Color(0xFFE2E8F0)),
    boxShadow: const [
      BoxShadow(color: Color(0x10000000), blurRadius: 18, offset: Offset(0, 8)),
    ],
  );
}

(Color, Color, Color) _statusColors(String status) {
  switch (status) {
    case 'Mandiri':
      return (
        const Color(0xFFDCFCE7),
        const Color(0xFF15803D),
        const Color(0xFFBBF7D0),
      );
    case 'Maju':
      return (
        const Color(0xFFDBEAFE),
        const Color(0xFF1D4ED8),
        const Color(0xFFBFDBFE),
      );
    case 'Berkembang':
      return (
        const Color(0xFFFEF9C3),
        const Color(0xFFA16207),
        const Color(0xFFFEF08A),
      );
    case 'Tertinggal':
      return (
        const Color(0xFFFFEDD5),
        const Color(0xFFC2410C),
        const Color(0xFFFED7AA),
      );
    case 'Sangat Tertinggal':
      return (
        const Color(0xFFFEE2E2),
        const Color(0xFFB91C1C),
        const Color(0xFFFECACA),
      );
    default:
      return (
        const Color(0xFFF1F5F9),
        const Color(0xFF334155),
        const Color(0xFFE2E8F0),
      );
  }
}

String _readableError(Object error, {required String fallback}) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return '${data['message']}';
    }
    return error.message ?? fallback;
  }
  return fallback;
}
