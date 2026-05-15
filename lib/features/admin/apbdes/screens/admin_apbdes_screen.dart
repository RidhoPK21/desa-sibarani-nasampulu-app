import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/admin_apbdes_provider.dart';

// =========================================================================
//  CUSTOM WIDGET: INPUT UANG (Otomatis Format Rupiah)
// =========================================================================
class InputUangField extends StatelessWidget {
  final String label;
  final num initialValue;
  final Function(num) onChanged;

  const InputUangField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: initialValue == 0 ? '' : initialValue.toString(),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
            onChanged: (val) {
              final rawNumber = int.tryParse(val.replaceAll(RegExp(r'\D'), '')) ?? 0;
              onChanged(rawNumber);
            },
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// MAIN SCREEN
// =========================================================================
class AdminApbdesScreen extends ConsumerStatefulWidget {
  const AdminApbdesScreen({super.key});

  @override
  ConsumerState<AdminApbdesScreen> createState() => _AdminApbdesScreenState();
}

class _AdminApbdesScreenState extends ConsumerState<AdminApbdesScreen> {
  String _viewMode = 'list';
  Map<String, dynamic>? _selectedItem;

  // Format Rupiah untuk Text
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  // State Form
  late Map<String, dynamic> _formData;

  Map<String, dynamic> _getInitialFormState() {
    return {
      "nama_desa": "Desa Sibarani Nasampulu",
      "tahun": DateTime.now().year,
      "alasan_perubahan": "",
      "pendapatan_asli_desa": 0,
      "dana_desa": 0,
      "alokasi_dana_desa": 0,
      "bagi_hasil_pajak_retribusi": 0,
      "lain_lain_pendapatan_sah": 0,
      "siltap_kepala_desa": 0,
      "siltap_perangkat_desa": 0,
      "jaminan_sosial_aparatur": 0,
      "operasional_pemerintahan_desa": 0,
      "tunjangan_bpd": 0,
      "operasional_bpd": 0,
      "operasional_dana_desa": 0,
      "sarana_prasarana_kantor": 0,
      "pengisian_mutasi_perangkat": 0,
      "penyuluhan_pendidikan": 0,
      "sarana_prasarana_pendidikan": 0,
      "sarana_prasarana_perpustakaan": 0,
      "pengelolaan_perpustakaan": 0,
      "penyelenggaraan_posyandu": 0,
      "penyuluhan_kesehatan": 0,
      "pemeliharaan_jalan_lingkungan": 0,
      "pembangunan_jalan_desa": 0,
      "pembangunan_jalan_usaha_tani": 0,
      "dokumen_tata_ruang": 0,
      "talud_irigasi": 0,
      "sanitasi_pemukiman": 0,
      "fasilitas_pengelolaan_sampah": 0,
      "jaringan_internet_desa": 0,
      "pembinaan_pkk": 0,
      "pelatihan_pertanian_peternakan": 0,
      "pelatihan_aparatur_desa": 0,
      "penyusunan_rencana_program": 0,
      "insentif_kader_pembangunan": 0,
      "insentif_kader_kesehatan_paud": 0,
      "penanggulangan_bencana": 0,
      "keadaan_mendesak": 0,
      "silpa_tahun_sebelumnya": 0,
      "penyertaan_modal_desa": 0,
    };
  }

  @override
  void initState() {
    super.initState();
    _formData = _getInitialFormState();
  }

  void _openAddForm() {
    setState(() {
      _selectedItem = null;
      _formData = _getInitialFormState();
      _viewMode = 'form';
    });
  }

  void _openEditForm(Map<String, dynamic> item) {
    setState(() {
      _selectedItem = item;
      _formData = {...item};
      _formData['alasan_perubahan'] = ""; // Wajib kosong sebelum disubmit versi baru
      _viewMode = 'form';
    });
  }

  Future<void> _handleSave() async {
    if (_selectedItem != null && (_formData['alasan_perubahan'] == null || _formData['alasan_perubahan'].toString().trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alasan perubahan wajib diisi untuk versi baru!'), backgroundColor: Colors.orange));
      return;
    }

    // Bersihkan payload
    final payload = {..._formData};
    payload.remove('id');
    payload.remove('total_pendapatan');
    payload.remove('total_belanja');
    payload.remove('created_at');
    payload.remove('updated_at');

    await ref.read(adminApbdesControllerProvider).saveApbdes(payload, _selectedItem?['id']?.toString());

    if (mounted) {
      final controller = ref.read(adminApbdesControllerProvider);
      if (controller.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(controller.errorMessage!), backgroundColor: Colors.red));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data APBDes berhasil disimpan!'), backgroundColor: Colors.green));
        ref.invalidate(adminApbdesListProvider);
        setState(() => _viewMode = 'list');
      }
    }
  }

  Future<void> _confirmDelete(String id, String tahun, String versi) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus APBDes?'),
        content: Text('Yakin ingin menghapus APBDes Tahun $tahun (Versi $versi) selamanya?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(adminApbdesControllerProvider).deleteApbdes(id);
      if (mounted) {
        final controller = ref.read(adminApbdesControllerProvider);
        if (controller.errorMessage == null) {
          ref.invalidate(adminApbdesListProvider);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('APBDes berhasil dihapus!'), backgroundColor: Colors.green));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(controller.errorMessage!), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(adminApbdesControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(_viewMode == 'list' ? 'Kelola APBDes' : (_selectedItem == null ? 'Input APBDes Baru' : 'Revisi APBDes')),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF064E3B), // teal-900
        elevation: 0,
        leading: _viewMode == 'form'
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _viewMode = 'list'))
            : null,
      ),
      body: _viewMode == 'list' ? _buildList() : _buildForm(isLoading),
      floatingActionButton: _viewMode == 'list'
          ? FloatingActionButton.extended(
        onPressed: _openAddForm,
        backgroundColor: const Color(0xFF10B981), // emerald-500
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Buat APBDes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      )
          : null,
    );
  }

  // ─── TAMPILAN DAFTAR APBDES ───
  Widget _buildList() {
    final apbdesAsync = ref.watch(adminApbdesListProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(adminApbdesListProvider),
      child: apbdesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Gagal memuat data: $err')),
        data: (listData) {
          if (listData.isEmpty) return const Center(child: Text('Belum ada data APBDes.'));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: listData.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = listData[index];
              final isAktif = item['is_aktif'] == 1 || item['is_aktif'] == true;

              final pendapatan = num.tryParse(item['total_pendapatan']?.toString() ?? '0') ?? 0;
              final belanja = num.tryParse(item['total_belanja']?.toString() ?? '0') ?? 0;
              final silpa = num.tryParse(item['silpa_tahun_sebelumnya']?.toString() ?? '0') ?? 0;
              final penyertaanModal = num.tryParse(item['penyertaan_modal_desa']?.toString() ?? '0') ?? 0;

              final pembiayaanNetto = silpa - penyertaanModal;
              final surplusDefisit = pendapatan - belanja;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(item['tahun']?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.teal)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(4)),
                                child: Text('V.${item['versi']}', style: TextStyle(color: Colors.blue.shade800, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 4),
                              if (isAktif)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(4)),
                                  child: Text('AKTIF', style: TextStyle(color: Colors.green.shade800, fontSize: 10, fontWeight: FontWeight.bold)),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                                  child: const Text('ARSIP', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert, color: Colors.grey),
                            itemBuilder: (context) => [
                              if (isAktif) const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Revisi (Versi Baru)')])),
                              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Hapus Permanen', style: TextStyle(color: Colors.red))])),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') _openEditForm(item);
                              if (value == 'delete') _confirmDelete(item['id'].toString(), item['tahun'].toString(), item['versi'].toString());
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildRingkasanRow('Pendapatan', currencyFormat.format(pendapatan), Colors.teal),
                      _buildRingkasanRow('Belanja', currencyFormat.format(belanja), Colors.orange),
                      _buildRingkasanRow('Pembiayaan Netto', currencyFormat.format(pembiayaanNetto), Colors.blue),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Surplus/(Defisit)', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(currencyFormat.format(surplusDefisit), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: surplusDefisit < 0 ? Colors.red : Colors.green)),
                        ],
                      ),
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

  Widget _buildRingkasanRow(String label, String value, MaterialColor color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color.shade700)),
        ],
      ),
    );
  }

  // ─── TAMPILAN FORM (DENGAN TABS) ───
  Widget _buildForm(bool isLoading) {
    return Column(
      children: [
        // Tab Header & Action
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(_selectedItem == null ? "Buat APBDes Awal" : "Revisi (Versi ${_selectedItem!['versi'] + 1})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
              ),
              ElevatedButton.icon(
                onPressed: isLoading ? null : _handleSave,
                icon: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check, size: 18),
                label: const Text('Simpan'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
              )
            ],
          ),
        ),

        // Tabs Content
        Expanded(
          child: DefaultTabController(
            length: 5,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  labelColor: Colors.teal.shade900,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.teal.shade900,
                  tabs: const [
                    Tab(text: "Info Dasar"),
                    Tab(text: "Pendapatan"),
                    Tab(text: "Pemerintahan"),
                    Tab(text: "Pembangunan"),
                    Tab(text: "Lainnya & Pembiayaan"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildTabDasar(),
                      _buildTabPendapatan(),
                      _buildTabPemerintahan(),
                      _buildTabPembangunan(),
                      _buildTabLainnya(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // TAB 1: DASAR
  Widget _buildTabDasar() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_selectedItem != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Alasan Perubahan (Wajib)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _formData['alasan_perubahan'],
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'Tuliskan alasan...', filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
                  onChanged: (val) => _formData['alasan_perubahan'] = val,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        const Text('Tahun Anggaran', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _formData['tahun'].toString(),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
          onChanged: (val) => _formData['tahun'] = int.tryParse(val) ?? DateTime.now().year,
        ),
      ],
    );
  }

  // TAB 2: PENDAPATAN
  Widget _buildTabPendapatan() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        InputUangField(label: 'Pendapatan Asli Desa (PADes)', initialValue: _formData['pendapatan_asli_desa'], onChanged: (val) => _formData['pendapatan_asli_desa'] = val),
        InputUangField(label: 'Dana Desa (DD)', initialValue: _formData['dana_desa'], onChanged: (val) => _formData['dana_desa'] = val),
        InputUangField(label: 'Alokasi Dana Desa (ADD)', initialValue: _formData['alokasi_dana_desa'], onChanged: (val) => _formData['alokasi_dana_desa'] = val),
        InputUangField(label: 'Bagi Hasil Pajak & Retribusi', initialValue: _formData['bagi_hasil_pajak_retribusi'], onChanged: (val) => _formData['bagi_hasil_pajak_retribusi'] = val),
        InputUangField(label: 'Lain-lain Pendapatan Sah', initialValue: _formData['lain_lain_pendapatan_sah'], onChanged: (val) => _formData['lain_lain_pendapatan_sah'] = val),
      ],
    );
  }

  // TAB 3: PEMERINTAHAN (Bidang 1)
  Widget _buildTabPemerintahan() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        InputUangField(label: 'Siltap Kepala Desa', initialValue: _formData['siltap_kepala_desa'], onChanged: (val) => _formData['siltap_kepala_desa'] = val),
        InputUangField(label: 'Siltap Perangkat Desa', initialValue: _formData['siltap_perangkat_desa'], onChanged: (val) => _formData['siltap_perangkat_desa'] = val),
        InputUangField(label: 'Jaminan Sosial Aparatur', initialValue: _formData['jaminan_sosial_aparatur'], onChanged: (val) => _formData['jaminan_sosial_aparatur'] = val),
        InputUangField(label: 'Operasional Pemerintahan', initialValue: _formData['operasional_pemerintahan_desa'], onChanged: (val) => _formData['operasional_pemerintahan_desa'] = val),
        InputUangField(label: 'Tunjangan BPD', initialValue: _formData['tunjangan_bpd'], onChanged: (val) => _formData['tunjangan_bpd'] = val),
        InputUangField(label: 'Operasional BPD', initialValue: _formData['operasional_bpd'], onChanged: (val) => _formData['operasional_bpd'] = val),
        InputUangField(label: 'Operasional Dana Desa', initialValue: _formData['operasional_dana_desa'], onChanged: (val) => _formData['operasional_dana_desa'] = val),
        InputUangField(label: 'Sarana & Prasarana Kantor', initialValue: _formData['sarana_prasarana_kantor'], onChanged: (val) => _formData['sarana_prasarana_kantor'] = val),
        InputUangField(label: 'Pengisian/Mutasi Perangkat', initialValue: _formData['pengisian_mutasi_perangkat'], onChanged: (val) => _formData['pengisian_mutasi_perangkat'] = val),
      ],
    );
  }

  // TAB 4: PEMBANGUNAN (Bidang 2)
  Widget _buildTabPembangunan() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        InputUangField(label: 'Penyuluhan Pendidikan', initialValue: _formData['penyuluhan_pendidikan'], onChanged: (val) => _formData['penyuluhan_pendidikan'] = val),
        InputUangField(label: 'Sarana Prasarana Pendidikan', initialValue: _formData['sarana_prasarana_pendidikan'], onChanged: (val) => _formData['sarana_prasarana_pendidikan'] = val),
        InputUangField(label: 'Sarana Prasarana Perpustakaan', initialValue: _formData['sarana_prasarana_perpustakaan'], onChanged: (val) => _formData['sarana_prasarana_perpustakaan'] = val),
        InputUangField(label: 'Pengelolaan Perpustakaan', initialValue: _formData['pengelolaan_perpustakaan'], onChanged: (val) => _formData['pengelolaan_perpustakaan'] = val),
        InputUangField(label: 'Penyelenggaraan Posyandu', initialValue: _formData['penyelenggaraan_posyandu'], onChanged: (val) => _formData['penyelenggaraan_posyandu'] = val),
        InputUangField(label: 'Penyuluhan Kesehatan', initialValue: _formData['penyuluhan_kesehatan'], onChanged: (val) => _formData['penyuluhan_kesehatan'] = val),
        InputUangField(label: 'Pemeliharaan Jalan Lingkungan', initialValue: _formData['pemeliharaan_jalan_lingkungan'], onChanged: (val) => _formData['pemeliharaan_jalan_lingkungan'] = val),
        InputUangField(label: 'Pembangunan Jalan Desa', initialValue: _formData['pembangunan_jalan_desa'], onChanged: (val) => _formData['pembangunan_jalan_desa'] = val),
        InputUangField(label: 'Jalan Usaha Tani', initialValue: _formData['pembangunan_jalan_usaha_tani'], onChanged: (val) => _formData['pembangunan_jalan_usaha_tani'] = val),
        InputUangField(label: 'Dokumen Tata Ruang', initialValue: _formData['dokumen_tata_ruang'], onChanged: (val) => _formData['dokumen_tata_ruang'] = val),
        InputUangField(label: 'Talud & Irigasi', initialValue: _formData['talud_irigasi'], onChanged: (val) => _formData['talud_irigasi'] = val),
        InputUangField(label: 'Sanitasi Pemukiman', initialValue: _formData['sanitasi_pemukiman'], onChanged: (val) => _formData['sanitasi_pemukiman'] = val),
        InputUangField(label: 'Fasilitas Pengelolaan Sampah', initialValue: _formData['fasilitas_pengelolaan_sampah'], onChanged: (val) => _formData['fasilitas_pengelolaan_sampah'] = val),
        InputUangField(label: 'Jaringan Internet Desa', initialValue: _formData['jaringan_internet_desa'], onChanged: (val) => _formData['jaringan_internet_desa'] = val),
      ],
    );
  }

  // TAB 5: LAINNYA & PEMBIAYAAN
  Widget _buildTabLainnya() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Belanja Lainnya (Bid. 3, 4, 5)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
        const Divider(),
        InputUangField(label: 'Pembinaan PKK', initialValue: _formData['pembinaan_pkk'], onChanged: (val) => _formData['pembinaan_pkk'] = val),
        InputUangField(label: 'Pelatihan Pertanian/Peternakan', initialValue: _formData['pelatihan_pertanian_peternakan'], onChanged: (val) => _formData['pelatihan_pertanian_peternakan'] = val),
        InputUangField(label: 'Pelatihan Aparatur Desa', initialValue: _formData['pelatihan_aparatur_desa'], onChanged: (val) => _formData['pelatihan_aparatur_desa'] = val),
        InputUangField(label: 'Penyusunan Rencana Program', initialValue: _formData['penyusunan_rencana_program'], onChanged: (val) => _formData['penyusunan_rencana_program'] = val),
        InputUangField(label: 'Insentif Kader Pembangunan', initialValue: _formData['insentif_kader_pembangunan'], onChanged: (val) => _formData['insentif_kader_pembangunan'] = val),
        InputUangField(label: 'Insentif Kader Kes/PAUD', initialValue: _formData['insentif_kader_kesehatan_paud'], onChanged: (val) => _formData['insentif_kader_kesehatan_paud'] = val),
        InputUangField(label: 'Penanggulangan Bencana', initialValue: _formData['penanggulangan_bencana'], onChanged: (val) => _formData['penanggulangan_bencana'] = val),
        InputUangField(label: 'Keadaan Mendesak/BLT', initialValue: _formData['keadaan_mendesak'], onChanged: (val) => _formData['keadaan_mendesak'] = val),
        const SizedBox(height: 24),

        const Text('Pembiayaan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
        const Divider(),
        InputUangField(label: 'SILPA Tahun Sebelumnya (Penerimaan)', initialValue: _formData['silpa_tahun_sebelumnya'], onChanged: (val) => _formData['silpa_tahun_sebelumnya'] = val),
        InputUangField(label: 'Penyertaan Modal Desa (Pengeluaran)', initialValue: _formData['penyertaan_modal_desa'], onChanged: (val) => _formData['penyertaan_modal_desa'] = val),
      ],
    );
  }
}