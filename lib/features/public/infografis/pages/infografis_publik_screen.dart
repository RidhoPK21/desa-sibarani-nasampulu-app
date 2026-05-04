import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// --- MOCK DATA UNTUK TAMPILAN FULL ---
final mockStats = [
  StatData(
    id: "penduduk",
    judul: "Statistik Penduduk",
    subjudul: "Keterangan jumlah penduduk berdasarkan jenis kelamin",
    deskripsi: "Data real-time penduduk laki-laki dan perempuan untuk memastikan keseimbangan demografi dan ketepatan distribusi bantuan sosial.",
    satuan: "Jiwa",
    data: [
      ChartData("Laki-laki", 1250, const Color(0xFF6366F1)),
      ChartData("Perempuan", 1320, const Color(0xFFEC4899)),
    ],
  ),
  StatData(
    id: "usia",
    judul: "Statistik Usia",
    subjudul: "Keterangan jumlah balita, anak, remaja, dewasa dan lansia",
    deskripsi: "Kami berkomitmen untuk memantau pertumbuhan penduduk secara berkala guna merencanakan program pelayanan kesehatan yang tepat sasaran.",
    satuan: "Jiwa",
    data: [
      ChartData("Balita", 250, const Color(0xFF6366F1)),
      ChartData("Anak-anak", 400, const Color(0xFFEC4899)),
      ChartData("Remaja", 600, const Color(0xFFA78BFA)),
      ChartData("Dewasa", 900, const Color(0xFF34D399)),
      ChartData("Lansia", 420, const Color(0xFFFBBF24)),
    ],
  ),
  StatData(
    id: "pendidikan",
    judul: "Statistik Pendidikan",
    subjudul: "Tingkat pendidikan terakhir penduduk Desa Sibarani",
    deskripsi: "Pendidikan adalah pilar utama pembangunan desa. Kami menyajikan data ini sebagai acuan program peningkatan SDM.",
    satuan: "Siswa",
    data: [
      ChartData("SD", 300, const Color(0xFF6366F1)),
      ChartData("SMP", 280, const Color(0xFFEC4899)),
      ChartData("SMA", 450, const Color(0xFFA78BFA)),
      ChartData("Sarjana", 150, const Color(0xFF34D399)),
      ChartData("Lainnya", 100, const Color(0xFFFBBF24)),
    ],
  ),
];

class InfografisPublikScreen extends StatefulWidget {
  const InfografisPublikScreen({super.key});

  @override
  State<InfografisPublikScreen> createState() => _InfografisPublikScreenState();
}

class _InfografisPublikScreenState extends State<InfografisPublikScreen> {
  String _selectedDusun = "Semua Dusun";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // 1. HERO SECTION (GRADIENT & TITLES)
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
                  // Dekorasi Blobs (Lingkaran Blur)
                  Positioned(
                    top: -50,
                    left: -50,
                    child: _buildBlob(300, Colors.blue.withOpacity(0.3)),
                  ),
                  Positioned(
                    bottom: -50,
                    right: -50,
                    child: _buildBlob(350, Colors.indigo.withOpacity(0.2)),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
                    child: Column(
                      children: [
                        const Text(
                          "Infografis",
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontFamily: 'Georgia',
                            fontStyle: FontStyle.italic,
                            shadows: [Shadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 4))],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Data Statistik Kependudukan Desa Sibarani Nasampulu Secara Terpadu & Realtime",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.95),
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // First Section (Penduduk) embedded in Hero for flow
                        StatCard(item: mockStats[0], isDark: true, selectedDusun: _selectedDusun, onDusunChanged: (v) => setState(() => _selectedDusun = v!)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. OTHER SECTIONS (ALTERNATING WHITE/GREEN)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = mockStats[index + 1];
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
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: isGreen ? Colors.white : const Color(0xFF1E293B),
                          fontFamily: 'Georgia',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.subjudul,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isGreen ? Colors.white.withOpacity(0.9) : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.deskripsi,
                        style: TextStyle(
                          fontSize: 14,
                          color: isGreen ? Colors.white.withOpacity(0.8) : const Color(0xFF64748B),
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 32),
                      StatCard(item: item, isDark: isGreen, selectedDusun: _selectedDusun, onDusunChanged: (v) => setState(() => _selectedDusun = v!)),
                    ],
                  ),
                );
              },
              childCount: mockStats.length - 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final StatData item;
  final bool isDark;
  final String selectedDusun;
  final ValueChanged<String?> onDusunChanged;

  const StatCard({super.key, required this.item, required this.isDark, required this.selectedDusun, required this.onDusunChanged});

  @override
  Widget build(BuildContext context) {
    final double total = item.data.fold(0, (sum, d) => sum + d.value);
    final cardColor = isDark ? Colors.white.withOpacity(0.12) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final labelColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("CHART TITLE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: labelColor, letterSpacing: 1.2)),
              DropdownButton<String>(
                value: selectedDusun,
                dropdownColor: isDark ? const Color(0xFF4EA674) : Colors.white,
                underline: const SizedBox(),
                icon: Icon(Icons.arrow_drop_down, color: labelColor, size: 18),
                style: TextStyle(fontSize: 11, color: labelColor, fontWeight: FontWeight.w700),
                onChanged: onDusunChanged,
                items: ["Semua Dusun", "Dusun 1", "Dusun 2", "Dusun 3"].map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(color: isDark ? Colors.white : Colors.black)))).toList(),
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
                width: 120,
                height: 120,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 35,
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

class StatData {
  final String id, judul, subjudul, deskripsi, satuan;
  final List<ChartData> data;
  StatData({required this.id, required this.judul, required this.subjudul, required this.deskripsi, required this.satuan, required this.data});
}

class ChartData {
  final String name;
  final double value;
  final Color color;
  ChartData(this.name, this.value, this.color);
}
