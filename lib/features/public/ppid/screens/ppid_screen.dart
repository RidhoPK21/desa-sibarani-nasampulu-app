import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ppid_provider.dart';
import '../models/ppid_model.dart';

class PpidPublicScreen extends ConsumerWidget {
  const PpidPublicScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ppidAsync = ref.watch(ppidProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(ppidProvider.future),
        color: const Color(0xFF4EA674),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── HEADER CUSTOM (TANPA ASSETS) ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4EA674),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF4EA674).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.folder_copy_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PPID Desa', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          ppidAsync.hasValue ? '${ppidAsync.value!.length} dokumen informasi publik' : 'Memuat informasi...',
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  // Menggunakan Icon bawaan Flutter sebagai pengganti gambar asset
                  const Icon(Icons.shield, color: Colors.white, size: 42),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── STATE MANAGEMENT ──
            ppidAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: Color(0xFF4EA674)),
                      SizedBox(height: 16),
                      Text('Memuat dokumen PPID...', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text('Gagal memuat dokumen:\n$err', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF4EA674)),
                        onPressed: () => ref.refresh(ppidProvider),
                        child: const Text('Coba Lagi'),
                      )
                    ],
                  ),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.folder_off_outlined, color: Colors.grey, size: 48),
                          SizedBox(height: 16),
                          Text('Belum ada dokumen PPID.', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: items.map((item) => _PpidCard(item: item)).toList(),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ── KOMPONEN CARD ──
class _PpidCard extends StatelessWidget {
  final PpidModel item;

  const _PpidCard({required this.item});

  @override
  Widget build(BuildContext context) {
    const textHintColor = Color(0xFF94A3B8);
    const textSecondaryColor = Color(0xFF64748B);

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
              width: 48, height: 48,
              decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12)
              ),
              child: const Icon(Icons.description_rounded, color: Color(0xFF4EA674)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  const SizedBox(height: 5),
                  Text(item.description.isEmpty ? item.category : item.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: textSecondaryColor, fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      Chip(label: Text(item.category, style: const TextStyle(fontSize: 10)), padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                      if (item.createdAt != null)
                        Chip(label: Text(item.createdAt!, style: const TextStyle(fontSize: 10)), padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: textHintColor),
          ],
        ),
      ),
    );
  }
}

// ── KOMPONEN DETAIL (BOTTOM SHEET) ──
class _PpidDetail extends StatelessWidget {
  final PpidModel item;

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
            Text(item.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(item.description.isEmpty ? '-' : item.description),
            const SizedBox(height: 12),
            Chip(label: Text(item.category)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4EA674),
                ),
                onPressed: item.documentUrl.isEmpty
                    ? null
                    : () async {
                  await Clipboard.setData(ClipboardData(text: item.documentUrl));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link dokumen berhasil disalin! Buka di browser untuk mengunduh.')),
                  );
                },
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Salin Link Dokumen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}