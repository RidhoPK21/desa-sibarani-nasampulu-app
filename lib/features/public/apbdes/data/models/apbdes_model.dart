// lib/features/public/apbdes/data/models/apbdes_model.dart

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
  final String imageUrl;
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
}