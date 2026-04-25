import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/idm_model.dart';
import '../../../data/repositories/idm_repository.dart';
import '../../../data/services/api_service.dart';

class IdmScreen extends StatefulWidget {
  const IdmScreen({super.key});

  @override
  State<IdmScreen> createState() => _IdmScreenState();
}

class _IdmScreenState extends State<IdmScreen> {
  final _repository = IdmRepository(ApiService());

  bool _loading = false;
  String? _error;
  List<IdmModel> _idmData = const [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _repository.getIdmHistory();
      if (!mounted) return;
      setState(() {
        _idmData = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Tidak dapat memuat data IDM. Coba lagi nanti.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final summaryByStatus = <String, int>{};
    for (final item in _idmData) {
      final status = item.statusIdm.trim().isEmpty
          ? 'Tidak Diketahui'
          : item.statusIdm;
      summaryByStatus[status] = (summaryByStatus[status] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PageHeader(
                          latest: _idmData.isEmpty ? null : _idmData.first,
                          onRefresh: _fetchData,
                        ),
                        const SizedBox(height: 18),
                        _SummaryGrid(
                          totalData: _idmData.length,
                          totalStatus: summaryByStatus.length,
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Ringkasan Status IDM',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Berikut distribusi status IDM Desa.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _StatusSummary(summaryByStatus: summaryByStatus),
                        const SizedBox(height: 22),
                        _IdmTable(
                          loading: _loading,
                          error: _error,
                          data: _idmData,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final IdmModel? latest;
  final VoidCallback onRefresh;

  const _PageHeader({required this.latest, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4EA674),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistik IDM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  latest == null
                      ? 'Data Indeks Desa Membangun'
                      : 'Tahun ${latest!.tahun} | ${latest!.statusIdm} | ${latest!.skorIdm.toStringAsFixed(4)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final int totalData;
  final int totalStatus;

  const _SummaryGrid({required this.totalData, required this.totalStatus});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _SummaryCard(
            title: 'Total Rekaman',
            value: totalData.toString(),
            subtitle: 'Data IDM terkini',
            icon: Icons.dataset_rounded,
          ),
          _SummaryCard(
            title: 'Kategori Status',
            value: totalStatus == 0 ? '-' : totalStatus.toString(),
            subtitle: 'Jumlah status berbeda',
            icon: Icons.category_rounded,
          ),
          const _SummaryCard(
            title: 'Refresh Data',
            value: 'Realtime',
            subtitle:
                'Data diambil dari API statistika IDM setiap buka halaman.',
            icon: Icons.sync_rounded,
            valueSize: 20,
          ),
        ];

        if (constraints.maxWidth < 760) {
          return Column(
            children: cards
                .map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: card,
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: [
            for (final card in cards)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: card,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final double valueSize;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.valueSize = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _whiteBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF115E59),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF0F766E),
              fontSize: valueSize,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatusSummary extends StatelessWidget {
  final Map<String, int> summaryByStatus;

  const _StatusSummary({required this.summaryByStatus});

  @override
  Widget build(BuildContext context) {
    if (summaryByStatus.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: _whiteBoxDecoration(),
        child: const Text(
          'Belum ada data status IDM.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 900
            ? 3
            : width >= 560
            ? 2
            : 1;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: crossAxisCount == 1 ? 4.5 : 3.6,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: summaryByStatus.entries.map((entry) {
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: _whiteBoxDecoration(),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          entry.key.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.value.toString(),
                          style: const TextStyle(
                            color: Color(0xFF0F766E),
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: entry.key),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _IdmTable extends StatelessWidget {
  final bool loading;
  final String? error;
  final List<IdmModel> data;

  const _IdmTable({
    required this.loading,
    required this.error,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: _whiteBoxDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 740,
            child: Column(
              children: [
                const _TableHeader(),
                if (loading)
                  const _TableMessage(message: 'Memuat data ...')
                else if (error != null)
                  _TableMessage(message: error!, isError: true)
                else if (data.isEmpty)
                  const _TableMessage(message: 'Data IDM belum tersedia.')
                else
                  for (final item in data) _TableRowItem(item: item),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFECFDF5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: const Row(
        children: [
          SizedBox(width: 96, child: _HeaderText('Tahun')),
          Expanded(flex: 2, child: _HeaderText('Status')),
          Expanded(child: _HeaderText('Skor', center: true)),
          Expanded(child: _HeaderText('IKS', center: true)),
          Expanded(child: _HeaderText('IKE', center: true)),
          Expanded(child: _HeaderText('IKL', center: true)),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  final bool center;

  const _HeaderText(this.text, {this.center = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.left,
      style: const TextStyle(
        color: Color(0xFF064E3B),
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _TableRowItem extends StatelessWidget {
  final IdmModel item;

  const _TableRowItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              item.tahun == 0 ? '-' : item.tahun.toString(),
              style: const TextStyle(
                color: Color(0xFF115E59),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(flex: 2, child: _StatusBadge(status: item.statusIdm)),
          Expanded(child: _NumberCell(value: item.skorIdm)),
          Expanded(child: _NumberCell(value: item.skorIks)),
          Expanded(child: _NumberCell(value: item.skorIke)),
          Expanded(child: _NumberCell(value: item.skorIkl)),
        ],
      ),
    );
  }
}

class _NumberCell extends StatelessWidget {
  final double value;

  const _NumberCell({required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      value.toStringAsFixed(4),
      textAlign: TextAlign.center,
      style: const TextStyle(color: Color(0xFF334155), fontSize: 13),
    );
  }
}

class _TableMessage extends StatelessWidget {
  final String message;
  final bool isError;

  const _TableMessage({required this.message, this.isError = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isError ? Colors.red.shade700 : const Color(0xFF64748B),
          fontSize: 13,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(status);
    final label = status.trim().isEmpty ? '-' : status;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: style.border),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: style.foreground,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

BoxDecoration _whiteBoxDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: const Color(0xFFE2E8F0)),
    boxShadow: const [
      BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 3)),
    ],
  );
}

_BadgeStyle _statusStyle(String status) {
  switch (status) {
    case 'Mandiri':
      return const _BadgeStyle(
        background: Color(0xFFDCFCE7),
        foreground: Color(0xFF15803D),
        border: Color(0xFFBBF7D0),
      );
    case 'Maju':
      return const _BadgeStyle(
        background: Color(0xFFDBEAFE),
        foreground: Color(0xFF1D4ED8),
        border: Color(0xFFBFDBFE),
      );
    case 'Berkembang':
      return const _BadgeStyle(
        background: Color(0xFFFEF9C3),
        foreground: Color(0xFFA16207),
        border: Color(0xFFFEF08A),
      );
    case 'Tertinggal':
      return const _BadgeStyle(
        background: Color(0xFFFFEDD5),
        foreground: Color(0xFFC2410C),
        border: Color(0xFFFED7AA),
      );
    case 'Sangat Tertinggal':
      return const _BadgeStyle(
        background: Color(0xFFFEE2E2),
        foreground: Color(0xFFB91C1C),
        border: Color(0xFFFECACA),
      );
    default:
      return const _BadgeStyle(
        background: Color(0xFFF1F5F9),
        foreground: Color(0xFF334155),
        border: Color(0xFFE2E8F0),
      );
  }
}

class _BadgeStyle {
  final Color background;
  final Color foreground;
  final Color border;

  const _BadgeStyle({
    required this.background,
    required this.foreground,
    required this.border,
  });
}
