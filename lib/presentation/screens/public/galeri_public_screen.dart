import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../data/models/content_models.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../data/services/api_service.dart';
import '../../../shared/widgets/app_state_widgets.dart';

class GaleriPublicScreen extends StatefulWidget {
  const GaleriPublicScreen({super.key});

  @override
  State<GaleriPublicScreen> createState() => _GaleriPublicScreenState();
}

class _GaleriPublicScreenState extends State<GaleriPublicScreen> {
  final _repository = ContentRepository(ApiService());
  bool _loading = true;
  String? _error;
  List<GaleriModel> _items = const [];

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
      final items = await _repository.getGaleri();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Galeri belum dapat dimuat.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: AppPageHeader(
                title: 'Galeri Desa',
                subtitle: '${_items.length} dokumentasi kegiatan',
                icon: Icons.photo_library_rounded,
                trailing: Image.asset(
                  AppAssets.logoDesa,
                  width: 42,
                  height: 42,
                ),
              ),
            ),
          ),
          if (_loading)
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: AppStateCard(message: 'Memuat galeri...'),
              ),
            )
          else if (_error != null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: AppStateCard(
                  message: _error!,
                  isError: true,
                  onRetry: _load,
                ),
              ),
            )
          else if (_items.isEmpty)
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: AppStateCard(message: 'Belum ada foto galeri.'),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
              sliver: SliverGrid.builder(
                itemCount: _items.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 230,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) =>
                    _GalleryTile(item: _items[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  final GaleriModel item;

  const _GalleryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => _GalleryPreview(item: item))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: item.imageUrl.isEmpty
                  ? Image.asset(
                      AppAssets.monument,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                      errorBuilder: (_, _, _) =>
                          Image.asset(AppAssets.monument, fit: BoxFit.cover),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                item.title.isEmpty ? 'Dokumentasi Desa' : item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryPreview extends StatelessWidget {
  final GaleriModel item;

  const _GalleryPreview({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text(item.title)),
      body: Center(
        child: InteractiveViewer(
          child: item.imageUrl.isEmpty
              ? Image.asset(AppAssets.monument)
              : Image.network(
                  item.imageUrl,
                  webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                  errorBuilder: (_, _, _) => Image.asset(AppAssets.monument),
                ),
        ),
      ),
      bottomNavigationBar: item.description.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                item.description,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
    );
  }
}
