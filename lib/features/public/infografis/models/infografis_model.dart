import 'package:flutter/material.dart';

// --- Model untuk Format Chart UI ---
class ChartData {
  final String name;
  final double value;
  final Color color;
  ChartData(this.name, this.value, this.color);
}

class StatData {
  final String id, judul, subjudul, deskripsi, satuan;
  final List<ChartData> data;
  StatData({
    required this.id, required this.judul, required this.subjudul,
    required this.deskripsi, required this.satuan, required this.data,
  });
}

// --- Model Data dari Database Laravel ---
class DusunStatModel {
  final String id;
  final String namaDusun;

  // Penduduk
  final int lakiLaki;
  final int perempuan;

  // Usia
  final int balita, anak, remaja, dewasa, lansia;

  // Pendidikan
  final int sd, smp, sma, sarjana, pendidikanLainnya;

  // Pekerjaan
  final int petani, nelayan, asn, wiraswasta, pekerjaanLainnya;

  // Agama
  final int kristen, muslim, katolik, agamaLainnya;

  // Perkawinan
  final int kawin, belumKawin, cerai;

  DusunStatModel({
    required this.id, required this.namaDusun,
    required this.lakiLaki, required this.perempuan,
    required this.balita, required this.anak, required this.remaja, required this.dewasa, required this.lansia,
    required this.sd, required this.smp, required this.sma, required this.sarjana, required this.pendidikanLainnya,
    required this.petani, required this.nelayan, required this.asn, required this.wiraswasta, required this.pekerjaanLainnya,
    required this.kristen, required this.muslim, required this.katolik, required this.agamaLainnya,
    required this.kawin, required this.belumKawin, required this.cerai,
  });

  factory DusunStatModel.fromJson(Map<String, dynamic> json) {
    int parse(dynamic value) => value != null ? int.tryParse(value.toString()) ?? 0 : 0;

    // --- FUNGSI AGREGASI ARRAY ---
    int sumUsia(String keyword) {
      if (json['usias'] is! List) return 0;
      return (json['usias'] as List).where((u) => (u['kelompok_usia'] ?? '').toString().contains(keyword)).fold(0, (sum, u) => sum + parse(u['jumlah_jiwa']));
    }

    int sumPendidikan(String keyword) {
      if (json['pendidikans'] is! List) return 0;
      return (json['pendidikans'] as List).where((p) => (p['tingkat_pendidikan'] ?? '').toString().contains(keyword)).fold(0, (sum, p) => sum + parse(p['jumlah_jiwa']));
    }

    // --- HITUNG MANUAL KATEGORI LAINNYA ---
    int hitungLainnyaPendidikan() {
      if (json['pendidikans'] is! List) return 0;
      return (json['pendidikans'] as List).where((p) {
        String t = (p['tingkat_pendidikan'] ?? '').toString();
        return !t.contains('SD') && !t.contains('SMP') && !t.contains('SMA') && !t.contains('Sarjana');
      }).fold(0, (sum, p) => sum + parse(p['jumlah_jiwa']));
    }

    int hitungKerja(List<String> keywords) {
      if (json['pekerjaans'] is! List) return 0;
      return (json['pekerjaans'] as List).where((p) {
        String t = (p['jenis_pekerjaan'] ?? '').toString();
        return keywords.any((kw) => t.contains(kw));
      }).fold(0, (sum, p) => sum + parse(p['jumlah_jiwa']));
    }

    int hitungLainnyaKerja() {
      if (json['pekerjaans'] is! List) return 0;
      return (json['pekerjaans'] as List).where((p) {
        String t = (p['jenis_pekerjaan'] ?? '').toString();
        return !t.contains('Petani') && !t.contains('Nelayan') && !t.contains('PNS') && !t.contains('TNI') && !t.contains('Wiraswasta');
      }).fold(0, (sum, p) => sum + parse(p['jumlah_jiwa']));
    }

    int hitungAgama(String keyword) {
      if (json['agamas'] is! List) return 0;
      return (json['agamas'] as List).where((a) => (a['agama'] ?? '').toString() == keyword).fold(0, (sum, a) => sum + parse(a['jumlah_jiwa']));
    }

    int hitungLainnyaAgama() {
      if (json['agamas'] is! List) return 0;
      return (json['agamas'] as List).where((a) {
        String t = (a['agama'] ?? '').toString();
        return t != 'Kristen' && t != 'Islam' && t != 'Katolik';
      }).fold(0, (sum, a) => sum + parse(a['jumlah_jiwa']));
    }

    int hitungKawin(String keyword) {
      if (json['perkawinans'] is! List) return 0;
      return (json['perkawinans'] as List).where((w) => (w['status_perkawinan'] ?? '').toString() == keyword).fold(0, (sum, w) => sum + parse(w['jumlah_jiwa']));
    }

    return DusunStatModel(
      id: json['id']?.toString() ?? '',
      namaDusun: json['nama_dusun'] ?? json['nama'] ?? 'Dusun',
      lakiLaki: parse(json['penduduk_laki']),
      perempuan: parse(json['penduduk_perempuan']),

      balita: sumUsia('Balita'),
      anak: sumUsia('Anak'),
      remaja: sumUsia('Pemuda'), // Mengikuti React: Pemuda -> Remaja
      dewasa: sumUsia('Dewasa'),
      lansia: sumUsia('Lansia'),

      sd: sumPendidikan('SD'),
      smp: sumPendidikan('SMP'),
      sma: sumPendidikan('SMA'),
      sarjana: sumPendidikan('Sarjana'),
      pendidikanLainnya: hitungLainnyaPendidikan(),

      petani: hitungKerja(['Petani']),
      nelayan: hitungKerja(['Nelayan']),
      asn: hitungKerja(['PNS', 'TNI']),
      wiraswasta: hitungKerja(['Wiraswasta']),
      pekerjaanLainnya: hitungLainnyaKerja(),

      kristen: hitungAgama('Kristen'),
      muslim: hitungAgama('Islam'),
      katolik: hitungAgama('Katolik'),
      agamaLainnya: hitungLainnyaAgama(),

      kawin: hitungKawin('Kawin'),
      belumKawin: hitungKawin('Belum Kawin'),
      cerai: hitungKawin('Cerai') + hitungKawin('Cerai Mati') + hitungKawin('Cerai Hidup'),
    );
  }
}