import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

// =====================================================================
// 1. PROVIDER: Pengganti useEffect & useState untuk Fetch Data API
// =====================================================================
final idmProvider = FutureProvider<List<dynamic>>((ref) async {
  // Langsung tembak API menggunakan Dio client yang sudah kita buat
  final response = await api.get('/statistic/idm');
  return response.data['data'] ?? [];
});

// =====================================================================
// 2. SCREEN UTAMA (Menggunakan ConsumerWidget agar bisa baca Provider)
// =====================================================================
class IdmScreen extends ConsumerWidget {
  const IdmScreen({super.key});

  // Fungsi helper warna status (Pengganti getStatusBadge)
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Mandiri': return Colors.green.shade600;
      case 'Maju': return Colors.blue.shade600;
      case 'Berkembang': return Colors.orange.shade500;
      case 'Tertinggal': return Colors.deepOrange.shade600;
      case 'Sangat Tertinggal': return Colors.red.shade700;
      default: return Colors.grey.shade600;
    }
  }

  // Fungsi helper format angka
  String _formatNumber(dynamic value) {
    if (value == null) return '-';
    double? parsed = double.tryParse(value.toString());
    if (parsed == null) return '-';
    return parsed.toStringAsFixed(4);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Membaca status dari API (Loading, Error, atau Data)
    final idmAsyncValue = ref.watch(idmProvider);
    const primaryColor = Color(0xFF4EA674);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          // --- HEADER HERO SECTION ---
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: primaryColor,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              title: const Text(
                'Statistik IDM',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  //  Gambar error 404 dihapus, diganti dengan warna solid bawaan
                  Container(color: primaryColor),

                  // Teks Judul
                  const Positioned(
                    bottom: 60,
                    left: 20,
                    right: 20,
                    child: Text(
                      'Indeks Desa Membangun\nDesa Sibarani Nasampulu',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- KONTEN UTAMA ---
          SliverToBoxAdapter(
            child: idmAsyncValue.when(
              // 1. JIKA MASIH LOADING
              loading: () => const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(child: CircularProgressIndicator(color: primaryColor)),
              ),

              // 2. JIKA TERJADI ERROR (Nginx mati, 500, dll)
              error: (error, stackTrace) => Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 50, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat data IDM.\n$error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(idmProvider), // Tombol coba lagi
                      child: const Text('Coba Lagi'),
                    )
                  ],
                ),
              ),

              // 3. JIKA DATA BERHASIL DIAMBIL
              data: (idmData) {
                // Menghitung ringkasan status
                final Map<String, int> summaryByStatus = {};
                for (var item in idmData) {
                  final status = item['status_idm']?.toString() ?? 'Tidak Diketahui';
                  summaryByStatus[status] = (summaryByStatus[status] ?? 0) + 1;
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- KARTU RINGKASAN ---
                      Row(
                        children: [
                          Expanded(child: _buildSummaryCard('Total Rekaman', '${idmData.length}', Icons.dataset)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildSummaryCard('Kategori Status', '${summaryByStatus.length}', Icons.category)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // --- BADGE STATUS ---
                      const Text('Ringkasan Status IDM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      if (summaryByStatus.isEmpty)
                        const Text('Belum ada data status IDM.', style: TextStyle(color: Colors.grey))
                      else
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: summaryByStatus.entries.map((entry) {
                            return Chip(
                              label: Text('${entry.key} : ${entry.value}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              backgroundColor: _getStatusColor(entry.key),
                              side: BorderSide.none,
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 32),

                      // --- TABEL DATA ---
                      const Text('Riwayat Data IDM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        //  SingleChildScrollView agar tabel tidak kepotong di HP (bisa digeser ke samping)
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(Colors.teal.shade50),
                            columns: const [
                              DataColumn(label: Text('Tahun', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Skor', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('IKS', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('IKE', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('IKL', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: idmData.map((row) {
                              return DataRow(cells: [
                                DataCell(Text(row['tahun_idm']?.toString() ?? '-')),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(row['status_idm']?.toString() ?? '').withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: _getStatusColor(row['status_idm']?.toString() ?? '')),
                                    ),
                                    child: Text(
                                      row['status_idm']?.toString() ?? '-',
                                      style: TextStyle(color: _getStatusColor(row['status_idm']?.toString() ?? ''), fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                ),
                                DataCell(Text(_formatNumber(row['score_idm']))),
                                DataCell(Text(_formatNumber(row['sosial_idm']))),
                                DataCell(Text(_formatNumber(row['ekonomi_idm']))),
                                DataCell(Text(_formatNumber(row['lingkungan_idm']))),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper untuk merender kotak ringkasan atas
  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal.shade700, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87)),
        ],
      ),
    );
  }
}