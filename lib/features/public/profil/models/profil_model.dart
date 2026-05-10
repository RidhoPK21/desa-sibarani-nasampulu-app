class VisiMisiModel {
  final String visi;
  final String misi;

  VisiMisiModel({required this.visi, required this.misi});

  factory VisiMisiModel.fromJson(Map<String, dynamic> json) {
    return VisiMisiModel(
      visi: json['visi'] ?? 'Data visi belum tersedia.',
      misi: json['misi'] ?? 'Data misi belum tersedia.',
    );
  }
}

class PerangkatDesaModel {
  final String id;
  final String nama;
  final String jabatan;
  final String? fotoUrl;

  PerangkatDesaModel({
    required this.id,
    required this.nama,
    required this.jabatan,
    this.fotoUrl,
  });

  factory PerangkatDesaModel.fromJson(Map<String, dynamic> json) {
    return PerangkatDesaModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama'] ?? 'Tanpa Nama',
      jabatan: json['jabatan'] ?? '-',
      fotoUrl: json['foto_url'] ?? json['foto'],
    );
  }
}

// Wrapper untuk menampung kedua data sekaligus
class ProfilData {
  final VisiMisiModel visiMisi;
  final List<PerangkatDesaModel> perangkatList;

  ProfilData({required this.visiMisi, required this.perangkatList});
}