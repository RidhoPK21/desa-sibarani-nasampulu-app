// lib/data/models/kegiatan_model.dart

class KegiatanModel {
  final String id;
  final String nama;
  final String tanggal;
  final String deskripsi;
  final String? lokasi;
  final String? penyelenggara;
  final String? gambar;
  final String? createdAt;
  final String? updatedAt;

  const KegiatanModel({
    required this.id,
    required this.nama,
    required this.tanggal,
    required this.deskripsi,
    this.lokasi,
    this.penyelenggara,
    this.gambar,
    this.createdAt,
    this.updatedAt,
  });

  factory KegiatanModel.fromJson(Map<String, dynamic> json) => KegiatanModel(
    id: '${json['id'] ?? ''}',
    nama: json['nama'] ?? '',
    tanggal: json['tanggal'] ?? '',
    deskripsi: json['deskripsi'] ?? '',
    lokasi: json['lokasi'],
    penyelenggara: json['penyelenggara'],
    gambar: json['gambar'],
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'tanggal': tanggal,
    'deskripsi': deskripsi,
    'lokasi': lokasi,
    'penyelenggara': penyelenggara,
    'gambar': gambar,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}