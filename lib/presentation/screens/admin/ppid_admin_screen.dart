import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/content_models.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../data/services/api_service.dart';
import '../../../shared/widgets/app_state_widgets.dart';

class PpidAdminScreen extends StatefulWidget {
  const PpidAdminScreen({super.key});

  @override
  State<PpidAdminScreen> createState() => _PpidAdminScreenState();
}

class _PpidAdminScreenState extends State<PpidAdminScreen> {
  final _repository = ContentRepository(ApiService());
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  List<PpidDocumentModel> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _repository.getPpid();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _readableError(error, fallback: 'Gagal memuat PPID.');
        _loading = false;
      });
    }
  }

  Future<void> _openForm({PpidDocumentModel? item}) async {
    final result = await showDialog<_PpidFormResult>(
      context: context,
      builder: (_) => _PpidFormDialog(initialData: item),
    );
    if (result == null) return;
    setState(() => _submitting = true);
    try {
      if (item == null) {
        await _repository.createPpid(result.item, file: result.file!);
        _message('Dokumen berhasil ditambahkan.');
      } else {
        await _repository.updatePpid(result.item, file: result.file);
        _message('Dokumen berhasil diperbarui.');
      }
      await _load();
    } catch (error) {
      if (!mounted) return;
      _message(
        _readableError(error, fallback: 'Gagal menyimpan dokumen.'),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _delete(PpidDocumentModel item) async {
    final ok = await _confirm(
      context,
      'Hapus dokumen',
      'Yakin ingin menghapus "${item.title}"?',
    );
    if (!ok) return;
    setState(() => _submitting = true);
    try {
      await _repository.deletePpid(item.id);
      _message('Dokumen berhasil dihapus.');
      await _load();
    } catch (error) {
      if (!mounted) return;
      _message(
        _readableError(error, fallback: 'Gagal menghapus dokumen.'),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _message(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red.shade700 : AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitting ? null : () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah PPID'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppPageHeader(
              title: 'PPID Admin',
              subtitle: '${_items.length} dokumen tersimpan',
              icon: Icons.folder_copy_rounded,
            ),
            const SizedBox(height: 14),
            if (_loading)
              const AppStateCard(message: 'Memuat dokumen...')
            else if (_error != null)
              AppStateCard(message: _error!, isError: true, onRetry: _load)
            else if (_items.isEmpty)
              const AppStateCard(message: 'Belum ada dokumen PPID.')
            else
              ..._items.map(
                (item) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.description_rounded),
                    ),
                    title: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      '${item.category}\n${item.description}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    trailing: Wrap(
                      children: [
                        IconButton(
                          onPressed: _submitting
                              ? null
                              : () => _openForm(item: item),
                          icon: const Icon(Icons.edit_rounded),
                        ),
                        IconButton(
                          onPressed: _submitting ? null : () => _delete(item),
                          icon: const Icon(Icons.delete_rounded),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}

class _PpidFormDialog extends StatefulWidget {
  final PpidDocumentModel? initialData;

  const _PpidFormDialog({this.initialData});

  @override
  State<_PpidFormDialog> createState() => _PpidFormDialogState();
}

class _PpidFormDialogState extends State<_PpidFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  PlatformFile? _file;
  String _category = _categories.first;
  bool _showFileError = false;

  static const _categories = [
    'Informasi Berkala',
    'Informasi Serta Merta',
    'Informasi Setiap Saat',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.initialData;
    _title = TextEditingController(text: item?.title ?? '');
    _description = TextEditingController(text: item?.description ?? '');
    _category = _categories.contains(item?.category)
        ? item!.category
        : _categories.first;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _file = result.files.single;
        _showFileError = false;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (widget.initialData == null && _file == null) {
      setState(() => _showFileError = true);
      return;
    }
    Navigator.pop(
      context,
      _PpidFormResult(
        item: PpidDocumentModel(
          id: widget.initialData?.id ?? '',
          title: _title.text.trim(),
          description: _description.text.trim(),
          category: _category,
          documentUrl: widget.initialData?.documentUrl ?? '',
        ),
        file: _file,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.initialData == null ? 'Tambah PPID' : 'Edit PPID',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Judul'),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: _categories
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _category = value ?? _categories.first),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.upload_file_rounded),
                  label: Text(_file?.name ?? 'Pilih Dokumen'),
                ),
                if (_showFileError)
                  const Text(
                    'File dokumen wajib dipilih.',
                    style: TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Simpan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Wajib diisi' : null;
}

class _PpidFormResult {
  final PpidDocumentModel item;
  final PlatformFile? file;

  const _PpidFormResult({required this.item, this.file});
}

Future<bool> _confirm(
  BuildContext context,
  String title,
  String message,
) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        ),
      ) ??
      false;
}

String _readableError(Object error, {required String fallback}) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) return '${data['message']}';
    return error.message ?? fallback;
  }
  return fallback;
}
