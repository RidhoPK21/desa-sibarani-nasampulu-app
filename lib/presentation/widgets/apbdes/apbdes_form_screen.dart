import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../data/models/apbdes_model.dart';
import '../../../features/auth/providers/apbdes_provider.dart';

class ApbdesFormScreen extends StatefulWidget {
  final ApbdesModel? existing;
  const ApbdesFormScreen({super.key, this.existing});

  @override
  State<ApbdesFormScreen> createState() => _ApbdesFormScreenState();
}

class _ApbdesFormScreenState extends State<ApbdesFormScreen> {
  late Map<String, double> _values;
  final _namaDesa = TextEditingController();
  final _tahun = TextEditingController();
  final _alasanCtrl = TextEditingController();
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _namaDesa.text = e?.namaDesa ?? 'Desa Sibarani Nasampulu';
    _tahun.text = (e?.tahun ?? DateTime.now().year).toString();
    _values = {
      'pendapatan_asli_desa': e?.pendapatanAsliDesa ?? 0,
      'dana_desa': e?.danaDesa ?? 0,
      'alokasi_dana_desa': e?.alokasiDanaDesa ?? 0,
      'bagi_hasil_pajak_retribusi': e?.bagiHasilPajakRetribusi ?? 0,
      'lain_lain_pendapatan_sah': e?.lainLainPendapatanSah ?? 0,
      'siltap_kepala_desa': e?.siltapKepalaDesa ?? 0,
      'siltap_perangkat_desa': e?.siltapPerangkatDesa ?? 0,
      'jaminan_sosial_aparatur': e?.jaminanSosialAparatur ?? 0,
      'operasional_pemerintahan_desa': e?.operasionalPemerintahanDesa ?? 0,
      'tunjangan_bpd': e?.tunjanganBpd ?? 0,
      'operasional_bpd': e?.operasionalBpd ?? 0,
      'operasional_dana_desa': e?.operasionalDanaDesa ?? 0,
      'sarana_prasarana_kantor': e?.saranaPrasaranaKantor ?? 0,
      'pengisian_mutasi_perangkat': e?.pengisianMutasiPerangkat ?? 0,
      'penyuluhan_pendidikan': e?.penyuluhanPendidikan ?? 0,
      'sarana_prasarana_pendidikan': e?.saranaPrasaranaPendidikan ?? 0,
      'sarana_prasarana_perpustakaan': e?.saranaPrasaranaPerpustakaan ?? 0,
      'pengelolaan_perpustakaan': e?.pengelolaanPerpustakaan ?? 0,
      'penyelenggaraan_posyandu': e?.penyelenggaraanPosyandu ?? 0,
      'penyuluhan_kesehatan': e?.penyuluhanKesehatan ?? 0,
      'pemeliharaan_jalan_lingkungan': e?.pemeliharaanJalanLingkungan ?? 0,
      'pembangunan_jalan_desa': e?.pembangunanJalanDesa ?? 0,
      'pembangunan_jalan_usaha_tani': e?.pembangunanJalanUsahaTani ?? 0,
      'dokumen_tata_ruang': e?.dokumenTataRuang ?? 0,
      'talud_irigasi': e?.taludIrigasi ?? 0,
      'sanitasi_pemukiman': e?.sanitasiPemukiman ?? 0,
      'fasilitas_pengelolaan_sampah': e?.fasilitasPengelolaanSampah ?? 0,
      'jaringan_internet_desa': e?.jaringanInternetDesa ?? 0,
      'pembinaan_pkk': e?.pembinaanPkk ?? 0,
      'pelatihan_pertanian_peternakan': e?.pelatihanPertanianPeternakan ?? 0,
      'pelatihan_aparatur_desa': e?.pelatihanAparaturDesa ?? 0,
      'penyusunan_rencana_program': e?.penyusunanRencanaProgram ?? 0,
      'insentif_kader_pembangunan': e?.insentifKaderPembangunan ?? 0,
      'insentif_kader_kesehatan_paud': e?.insentifKaderKesehatanPaud ?? 0,
      'penanggulangan_bencana': e?.penanggulanganBencana ?? 0,
      'keadaan_mendesak': e?.keadaanMendesak ?? 0,
      'silpa_tahun_sebelumnya': e?.silpaTahunSebelumnya ?? 0,
      'penyertaan_modal_desa': e?.penyertaanModalDesa ?? 0,
    };
  }

  @override
  void dispose() {
    _namaDesa.dispose();
    _tahun.dispose();
    _alasanCtrl.dispose();
    super.dispose();
  }

  void _setVal(String key, double val) => setState(() => _values[key] = val);

  Future<void> _save() async {
    if (_isEdit && _alasanCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wajib mengisi ALASAN PERUBAHAN untuk versi baru!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => _saving = true);

    final v = _values;
    final model = ApbdesModel(
      namaDesa: _namaDesa.text,
      tahun: int.tryParse(_tahun.text) ?? DateTime.now().year,
      alasanPerubahan: _isEdit ? _alasanCtrl.text : null,
      pendapatanAsliDesa: v['pendapatan_asli_desa']!,
      danaDesa: v['dana_desa']!,
      alokasiDanaDesa: v['alokasi_dana_desa']!,
      bagiHasilPajakRetribusi: v['bagi_hasil_pajak_retribusi']!,
      lainLainPendapatanSah: v['lain_lain_pendapatan_sah']!,
      siltapKepalaDesa: v['siltap_kepala_desa']!,
      siltapPerangkatDesa: v['siltap_perangkat_desa']!,
      jaminanSosialAparatur: v['jaminan_sosial_aparatur']!,
      operasionalPemerintahanDesa: v['operasional_pemerintahan_desa']!,
      tunjanganBpd: v['tunjangan_bpd']!,
      operasionalBpd: v['operasional_bpd']!,
      operasionalDanaDesa: v['operasional_dana_desa']!,
      saranaPrasaranaKantor: v['sarana_prasarana_kantor']!,
      pengisianMutasiPerangkat: v['pengisian_mutasi_perangkat']!,
      penyuluhanPendidikan: v['penyuluhan_pendidikan']!,
      saranaPrasaranaPendidikan: v['sarana_prasarana_pendidikan']!,
      saranaPrasaranaPerpustakaan: v['sarana_prasarana_perpustakaan']!,
      pengelolaanPerpustakaan: v['pengelolaan_perpustakaan']!,
      penyelenggaraanPosyandu: v['penyelenggaraan_posyandu']!,
      penyuluhanKesehatan: v['penyuluhan_kesehatan']!,
      pemeliharaanJalanLingkungan: v['pemeliharaan_jalan_lingkungan']!,
      pembangunanJalanDesa: v['pembangunan_jalan_desa']!,
      pembangunanJalanUsahaTani: v['pembangunan_jalan_usaha_tani']!,
      dokumenTataRuang: v['dokumen_tata_ruang']!,
      taludIrigasi: v['talud_irigasi']!,
      sanitasiPemukiman: v['sanitasi_pemukiman']!,
      fasilitasPengelolaanSampah: v['fasilitas_pengelolaan_sampah']!,
      jaringanInternetDesa: v['jaringan_internet_desa']!,
      pembinaanPkk: v['pembinaan_pkk']!,
      pelatihanPertanianPeternakan: v['pelatihan_pertanian_peternakan']!,
      pelatihanAparaturDesa: v['pelatihan_aparatur_desa']!,
      penyusunanRencanaProgram: v['penyusunan_rencana_program']!,
      insentifKaderPembangunan: v['insentif_kader_pembangunan']!,
      insentifKaderKesehatanPaud: v['insentif_kader_kesehatan_paud']!,
      penanggulanganBencana: v['penanggulangan_bencana']!,
      keadaanMendesak: v['keadaan_mendesak']!,
      silpaTahunSebelumnya: v['silpa_tahun_sebelumnya']!,
      penyertaanModalDesa: v['penyertaan_modal_desa']!,
    );

    // Memanggil fungsi save yang baru saja kita tambahkan di Provider
    final ok = await context
        .read<ApbdesProvider>()
        .save(model, existing: widget.existing);

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // Menyesuaikan pemanggilan properti errorMessage
          content: Text(context.read<ApbdesProvider>().errorMessage ??
              'Terjadi kesalahan saat menyimpan!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Perbaikan warna
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.account_balance_wallet_outlined,
                color: Colors.green), // Perbaikan warna
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _isEdit
                    ? 'Ubah APBDes ${widget.existing!.tahun} → V.${(widget.existing!.versi ?? 0) + 1}'
                    : 'Input APBDes Awal (Versi 1)',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (!_saving)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal',
                  style: TextStyle(color: Colors.grey)),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_circle_outline, size: 18),
              label: Text(_isEdit ? 'Simpan Versi Baru' : 'Simpan APBDes'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green), // Perbaikan warna
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Alasan Perubahan (edit only) ─────────────────────
          if (_isEdit) ...[
            _SectionCard(
              topColor: Colors.orange,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.orange),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Kenapa Anda Merubah APBDes ini?',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sistem menggunakan fitur Versioning. Data lama disimpan sebagai arsip. Tuliskan alasan perubahan (Wajib).',
                    style: TextStyle(fontSize: 11, color: Colors.orange),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _alasanCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Penambahan dana desa tahap II...',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── A. Informasi Dasar ────────────────────────────────
          _SectionCard(
            topColor: Colors.grey.shade800,
            title: 'A. Informasi Dasar',
            titleColor: Colors.grey.shade800,
            child: Column(
              children: [
                _labeledField(
                  label: 'Nama Desa',
                  child: TextField(
                    controller: _namaDesa,
                    decoration:
                    const InputDecoration(hintText: 'Nama Desa'),
                  ),
                ),
                const SizedBox(height: 10),
                _labeledField(
                  label: 'Tahun Anggaran',
                  child: TextField(
                    controller: _tahun,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration:
                    const InputDecoration(hintText: '2024'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── B. Pendapatan ─────────────────────────────────────
          _SectionCard(
            topColor: Colors.green.shade400, // Perbaikan warna
            title: 'B. Pendapatan Desa',
            titleColor: Colors.green.shade800, // Perbaikan warna
            child: Column(children: [
              _InputUang(
                  label: 'Pendapatan Asli Desa (PADes)',
                  value: _values['pendapatan_asli_desa']!,
                  onChanged: (v) => _setVal('pendapatan_asli_desa', v)),
              _InputUang(
                  label: 'Dana Desa (DD)',
                  value: _values['dana_desa']!,
                  onChanged: (v) => _setVal('dana_desa', v)),
              _InputUang(
                  label: 'Alokasi Dana Desa (ADD)',
                  value: _values['alokasi_dana_desa']!,
                  onChanged: (v) => _setVal('alokasi_dana_desa', v)),
              _InputUang(
                  label: 'Bagi Hasil Pajak & Retribusi',
                  value: _values['bagi_hasil_pajak_retribusi']!,
                  onChanged: (v) => _setVal('bagi_hasil_pajak_retribusi', v)),
              _InputUang(
                  label: 'Lain-lain Pendapatan Sah',
                  value: _values['lain_lain_pendapatan_sah']!,
                  onChanged: (v) => _setVal('lain_lain_pendapatan_sah', v)),
            ]),
          ),
          const SizedBox(height: 12),

          // ── C. Belanja Pemerintahan ───────────────────────────
          _SectionCard(
            topColor: Colors.orange, // Perbaikan warna
            title: 'C. Belanja - Pemerintahan (Bid. 1)',
            titleColor: Colors.orange.shade800,
            child: Column(children: [
              _InputUang(
                  label: 'Penghasilan Tetap Kades',
                  value: _values['siltap_kepala_desa']!,
                  onChanged: (v) => _setVal('siltap_kepala_desa', v)),
              _InputUang(
                  label: 'Penghasilan Tetap Perangkat',
                  value: _values['siltap_perangkat_desa']!,
                  onChanged: (v) => _setVal('siltap_perangkat_desa', v)),
              _InputUang(
                  label: 'Jaminan Sosial Aparatur',
                  value: _values['jaminan_sosial_aparatur']!,
                  onChanged: (v) => _setVal('jaminan_sosial_aparatur', v)),
              _InputUang(
                  label: 'Operasional Pemerintahan Desa',
                  value: _values['operasional_pemerintahan_desa']!,
                  onChanged: (v) => _setVal('operasional_pemerintahan_desa', v)),
              _InputUang(
                  label: 'Tunjangan BPD',
                  value: _values['tunjangan_bpd']!,
                  onChanged: (v) => _setVal('tunjangan_bpd', v)),
              _InputUang(
                  label: 'Operasional BPD',
                  value: _values['operasional_bpd']!,
                  onChanged: (v) => _setVal('operasional_bpd', v)),
              _InputUang(
                  label: 'Operasional Dana Desa',
                  value: _values['operasional_dana_desa']!,
                  onChanged: (v) => _setVal('operasional_dana_desa', v)),
              _InputUang(
                  label: 'Sarana & Prasarana Kantor',
                  value: _values['sarana_prasarana_kantor']!,
                  onChanged: (v) => _setVal('sarana_prasarana_kantor', v)),
              _InputUang(
                  label: 'Pengisian/Mutasi Perangkat',
                  value: _values['pengisian_mutasi_perangkat']!,
                  onChanged: (v) => _setVal('pengisian_mutasi_perangkat', v)),
            ]),
          ),
          const SizedBox(height: 12),

          // ── D. Belanja Pembangunan ────────────────────────────
          _SectionCard(
            topColor: Colors.orange, // Perbaikan warna
            title: 'D. Belanja - Pembangunan (Bid. 2)',
            titleColor: Colors.orange.shade800,
            child: Column(children: [
              _InputUang(
                  label: 'Penyuluhan Pendidikan',
                  value: _values['penyuluhan_pendidikan']!,
                  onChanged: (v) => _setVal('penyuluhan_pendidikan', v)),
              _InputUang(
                  label: 'Sarana Prasarana Pendidikan',
                  value: _values['sarana_prasarana_pendidikan']!,
                  onChanged: (v) => _setVal('sarana_prasarana_pendidikan', v)),
              _InputUang(
                  label: 'Sarana Prasarana Perpustakaan',
                  value: _values['sarana_prasarana_perpustakaan']!,
                  onChanged: (v) =>
                      _setVal('sarana_prasarana_perpustakaan', v)),
              _InputUang(
                  label: 'Pengelolaan Perpustakaan',
                  value: _values['pengelolaan_perpustakaan']!,
                  onChanged: (v) => _setVal('pengelolaan_perpustakaan', v)),
              _InputUang(
                  label: 'Penyelenggaraan Posyandu',
                  value: _values['penyelenggaraan_posyandu']!,
                  onChanged: (v) => _setVal('penyelenggaraan_posyandu', v)),
              _InputUang(
                  label: 'Penyuluhan Kesehatan',
                  value: _values['penyuluhan_kesehatan']!,
                  onChanged: (v) => _setVal('penyuluhan_kesehatan', v)),
              _InputUang(
                  label: 'Pemeliharaan Jalan Lingkungan',
                  value: _values['pemeliharaan_jalan_lingkungan']!,
                  onChanged: (v) =>
                      _setVal('pemeliharaan_jalan_lingkungan', v)),
              _InputUang(
                  label: 'Pembangunan Jalan Desa',
                  value: _values['pembangunan_jalan_desa']!,
                  onChanged: (v) => _setVal('pembangunan_jalan_desa', v)),
              _InputUang(
                  label: 'Jalan Usaha Tani',
                  value: _values['pembangunan_jalan_usaha_tani']!,
                  onChanged: (v) =>
                      _setVal('pembangunan_jalan_usaha_tani', v)),
              _InputUang(
                  label: 'Dokumen Tata Ruang',
                  value: _values['dokumen_tata_ruang']!,
                  onChanged: (v) => _setVal('dokumen_tata_ruang', v)),
              _InputUang(
                  label: 'Talud & Irigasi',
                  value: _values['talud_irigasi']!,
                  onChanged: (v) => _setVal('talud_irigasi', v)),
              _InputUang(
                  label: 'Sanitasi Pemukiman',
                  value: _values['sanitasi_pemukiman']!,
                  onChanged: (v) => _setVal('sanitasi_pemukiman', v)),
              _InputUang(
                  label: 'Fasilitas Pengelolaan Sampah',
                  value: _values['fasilitas_pengelolaan_sampah']!,
                  onChanged: (v) =>
                      _setVal('fasilitas_pengelolaan_sampah', v)),
              _InputUang(
                  label: 'Jaringan Internet Desa',
                  value: _values['jaringan_internet_desa']!,
                  onChanged: (v) => _setVal('jaringan_internet_desa', v)),
            ]),
          ),
          const SizedBox(height: 12),

          // ── E. Belanja Lainnya ────────────────────────────────
          _SectionCard(
            topColor: Colors.orange, // Perbaikan warna
            title: 'E. Belanja - Lainnya (Bid. 3, 4, 5)',
            titleColor: Colors.orange.shade800,
            child: Column(children: [
              _InputUang(
                  label: 'Pembinaan PKK (Bid 3)',
                  value: _values['pembinaan_pkk']!,
                  onChanged: (v) => _setVal('pembinaan_pkk', v)),
              _InputUang(
                  label: 'Pelatihan Pertanian/Peternakan',
                  value: _values['pelatihan_pertanian_peternakan']!,
                  onChanged: (v) =>
                      _setVal('pelatihan_pertanian_peternakan', v)),
              _InputUang(
                  label: 'Pelatihan Aparatur Desa',
                  value: _values['pelatihan_aparatur_desa']!,
                  onChanged: (v) => _setVal('pelatihan_aparatur_desa', v)),
              _InputUang(
                  label: 'Penyusunan Rencana Program',
                  value: _values['penyusunan_rencana_program']!,
                  onChanged: (v) => _setVal('penyusunan_rencana_program', v)),
              _InputUang(
                  label: 'Insentif Kader Pembangunan',
                  value: _values['insentif_kader_pembangunan']!,
                  onChanged: (v) => _setVal('insentif_kader_pembangunan', v)),
              _InputUang(
                  label: 'Insentif Kader Kes/PAUD',
                  value: _values['insentif_kader_kesehatan_paud']!,
                  onChanged: (v) =>
                      _setVal('insentif_kader_kesehatan_paud', v)),
              _InputUang(
                  label: 'Penanggulangan Bencana',
                  value: _values['penanggulangan_bencana']!,
                  onChanged: (v) => _setVal('penanggulangan_bencana', v)),
              _InputUang(
                  label: 'Keadaan Mendesak / BLT',
                  value: _values['keadaan_mendesak']!,
                  onChanged: (v) => _setVal('keadaan_mendesak', v)),
            ]),
          ),
          const SizedBox(height: 12),

          // ── F. Pembiayaan ─────────────────────────────────────
          _SectionCard(
            topColor: Colors.blue, // Perbaikan warna
            title: 'F. Pembiayaan Desa',
            titleColor: Colors.blue.shade800,
            child: Column(children: [
              _InputUang(
                  label: 'SILPA Tahun Sebelumnya (Penerimaan)',
                  value: _values['silpa_tahun_sebelumnya']!,
                  onChanged: (v) => _setVal('silpa_tahun_sebelumnya', v)),
              _InputUang(
                  label: 'Penyertaan Modal Desa (Pengeluaran)',
                  value: _values['penyertaan_modal_desa']!,
                  onChanged: (v) => _setVal('penyertaan_modal_desa', v)),
            ]),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _labeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey)), // Perbaikan warna
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Reusable: Section Card
// ─────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final Color topColor;
  final String? title;
  final Color? titleColor;
  final Widget child;

  const _SectionCard({
    required this.topColor,
    this.title,
    this.titleColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(top: BorderSide(color: topColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // Perbaikan peringatan withOpacity
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: titleColor ?? Colors.black87,
                  fontSize: 14),
            ),
            const Divider(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Reusable: Currency Input (mirrors JSX InputUang)
// ─────────────────────────────────────────────────────────────
class _InputUang extends StatefulWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _InputUang({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_InputUang> createState() => _InputUangState();
}

class _InputUangState extends State<_InputUang> {
  late final TextEditingController _ctrl;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.value == 0 ? '' : widget.value.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey, // Perbaikan warna
            ),
          ),
          const SizedBox(height: 4),
          Focus(
            onFocusChange: (f) => setState(() => _focused = f),
            child: TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (v) {
                final num = double.tryParse(v) ?? 0;
                widget.onChanged(num);
              },
              decoration: InputDecoration(
                hintText: '0',
                prefixText: 'Rp ',
                prefixStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _focused ? Colors.green : Colors.grey.shade500, // Perbaikan warna
                  fontSize: 13,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}