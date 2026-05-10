import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/content_models.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../data/services/api_service.dart';
import '../../../shared/widgets/app_state_widgets.dart';

class BeritaAdminScreen extends StatefulWidget {
  const BeritaAdminScreen({super.key});

  @override
  State<BeritaAdminScreen> createState() => _BeritaAdminScreenState();
}

class _BeritaAdminScreenState extends State<BeritaAdminScreen> {
  final _repository = ContentRepository(ApiService());
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  List<BeritaModel> _items = const [];

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
      final items = await _repository.getBerita();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _readableError(error, fallback: 'Gagal memuat berita.');
        _loading = false;
      });
    }
  }

  Future<void> _openForm({BeritaModel? item}) async {
    final result = await showDialog<_BeritaFormResult>(
      context: context,
      builder: (_) => _BeritaFormDialog(initialData: item),
    );
    if (result == null) return;
    setState(() => _submitting = true);
    try {
      if (item == null) {
        await _repository.createBerita(result.item, image: result.image);
        _message('Berita berhasil ditambahkan.');
      } else {
        await _repository.updateBerita(result.item, image: result.image);
        _message('Berita berhasil diperbarui.');
      }
      await _load();
    } catch (error) {
      if (!mounted) return;
      _message(
        _readableError(error, fallback: 'Gagal menyimpan berita.'),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _delete(BeritaModel item) async {
    final ok = await _confirm(
      context,
      'Hapus berita',
      'Yakin ingin menghapus "${item.title}"?',
    );
    if (!ok) return;
    setState(() => _submitting = true);
    try {
      await _repository.deleteBerita(item.id);
      _message('Berita berhasil dihapus.');
      await _load();
    } catch (error) {
      if (!mounted) return;
      _message(
        _readableError(error, fallback: 'Gagal menghapus berita.'),
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
        label: const Text('Tambah Berita'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppPageHeader(
              title: 'Berita Admin',
              subtitle: '${_items.length} berita tersimpan',
              icon: Icons.article_rounded,
            ),
            const SizedBox(height: 14),
            if (_loading)
              const AppStateCard(message: 'Memuat berita...')
            else if (_error != null)
              AppStateCard(message: _error!, isError: true, onRetry: _load)
            else if (_items.isEmpty)
              const AppStateCard(message: 'Belum ada berita.')
            else
              ..._items.map(
                (item) => _AdminNewsCard(
                  item: item,
                  disabled: _submitting,
                  onEdit: () => _openForm(item: item),
                  onDelete: () => _delete(item),
                ),
              ),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}

class _AdminNewsCard extends StatelessWidget {
  final BeritaModel item;
  final bool disabled;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminNewsCard({
    required this.item,
    required this.disabled,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 58,
            height: 58,
            child: item.imageUrl == null
                ? Container(
                    color: AppColors.primarySurface,
                    child: const Icon(Icons.article_rounded),
                  )
                : Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.primarySurface,
                      child: const Icon(Icons.article_rounded),
                    ),
                  ),
          ),
        ),
        title: Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          item.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Wrap(
          children: [
            IconButton(
              onPressed: disabled ? null : onEdit,
              icon: const Icon(Icons.edit_rounded),
            ),
            IconButton(
              onPressed: disabled ? null : onDelete,
              icon: const Icon(Icons.delete_rounded),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class _BeritaFormDialog extends StatefulWidget {
  final BeritaModel? initialData;

  const _BeritaFormDialog({this.initialData});

  @override
  State<_BeritaFormDialog> createState() => _BeritaFormDialogState();
}

class _BeritaFormDialogState extends State<_BeritaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _content;
  bool _published = false;
  PlatformFile? _image;

  @override
  void initState() {
    super.initState();
    final item = widget.initialData;
    _title = TextEditingController(text: item?.title ?? '');
    _content = TextEditingController(text: item?.content ?? '');
    _published = item?.isPublished ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _image = result.files.single);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      _BeritaFormResult(
        item: BeritaModel(
          id: widget.initialData?.id ?? '',
          title: _title.text.trim(),
          content: _content.text.trim(),
          imageUrl: widget.initialData?.imageUrl,
          isPublished: _published,
        ),
        image: _image,
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
                  widget.initialData == null ? 'Tambah Berita' : 'Edit Berita',
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
                  controller: _content,
                  minLines: 5,
                  maxLines: 8,
                  decoration: const InputDecoration(labelText: 'Isi berita'),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image_rounded),
                  label: Text(_image?.name ?? 'Pilih Gambar'),
                ),
                SwitchListTile(
                  value: _published,
                  onChanged: (v) => setState(() => _published = v),
                  title: const Text('Publikasikan'),
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

class _BeritaFormResult {
  final BeritaModel item;
  final PlatformFile? image;

  const _BeritaFormResult({required this.item, this.image});
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
