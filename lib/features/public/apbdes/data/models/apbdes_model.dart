import 'package:intl/intl.dart';

class PelaksanaanModel {
  final String pendapatan;
  final String belanja;
  final String pembiayaan;

  PelaksanaanModel({
    required this.pendapatan,
    required this.belanja,
    required this.pembiayaan,
  });
}

class ItemKeuanganModel {
  final String nama;
  final String jumlah;

  ItemKeuanganModel({
    required this.nama,
    required this.jumlah,
  });
}

class ApbdesModel {
  final String id;
  final String tahun;
  final int versi;
  final String imageUrl; // Akan diisi default
  final String tanggal;
  final String jam;
  final String lokasi;
  final PelaksanaanModel pelaksanaan;
  final List<ItemKeuanganModel> pendapatan;
  final List<ItemKeuanganModel> belanja;
  final List<ItemKeuanganModel> pembiayaan;
  final String? catatanPerubahan;

  ApbdesModel({
    required this.id,
    required this.tahun,
    required this.versi,
    required this.imageUrl,
    required this.tanggal,
    required this.jam,
    required this.lokasi,
    required this.pelaksanaan,
    required this.pendapatan,
    required this.belanja,
    required this.pembiayaan,
    this.catatanPerubahan,
  });

  factory ApbdesModel.fromJson(Map<String, dynamic> json) {
    // 1. Fungsi Bantuan untuk Format Rupiah
    String formatRp(dynamic value) {
      num val = value != null ? num.tryParse(value.toString()) ?? 0 : 0;
      return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(val);
    }

    // 2. Fungsi Ekstrak Tanggal dan Jam dari created_at
    String tgl = '-';
    String wkt = '-';
    if (json['created_at'] != null) {
      try {
        final dt = DateTime.parse(json['created_at']).toLocal();
        tgl = DateFormat('dd MMM yyyy').format(dt);
        wkt = DateFormat('HH:mm').format(dt);
      } catch (_) {}
    }

    // 3. Menghitung Total Belanja per Bidang (Sesuai kolom Laravel)
    num sum(List<String> keys) {
      num total = 0;
      for (var key in keys) {
        total += (json[key] != null ? num.tryParse(json[key].toString()) ?? 0 : 0);
      }
      return total;
    }

    num bidang1 = sum([
      'siltap_kepala_desa', 'siltap_perangkat_desa', 'jaminan_sosial_aparatur',
      'operasional_pemerintahan_desa', 'tunjangan_bpd', 'operasional_bpd',
      'operasional_dana_desa', 'sarana_prasarana_kantor', 'pengisian_mutasi_perangkat'
    ]);

    num bidang2 = sum([
      'penyuluhan_pendidikan', 'sarana_prasarana_pendidikan', 'sarana_prasarana_perpustakaan',
      'pengelolaan_perpustakaan', 'penyelenggaraan_posyandu', 'penyuluhan_kesehatan',
      'pemeliharaan_jalan_lingkungan', 'pembangunan_jalan_desa', 'pembangunan_jalan_usaha_tani',
      'dokumen_tata_ruang', 'talud_irigasi', 'sanitasi_pemukiman', 'fasilitas_pengelolaan_sampah',
      'jaringan_internet_desa'
    ]);

    num bidang3 = sum(['pembinaan_pkk']);

    num bidang4 = sum([
      'pelatihan_pertanian_peternakan', 'pelatihan_aparatur_desa', 'penyusunan_rencana_program',
      'insentif_kader_pembangunan', 'insentif_kader_kesehatan_paud'
    ]);

    num bidang5 = sum(['penanggulangan_bencana', 'keadaan_mendesak']);

    // Total Pembiayaan
    num pembiayaanTotal = sum(['silpa_tahun_sebelumnya', 'penyertaan_modal_desa']);

    // 4. Membangun Data Model
    return ApbdesModel(
      id: json['id']?.toString() ?? '',
      tahun: json['tahun'] != null ? 'APBDes ${json['tahun']}' : 'APBDes',
      versi: json['versi'] != null ? int.tryParse(json['versi'].toString()) ?? 1 : 1,
      imageUrl: '', // Kosongkan agar masuk ke fallback warna hijau di UI
      tanggal: tgl,
      jam: wkt,
      lokasi: json['nama_desa'] ?? 'Sibarani Nasampulu',
      catatanPerubahan: json['alasan_perubahan'],

      // Mengambil Appends dari Laravel Model (Atau hitung fallback)
      pelaksanaan: PelaksanaanModel(
        pendapatan: formatRp(json['total_pendapatan']),
        belanja: formatRp(json['total_belanja']),
        pembiayaan: formatRp(pembiayaanTotal),
      ),

      // Mapping ke List untuk Tabel UI
      pendapatan: [
        ItemKeuanganModel(nama: 'Pendapatan Asli Desa', jumlah: formatRp(json['pendapatan_asli_desa'])),
        ItemKeuanganModel(nama: 'Dana Desa', jumlah: formatRp(json['dana_desa'])),
        ItemKeuanganModel(nama: 'Alokasi Dana Desa', jumlah: formatRp(json['alokasi_dana_desa'])),
        ItemKeuanganModel(nama: 'Bagi Hasil Pajak & Retribusi', jumlah: formatRp(json['bagi_hasil_pajak_retribusi'])),
        ItemKeuanganModel(nama: 'Lain-lain Pendapatan Sah', jumlah: formatRp(json['lain_lain_pendapatan_sah'])),
      ],
      belanja: [
        ItemKeuanganModel(nama: 'Penyelenggaraan Pemerintahan Desa', jumlah: formatRp(bidang1)),
        ItemKeuanganModel(nama: 'Pelaksanaan Pembangunan Desa', jumlah: formatRp(bidang2)),
        ItemKeuanganModel(nama: 'Pembinaan Kemasyarakatan', jumlah: formatRp(bidang3)),
        ItemKeuanganModel(nama: 'Pemberdayaan Masyarakat', jumlah: formatRp(bidang4)),
        ItemKeuanganModel(nama: 'Penanggulangan Bencana & Mendesak', jumlah: formatRp(bidang5)),
      ],
      pembiayaan: [
        ItemKeuanganModel(nama: 'SILPA Tahun Sebelumnya', jumlah: formatRp(json['silpa_tahun_sebelumnya'])),
        ItemKeuanganModel(nama: 'Penyertaan Modal Desa', jumlah: formatRp(json['penyertaan_modal_desa'])),
      ],
    );
  }
}