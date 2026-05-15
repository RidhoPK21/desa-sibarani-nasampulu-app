import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_infografis_provider.dart';

class AdminInfografisScreen extends ConsumerStatefulWidget {
  const AdminInfografisScreen({super.key});

  @override
  ConsumerState<AdminInfografisScreen> createState() => _AdminInfografisScreenState();
}

class _AdminInfografisScreenState extends ConsumerState<AdminInfografisScreen> {
  String _viewMode = 'list';
  bool _isEdit = false;

  // State Data Master
  late Map<String, dynamic> _formData;

  // Template Form Statis (Sama seperti InitialFormState di React)
  Map<String, dynamic> _getInitialFormState() {
    return {
      "id": "",
      "nama_dusun": "",
      "penduduk_laki": 0,
      "penduduk_perempuan": 0,
      "agamas": [
        {"agama": "Islam", "jumlah_jiwa": 0},
        {"agama": "Kristen", "jumlah_jiwa": 0},
        {"agama": "Katolik", "jumlah_jiwa": 0},
        {"agama": "Hindu", "jumlah_jiwa": 0},
        {"agama": "Buddha", "jumlah_jiwa": 0},
      ],
      "perkawinans": [
        {"status_perkawinan": "Belum Kawin", "jumlah_jiwa": 0},
        {"status_perkawinan": "Kawin", "jumlah_jiwa": 0},
        {"status_perkawinan": "Cerai Hidup", "jumlah_jiwa": 0},
        {"status_perkawinan": "Cerai Mati", "jumlah_jiwa": 0},
      ],
      "usias": [
        {"kelompok_usia": "0 - 4 Tahun (Balita)", "jumlah_jiwa": 0},
        {"kelompok_usia": "5 - 14 Tahun (Anak)", "jumlah_jiwa": 0},
        {"kelompok_usia": "15 - 39 Tahun (Pemuda)", "jumlah_jiwa": 0},
        {"kelompok_usia": "40 - 64 Tahun (Dewasa)", "jumlah_jiwa": 0},
        {"kelompok_usia": "65 Tahun Keatas (Lansia)", "jumlah_jiwa": 0},
      ],
      "pendidikans": [
        {"tingkat_pendidikan": "Tidak/Belum Sekolah", "jumlah_jiwa": 0},
        {"tingkat_pendidikan": "Tamat SD/Sederajat", "jumlah_jiwa": 0},
        {"tingkat_pendidikan": "Tamat SMP/Sederajat", "jumlah_jiwa": 0},
        {"tingkat_pendidikan": "Tamat SMA/Sederajat", "jumlah_jiwa": 0},
        {"tingkat_pendidikan": "Diploma / Sarjana (S1/S2/S3)", "jumlah_jiwa": 0},
      ],
      "pekerjaans": [
        {"jenis_pekerjaan": "Belum/Tidak Bekerja", "jumlah_jiwa": 0},
        {"jenis_pekerjaan": "Mengurus Rumah Tangga", "jumlah_jiwa": 0},
        {"jenis_pekerjaan": "Pelajar/Mahasiswa", "jumlah_jiwa": 0},
        {"jenis_pekerjaan": "PNS/TNI/Polri", "jumlah_jiwa": 0},
        {"jenis_pekerjaan": "Wiraswasta / Pengusaha", "jumlah_jiwa": 0},
        {"jenis_pekerjaan": "Karyawan Swasta", "jumlah_jiwa": 0},
        {"jenis_pekerjaan": "Petani/Pekebun", "jumlah_jiwa": 0},
        {"jenis_pekerjaan": "Buruh Harian Lepas", "jumlah_jiwa": 0},
        {"jenis_pekerjaan": "Pekerjaan Lainnya", "jumlah_jiwa": 0},
      ],
    };
  }

  @override
  void initState() {
    super.initState();
    _formData = _getInitialFormState();
  }

  void _openAddForm() {
    setState(() {
      _isEdit = false;
      _formData = _getInitialFormState();
      _viewMode = 'form';
    });
  }

  void _openEditForm(Map<String, dynamic> item) {
    setState(() {
      _isEdit = true;

      // Merging data seperti di React
      Map<String, dynamic> mergedData = _getInitialFormState();
      mergedData['id'] = item['id'];
      mergedData['nama_dusun'] = item['nama_dusun'];
      mergedData['penduduk_laki'] = item['penduduk_laki'] ?? 0;
      mergedData['penduduk_perempuan'] = item['penduduk_perempuan'] ?? 0;

      if (item['agamas'] != null && (item['agamas'] as List).isNotEmpty) mergedData['agamas'] = item['agamas'];
      if (item['perkawinans'] != null && (item['perkawinans'] as List).isNotEmpty) mergedData['perkawinans'] = item['perkawinans'];
      if (item['usias'] != null && (item['usias'] as List).isNotEmpty) mergedData['usias'] = item['usias'];
      if (item['pendidikans'] != null && (item['pendidikans'] as List).isNotEmpty) mergedData['pendidikans'] = item['pendidikans'];
      if (item['pekerjaans'] != null && (item['pekerjaans'] as List).isNotEmpty) mergedData['pekerjaans'] = item['pekerjaans'];

      _formData = mergedData;
      _viewMode = 'form';
    });
  }

  Future<void> _handleSave() async {
    if (_formData['id'] == "" || _formData['nama_dusun'] == "") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih Dusun pada Tab Info Dasar!'), backgroundColor: Colors.orange));
      return;
    }

    await ref.read(adminInfografisControllerProvider).saveDusun(_formData, _isEdit);

    if (mounted) {
      final controller = ref.read(adminInfografisControllerProvider);
      if (controller.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(controller.errorMessage!), backgroundColor: Colors.red));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data Demografi Dusun berhasil disimpan!'), backgroundColor: Colors.green));
        ref.invalidate(adminDusunProvider);
        setState(() => _viewMode = 'list');
      }
    }
  }

  Future<void> _confirmDelete(String id, String nama) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data Dusun?'),
        content: Text('Semua data statistik demografi untuk $nama akan dihapus selamanya. Yakin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(adminInfografisControllerProvider).deleteDusun(id);
      if (mounted) {
        final controller = ref.read(adminInfografisControllerProvider);
        if (controller.errorMessage == null) {
          ref.invalidate(adminDusunProvider);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data Dusun berhasil dihapus!'), backgroundColor: Colors.green));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(controller.errorMessage!), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(adminInfografisControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(_viewMode == 'list' ? 'Infografis & Demografi Dusun' : (_isEdit ? 'Ubah Demografi' : 'Tambah Dusun Baru')),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF064E3B),
        elevation: 0,
        leading: _viewMode == 'form'
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _viewMode = 'list'))
            : null,
        actions: _viewMode == 'form'
            ? [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FilledButton.icon(
              onPressed: isLoading ? null : _handleSave,
              icon: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check_circle, size: 18),
              label: const Text('Simpan Data'),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            ),
          )
        ]
            : null,
      ),
      body: _viewMode == 'list' ? _buildList() : _buildForm(),
      floatingActionButton: _viewMode == 'list'
          ? FloatingActionButton.extended(
        onPressed: _openAddForm,
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Dusun', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      )
          : null,
    );
  }

  // ─── MODE LIST DUSUN ───
  Widget _buildList() {
    final dusunAsync = ref.watch(adminDusunProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(adminDusunProvider),
      child: dusunAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Gagal memuat data: $err')),
        data: (dusunList) {
          if (dusunList.isEmpty) return const Center(child: Text('Belum ada data Dusun.'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: dusunList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = dusunList[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(12)),
                        child: Text(item['id'] ?? '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.teal.shade900)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['nama_dusun'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.man, size: 16, color: Colors.blue),
                                Text(' ${item['penduduk_laki'] ?? 0}  ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                const Icon(Icons.woman, size: 16, color: Colors.pink),
                                Text(' ${item['penduduk_perempuan'] ?? 0}  ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.teal.shade100, borderRadius: BorderRadius.circular(8)),
                                  child: Text('Total: ${item['total_penduduk'] ?? 0}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal.shade800)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _openEditForm(item)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDelete(item['id'].toString(), item['nama_dusun'])),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ─── MODE FORM DENGAN TAB ───
  Widget _buildForm() {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              isScrollable: true,
              labelColor: Colors.teal.shade900,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.teal.shade900,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: "Info Dasar"),
                Tab(text: "Agama & Perkawinan"),
                Tab(text: "Usia"),
                Tab(text: "Pendidikan"),
                Tab(text: "Pekerjaan"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildTabDasar(),
                _buildTabAgamaPerkawinan(),
                _buildTabArrayList("Demografi Berdasarkan Rentang Usia", "usias", "kelompok_usia", Colors.orange),
                _buildTabArrayList("Tingkat Pendidikan Terakhir", "pendidikans", "tingkat_pendidikan", Colors.purple),
                _buildTabArrayList("Mata Pencaharian Pokok", "pekerjaans", "jenis_pekerjaan", Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: DASAR (Dropdown Dusun & Laki/Perempuan)
  Widget _buildTabDasar() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Pilih Dusun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12), color: _isEdit ? Colors.grey.shade100 : Colors.white),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _formData['id'] == "" ? null : _formData['id'],
              hint: const Text("-- Pilih Dusun --"),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: "D01", child: Text("Dusun 1")),
                DropdownMenuItem(value: "D02", child: Text("Dusun 2")),
                DropdownMenuItem(value: "D03", child: Text("Dusun 3")),
                DropdownMenuItem(value: "D04", child: Text("Dusun 4")),
              ],
              onChanged: _isEdit ? null : (val) {
                setState(() {
                  _formData['id'] = val!;
                  _formData['nama_dusun'] = "Dusun ${val.substring(2)}";
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Total Penduduk Laki-Laki', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _formData['penduduk_laki'].toString(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), suffixText: 'Jiwa'),
          onChanged: (val) => _formData['penduduk_laki'] = int.tryParse(val) ?? 0,
        ),
        const SizedBox(height: 16),
        const Text('Total Penduduk Perempuan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.pink)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _formData['penduduk_perempuan'].toString(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), suffixText: 'Jiwa'),
          onChanged: (val) => _formData['penduduk_perempuan'] = int.tryParse(val) ?? 0,
        ),
      ],
    );
  }

  // TAB 2: AGAMA & PERKAWINAN
  Widget _buildTabAgamaPerkawinan() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Demografi Agama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal)),
        const Divider(),
        ...(_formData['agamas'] as List).asMap().entries.map((entry) {
          int idx = entry.key;
          Map item = entry.value;
          return _buildRowInput(item['agama'], item['jumlah_jiwa'].toString(), (val) => _formData['agamas'][idx]['jumlah_jiwa'] = int.tryParse(val) ?? 0);
        }),
        const SizedBox(height: 32),
        const Text('Status Perkawinan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
        const Divider(),
        ...(_formData['perkawinans'] as List).asMap().entries.map((entry) {
          int idx = entry.key;
          Map item = entry.value;
          return _buildRowInput(item['status_perkawinan'], item['jumlah_jiwa'].toString(), (val) => _formData['perkawinans'][idx]['jumlah_jiwa'] = int.tryParse(val) ?? 0);
        }),
      ],
    );
  }

  // HELPER UNTUK TAB 3, 4, 5
  Widget _buildTabArrayList(String title, String arrayKey, String labelKey, MaterialColor color) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color.shade800)),
        const Divider(),
        ...(_formData[arrayKey] as List).asMap().entries.map((entry) {
          int idx = entry.key;
          Map item = entry.value;
          return _buildRowInput(item[labelKey], item['jumlah_jiwa'].toString(), (val) => _formData[arrayKey][idx]['jumlah_jiwa'] = int.tryParse(val) ?? 0);
        }),
      ],
    );
  }

  // KOTAK INPUT UNTUK SETIAP BARIS ARRAY
  Widget _buildRowInput(String label, String initialValue, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
            flex: 1,
            child: TextFormField(
              initialValue: initialValue == "0" ? "" : initialValue,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  filled: true, fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixText: 'Jiwa', suffixStyle: const TextStyle(fontSize: 10)
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}