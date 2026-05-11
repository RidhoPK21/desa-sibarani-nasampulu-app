import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/content_models.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../data/services/api_service.dart';
import '../../../shared/widgets/app_state_widgets.dart';

class PpidPublicScreen extends StatefulWidget {
  const PpidPublicScreen({super.key});

  @override
  State<PpidPublicScreen> createState() => _PpidPublicScreenState();
}

class _PpidPublicScreenState extends State<PpidPublicScreen> {
  final _repository = ContentRepository(ApiService());
  bool _loading = true;
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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Dokumentasi PPID belum dapat dimuat.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppPageHeader(
            title: 'PPID Desa',
            subtitle: '${_items.length} dokumen informasi publik',
            icon: Icons.folder_copy_rounded,
            trailing: Image.asset(AppAssets.logoDesa, width: 42, height: 42),
          ),
          const SizedBox(height: 14),
          if (_loading)
            const AppStateCard(message: 'Memuat dokumen PPID...')
          else if (_error != null)
            AppStateCard(message: _error!, isError: true, onRetry: _load)
          else if (_items.isEmpty)
            const AppStateCard(message: 'Belum ada dokumen PPID.')
          else
            ..._items.map((item) => _PpidCard(item: item)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _PpidCard extends StatelessWidget {
  final PpidDocumentModel item;

  const _PpidCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: () => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (_) => _PpidDetail(item: item),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.description_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.description.isEmpty ? item.category : item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text(item.category)),
                      if (item.createdAt != null)
                        Chip(label: Text(item.createdAt!)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

class _PpidDetail extends StatelessWidget {
  final PpidDocumentModel item;

  const _PpidDetail({required this.item});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(item.description.isEmpty ? '-' : item.description),
            const SizedBox(height: 12),
            Chip(label: Text(item.category)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: item.documentUrl.isEmpty
                    ? null
                    : () async {
                        await Clipboard.setData(
                          ClipboardData(text: item.documentUrl),
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Link dokumen disalin.'),
                          ),
                        );
                      },
                icon: const Icon(Icons.download_rounded),
                label: const Text('Lihat / Unduh Dokumen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
