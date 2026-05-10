import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/infografis_provider.dart';
import '../models/infografis_model.dart';

class InfografisPublikScreen extends ConsumerStatefulWidget {
  const InfografisPublikScreen({super.key});

  @override
  ConsumerState<InfografisPublikScreen> createState() => _InfografisPublikScreenState();
}

class _InfografisPublikScreenState extends ConsumerState<InfografisPublikScreen> {
  String _selectedDusunId = "all";

  // Fungsi meracik 6 Data Chart
  List<StatData> _generateChartData(List<DusunStatModel> allData, String selectedId) {
    final filtered = selectedId == "all" ? allData : allData.where((d) => d.id == selectedId).toList();

    int sum(int Function(DusunStatModel) selector) => filtered.fold(0, (prev, d) => prev + selector(d));

    return [
      // 1. USIA
      StatData(
        id: "usia", judul: "Statistik Usia", satuan: "Jiwa",
        subjudul: "Keterangan jumlah balita, anak - anak, remaja, dewasa dan lansia",
        deskripsi: "Kami berkomitmen untuk memantau pertumbuhan penduduk secara berkala guna merencanakan program pelayanan kesehatan dan sosial yang tepat sasaran bagi seluruh kelompok usia.",
        data: [
          ChartData("Balita", sum((d) => d.balita).toDouble(), const Color(0xFF6366F1)),
          ChartData("Anak-anak", sum((d) => d.anak).toDouble(), const Color(0xFFEC4899)),
          ChartData("Remaja", sum((d) => d.remaja).toDouble(), const Color(0xFFA78BFA)),
          ChartData("Dewasa", sum((d) => d.dewasa).toDouble(), const Color(0xFF34D399)),
          ChartData("Lansia", sum((d) => d.lansia).toDouble(), const Color(0xFFFBBF24)),
        ],
      ),
      // 2. PENDIDIKAN
      StatData(
        id: "pendidikan", judul: "Statistik Pendidikan", satuan: "Siswa",
        subjudul: "Keterangan jumlah yang bersekolah SD, SMP, SMA, Sarjana, dan non Sarjana",
        deskripsi: "Pendidikan adalah pilar utama pembangunan desa. Kami menyajikan data tingkat pendidikan penduduk sebagai acuan untuk mendukung program peningkatan SDM di Desa Sibarani Nasampulu.",
        data: [
          ChartData("SD", sum((d) => d.sd).toDouble(), const Color(0xFF6366F1)),
          ChartData("SMP", sum((d) => d.smp).toDouble(), const Color(0xFFEC4899)),
          ChartData("SMA", sum((d) => d.sma).toDouble(), const Color(0xFFA78BFA)),
          ChartData("Sarjana", sum((d) => d.sarjana).toDouble(), const Color(0xFF34D399)),
          ChartData("Lainnya", sum((d) => d.pendidikanLainnya).toDouble(), const Color(0xFFFBBF24)),
        ],
      ),
      // 3. PEKERJAAN
      StatData(
        id: "pekerjaan", judul: "Statistik Pekerjaan", satuan: "Orang",
        subjudul: "Keterangan jumlah orang yang bekerja sebagai petani, nelayan, asn, wiraswasta",
        deskripsi: "Gambaran mata pencaharian penduduk mencerminkan potensi ekonomi desa. Data ini membantu pemerintah desa dalam merancang pemberdayaan ekonomi masyarakat.",
        data: [
          ChartData("Petani", sum((d) => d.petani).toDouble(), const Color(0xFF6366F1)),
          ChartData("Nelayan", sum((d) => d.nelayan).toDouble(), const Color(0xFFEC4899)),
          ChartData("ASN", sum((d) => d.asn).toDouble(), const Color(0xFFA78BFA)),
          ChartData("Wiraswasta", sum((d) => d.wiraswasta).toDouble(), const Color(0xFF34D399)),
          ChartData("Lainnya", sum((d) => d.pekerjaanLainnya).toDouble(), const Color(0xFFFBBF24)),
        ],
      ),
      // 4. AGAMA
      StatData(
        id: "agama", judul: "Statistik Agama", satuan: "Jiwa",
        subjudul: "Keterangan jumlah yang beragama muslim, kristen, katolik, budha, hindu, dan konghucu",
        deskripsi: "Keberagaman agama di desa kami adalah kekuatan sosial yang harmonis. Kami senantiasa menjaga toleransi dan kerukunan antarumat beragama.",
        data: [
          ChartData("Kristen", sum((d) => d.kristen).toDouble(), const Color(0xFF6366F1)),
          ChartData("Muslim", sum((d) => d.muslim).toDouble(), const Color(0xFFEC4899)),
          ChartData("Katolik", sum((d) => d.katolik).toDouble(), const Color(0xFFA78BFA)),
          ChartData("Lainnya", sum((d) => d.agamaLainnya).toDouble(), const Color(0xFF34D399)),
        ],
      ),
      // 5. PERKAWINAN
      StatData(
        id: "perkawinan", judul: "Statistik Status Perkawinan", satuan: "Jiwa",
        subjudul: "Keterangan jumlah orang yang kawin dan belum kawin",
        deskripsi: "Data status perkawinan membantu dalam pendataan kependudukan dan perencanaan program kesejahteraan keluarga di tingkat dusun.",
        data: [
          ChartData("Sudah Kawin", sum((d) => d.kawin).toDouble(), const Color(0xFF6366F1)),
          ChartData("Belum Kawin", sum((d) => d.belumKawin).toDouble(), const Color(0xFFEC4899)),
          ChartData("Cerai", sum((d) => d.cerai).toDouble(), const Color(0xFFA78BFA)),
        ],
      ),
      // 6. PENDUDUK
      StatData(
        id: "penduduk", judul: "Statistik Penduduk", satuan: "Jiwa",
        subjudul: "Keterangan jumlah penduduk berdasarkan jenis kelamin",
        deskripsi: "Data real-time penduduk laki-laki dan perempuan untuk memastikan keseimbangan demografi dan ketepatan distribusi bantuan sosial.",
        data: [
          ChartData("Laki-laki", sum((d) => d.lakiLaki).toDouble(), const Color(0xFF6366F1)),
          ChartData("Perempuan", sum((d) => d.perempuan).toDouble(), const Color(0xFFEC4899)),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final infografisAsync = ref.watch(infografisProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: infografisAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF57A677))),
        error: (e, _) => Center(child: Text("Gagal memuat statistik: $e")),
        data: (dusunList) {
          if (dusunList.isEmpty) return const Center(child: Text("Data statistik belum tersedia."));

          final activeStats = _generateChartData(dusunList, _selectedDusunId);

          return CustomScrollView(
            slivers: [
              // 1. HERO SECTION (Menampung Chart Pertama: USIA)
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF57A677), Color(0xFF4EA674)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(top: -50, left: -50, child: _buildBlob(300, Colors.blue.withOpacity(0.3))),
                      Positioned(bottom: -50, right: -50, child: _buildBlob(350, Colors.indigo.withOpacity(0.2))),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
                        child: Column(
                          children: [
                            const Text(
                              "Infografis",
                              style: TextStyle(
                                fontSize: 52, fontWeight: FontWeight.w900, color: Colors.white,
                                fontFamily: 'Georgia', fontStyle: FontStyle.italic,
                                shadows: [Shadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 4))],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Data Statistik Kependudukan Desa Sibarani Nasampulu Secara Terpadu & Realtime",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w600, height: 1.5),
                            ),
                            const SizedBox(height: 40),
                            // CHART PERTAMA (USIA)
                            StatCard(
                              item: activeStats[0],
                              isDark: true,
                              selectedDusunId: _selectedDusunId,
                              dusunList: dusunList,
                              onDusunChanged: (v) => setState(() => _selectedDusunId = v!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. OTHER SECTIONS (5 Chart Sisanya dengan warna selang-seling)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final item = activeStats[index + 1];
                    // Selang-seling warna putih dan hijau
                    final isGreen = index % 2 != 0;

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                      color: isGreen ? const Color(0xFF4EA674) : Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.judul,
                            style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.w900,
                              color: isGreen ? Colors.white : const Color(0xFF1E293B),
                              fontFamily: 'Georgia', fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.subjudul,
                            style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold,
                              color: isGreen ? Colors.white.withOpacity(0.9) : const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.deskripsi,
                            style: TextStyle(
                              fontSize: 14, height: 1.7,
                              color: isGreen ? Colors.white.withOpacity(0.8) : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 32),
                          StatCard(
                            item: item,
                            isDark: isGreen,
                            selectedDusunId: _selectedDusunId,
                            dusunList: dusunList,
                            onDusunChanged: (v) => setState(() => _selectedDusunId = v!),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: activeStats.length - 1, // Sisa 5 item
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

// ── KOMPONEN STATCARD ──
class StatCard extends StatelessWidget {
  final StatData item;
  final bool isDark;
  final String selectedDusunId;
  final List<DusunStatModel> dusunList;
  final ValueChanged<String?> onDusunChanged;

  const StatCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.selectedDusunId,
    required this.dusunList,
    required this.onDusunChanged,
  });

  @override
  Widget build(BuildContext context) {
    final double total = item.data.fold(0, (sum, d) => sum + d.value);
    final cardColor = isDark ? Colors.white.withOpacity(0.12) : Colors.white;
    final labelColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("DATA REALTIME", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: labelColor, letterSpacing: 1.2)),
              // Dropdown Menggunakan ID Dusun seperti di React
              DropdownButton<String>(
                value: selectedDusunId,
                dropdownColor: isDark ? const Color(0xFF4EA674) : Colors.white,
                underline: const SizedBox(),
                icon: Icon(Icons.arrow_drop_down, color: labelColor, size: 18),
                style: TextStyle(fontSize: 11, color: labelColor, fontWeight: FontWeight.w700),
                onChanged: onDusunChanged,
                items: [
                  DropdownMenuItem(value: "all", child: Text("Semua Dusun", style: TextStyle(color: isDark ? Colors.white : Colors.black))),
                  ...dusunList.map((d) => DropdownMenuItem(value: d.id, child: Text(d.namaDusun, style: TextStyle(color: isDark ? Colors.white : Colors.black))))
                ],
              ),
            ],
          ),
          Text(
            NumberFormat.decimalPattern('id').format(total),
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF4EA674)),
          ),
          Text(
            "${NumberFormat.decimalPattern('id').format(total)} ${item.satuan}",
            style: TextStyle(fontSize: 11, color: labelColor, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                width: 120, height: 120,
                child: total == 0
                    ? Center(child: Icon(Icons.pie_chart_outline, color: isDark ? Colors.white24 : Colors.grey.shade300, size: 80))
                    : PieChart(
                  PieChartData(
                    sectionsSpace: 2, centerSpaceRadius: 35,
                    sections: item.data.map((d) => PieChartSectionData(color: d.color, value: d.value, title: '', radius: 15)).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: item.data.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: d.color, shape: BoxShape.circle)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(d.name, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFFEEEEEE) : const Color(0xFF334155), fontWeight: FontWeight.w600))),
                        Text(NumberFormat.decimalPattern('id').format(d.value), style: TextStyle(fontSize: 11, color: labelColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )).toList(),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}