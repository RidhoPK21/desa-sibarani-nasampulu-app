import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/dusun_provider.dart';
import '../models/dusun_model.dart';

class TambahDusunScreen extends ConsumerStatefulWidget {
  final DusunModel? dusun;
  const TambahDusunScreen({super.key, this.dusun});

  @override
  ConsumerState<TambahDusunScreen> createState() => _TambahDusunScreenState();
}

class _TambahDusunScreenState extends ConsumerState<TambahDusunScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedDusunId;
  String? _selectedDusunNama;
  late TextEditingController _lakiCtrl;
  late TextEditingController _perempuanCtrl;
  bool _isSaving = false;
  int _activeTabIndex = 0;

  final List<String> _tabs = ["Info Dasar", "Agama & Perkawinan", "Usia", "Pendidikan", "Pekerjaan"];
  final Map<String, String> _dusunOptions = {"D01": "Dusun 1", "D02": "Dusun 2", "D03": "Dusun 3", "D04": "Dusun 4"};

  late List<AgamaModel> _agamas;
  late List<PerkawinanModel> _perkawinans;
  late List<UsiaModel> _usias;
  late List<PendidikanModel> _pendidikans;
  late List<PekerjaanModel> _pekerjaans;

  @override
  void initState() {
    super.initState();
    final d = widget.dusun;
    _selectedDusunNama = d?.namaDusun;
    if (d != null) {
      _selectedDusunId = _dusunOptions.entries.firstWhere((e) => e.value == d.namaDusun, orElse: () => const MapEntry("", "")).key;
      if (_selectedDusunId == "") _selectedDusunId = null;
    }
    
    _lakiCtrl = TextEditingController(text: d?.pendudukLaki.toString() ?? '0');
    _perempuanCtrl = TextEditingController(text: d?.pendudukPerempuan.toString() ?? '0');

    _agamas = d?.agamas ?? [
      AgamaModel(agama: "Islam", jumlahJiwa: 0),
      AgamaModel(agama: "Kristen", jumlahJiwa: 0),
      AgamaModel(agama: "Katolik", jumlahJiwa: 0),
      AgamaModel(agama: "Hindu", jumlahJiwa: 0),
      AgamaModel(agama: "Buddha", jumlahJiwa: 0),
    ];

    _perkawinans = d?.perkawinans ?? [
      PerkawinanModel(statusPerkawinan: "Belum Kawin", jumlahJiwa: 0),
      PerkawinanModel(statusPerkawinan: "Kawin", jumlahJiwa: 0),
      PerkawinanModel(statusPerkawinan: "Cerai Hidup", jumlahJiwa: 0),
      PerkawinanModel(statusPerkawinan: "Cerai Mati", jumlahJiwa: 0),
    ];

    _usias = d?.usias ?? [
      UsiaModel(kelompokUsia: "0 - 4 Tahun (Balita)", jumlahJiwa: 0),
      UsiaModel(kelompokUsia: "5 - 14 Tahun (Anak)", jumlahJiwa: 0),
      UsiaModel(kelompokUsia: "15 - 39 Tahun (Pemuda)", jumlahJiwa: 0),
      UsiaModel(kelompokUsia: "40 - 64 Tahun (Dewasa)", jumlahJiwa: 0),
      UsiaModel(kelompokUsia: "65 Tahun Keatas (Lansia)", jumlahJiwa: 0),
    ];

    _pendidikans = d?.pendidikans ?? [
      PendidikanModel(tingkatPendidikan: "Tidak/Belum Sekolah", jumlahJiwa: 0),
      PendidikanModel(tingkatPendidikan: "Tamat SD/Sederajat", jumlahJiwa: 0),
      PendidikanModel(tingkatPendidikan: "Tamat SMP/Sederajat", jumlahJiwa: 0),
      PendidikanModel(tingkatPendidikan: "Tamat SMA/Sederajat", jumlahJiwa: 0),
      PendidikanModel(tingkatPendidikan: "Diploma / Sarjana (S1/S2/S3)", jumlahJiwa: 0),
    ];

    _pekerjaans = d?.pekerjaans ?? [
      PekerjaanModel(jenisPekerjaan: "Belum/Tidak Bekerja", jumlahJiwa: 0),
      PekerjaanModel(jenisPekerjaan: "Mengurus Rumah Tangga", jumlahJiwa: 0),
      PekerjaanModel(jenisPekerjaan: "Pelajar/Mahasiswa", jumlahJiwa: 0),
      PekerjaanModel(jenisPekerjaan: "PNS/TNI/Polri", jumlahJiwa: 0),
      PekerjaanModel(jenisPekerjaan: "Wiraswasta / Pengusaha", jumlahJiwa: 0),
      PekerjaanModel(jenisPekerjaan: "Karyawan Swasta", jumlahJiwa: 0),
      PekerjaanModel(jenisPekerjaan: "Petani/Pekebun", jumlahJiwa: 0),
      PekerjaanModel(jenisPekerjaan: "Buruh Harian Lepas", jumlahJiwa: 0),
      PekerjaanModel(jenisPekerjaan: "Pekerjaan Lainnya", jumlahJiwa: 0),
    ];
  }

  @override
  void dispose() {
    _lakiCtrl.dispose();
    _perempuanCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpanData() async {
    if (_selectedDusunId == null && widget.dusun == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih Dusun terlebih dahulu")));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final newDusun = DusunModel(
        namaDusun: _selectedDusunNama!,
        pendudukLaki: int.tryParse(_lakiCtrl.text) ?? 0,
        pendudukPerempuan: int.tryParse(_perempuanCtrl.text) ?? 0,
        agamas: _agamas,
        perkawinans: _perkawinans,
        usias: _usias,
        pendidikans: _pendidikans,
        pekerjaans: _pekerjaans,
      );

      if (widget.dusun != null) {
        await ref.read(dusunListProvider.notifier).updateDusun(widget.dusun!.id!, newDusun);
      } else {
        await ref.read(dusunListProvider.notifier).addDusun(newDusun);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data Dusun Berhasil Disimpan!")));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menyimpan: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF4EA674);
    const teal900 = Color(0xFF134E4A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Image.asset('assets/logo-toba.jpg', height: 50, errorBuilder: (c, e, s) => const Icon(Icons.account_balance, size: 40, color: primaryGreen)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.dusun != null ? "Ubah Demografi: ${widget.dusun!.namaDusun}" : "Input Data Dusun & Demografi Baru",
                      style: const TextStyle(color: teal900, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), side: const BorderSide(color: Colors.grey)),
                      child: const Text("Batal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _simpanData,
                      icon: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_circle_outline, size: 20),
                      label: const Text("Simpan Data", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final isSelected = _activeTabIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _activeTabIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? teal900 : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: isSelected ? teal900 : Colors.grey.shade300),
                      ),
                      alignment: Alignment.center,
                      child: Text(_tabs[index], style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), border: Border.all(color: Colors.grey.shade100)),
                child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Form(key: _formKey, child: _buildActiveTabContent())),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_activeTabIndex) {
      case 0: return _buildInfoDasar();
      case 1: return _buildAgamaPerkawinan();
      case 2: return _buildUsia();
      case 3: return _buildPendidikan();
      case 4: return _buildPekerjaan();
      default: return const SizedBox();
    }
  }

  Widget _buildInfoDasar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Profil Dusun"),
        const SizedBox(height: 12),
        const Text("Pilih Dusun", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedDusunId,
          disabledHint: Text(_selectedDusunNama ?? ""),
          decoration: _inputDecoration(),
          items: widget.dusun != null ? null : _dusunOptions.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
          onChanged: widget.dusun != null ? null : (val) => setState(() { _selectedDusunId = val; _selectedDusunNama = _dusunOptions[val]; }),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle("Total Penduduk (Master)"),
        const SizedBox(height: 12),
        _buildInputField("Penduduk Laki-Laki (Jiwa)", _lakiCtrl, color: Colors.blue),
        const SizedBox(height: 16),
        _buildInputField("Penduduk Perempuan (Jiwa)", _perempuanCtrl, color: Colors.pink),
      ],
    );
  }

  Widget _buildAgamaPerkawinan() {
    return Column(
      children: [
        _buildSectionTitle("Demografi Agama", color: Colors.green),
        const SizedBox(height: 12),
        ..._agamas.asMap().entries.map((e) => _buildArrayInput(e.value.agama, (val) => _agamas[e.key] = AgamaModel(agama: e.value.agama, jumlahJiwa: int.tryParse(val) ?? 0), initialValue: e.value.jumlahJiwa)),
        const SizedBox(height: 24),
        _buildSectionTitle("Status Perkawinan", color: Colors.blue),
        const SizedBox(height: 12),
        ..._perkawinans.asMap().entries.map((e) => _buildArrayInput(e.value.statusPerkawinan, (val) => _perkawinans[e.key] = PerkawinanModel(statusPerkawinan: e.value.statusPerkawinan, jumlahJiwa: int.tryParse(val) ?? 0), initialValue: e.value.jumlahJiwa)),
      ],
    );
  }

  Widget _buildUsia() {
    return Column(
      children: [
        _buildSectionTitle("Demografi Berdasarkan Rentang Usia", color: Colors.orange),
        const SizedBox(height: 12),
        ..._usias.asMap().entries.map((e) => _buildArrayInput(e.value.kelompokUsia, (val) => _usias[e.key] = UsiaModel(kelompokUsia: e.value.kelompokUsia, jumlahJiwa: int.tryParse(val) ?? 0), initialValue: e.value.jumlahJiwa)),
      ],
    );
  }

  Widget _buildPendidikan() {
    return Column(
      children: [
        _buildSectionTitle("Tingkat Pendidikan Terakhir", color: Colors.purple),
        const SizedBox(height: 12),
        ..._pendidikans.asMap().entries.map((e) => _buildArrayInput(e.value.tingkatPendidikan, (val) => _pendidikans[e.key] = PendidikanModel(tingkatPendidikan: e.value.tingkatPendidikan, jumlahJiwa: int.tryParse(val) ?? 0), initialValue: e.value.jumlahJiwa)),
      ],
    );
  }

  Widget _buildPekerjaan() {
    return Column(
      children: [
        _buildSectionTitle("Mata Pencaharian Pokok", color: Colors.red),
        const SizedBox(height: 12),
        ..._pekerjaans.asMap().entries.map((e) => _buildArrayInput(e.value.jenisPekerjaan, (val) => _pekerjaans[e.key] = PekerjaanModel(jenisPekerjaan: e.value.jenisPekerjaan, jumlahJiwa: int.tryParse(val) ?? 0), initialValue: e.value.jumlahJiwa)),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {Color color = const Color(0xFF1E293B)}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: color, width: 2)),
      ),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController ctrl, {Color color = const Color(0xFF334155)}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)), const SizedBox(height: 8), TextFormField(controller: ctrl, keyboardType: TextInputType.number, style: const TextStyle(fontWeight: FontWeight.bold), decoration: _inputDecoration(focusColor: color))]);
  }

  Widget _buildArrayInput(String label, ValueChanged<String> onChanged, {int initialValue = 0}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          const SizedBox(width: 12),
          Expanded(child: TextFormField(initialValue: initialValue == 0 ? '' : initialValue.toString(), keyboardType: TextInputType.number, textAlign: TextAlign.center, onChanged: onChanged, decoration: _inputDecoration().copyWith(hintText: '0'))),
          const SizedBox(width: 8),
          const Text("Jiwa", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({Color focusColor = const Color(0xFF10B981)}) {
    return InputDecoration(filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: focusColor, width: 2)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12));
  }
}
