// lib/data/models/idm_model.dart

class IdmModel {
  final String id;
  final int tahun;
  final double skorIdm;
  final String statusIdm;
  final double skorIks; // Indeks Ketahanan Sosial
  final double skorIke; // Indeks Ketahanan Ekonomi
  final double skorIkl; // Indeks Ketahanan Lingkungan
  final String? catatan;
  final String? createdAt;

  const IdmModel({
    required this.id,
    required this.tahun,
    required this.skorIdm,
    required this.statusIdm,
    required this.skorIks,
    required this.skorIke,
    required this.skorIkl,
    this.catatan,
    this.createdAt,
  });

  factory IdmModel.fromJson(Map<String, dynamic> json) => IdmModel(
    id: '${json['id'] ?? ''}',
    tahun: _asInt(json['tahun_idm'] ?? json['tahun'], DateTime.now().year),
    skorIdm: _asDouble(
      json['score_idm'] ?? json['skor_idm'] ?? json['nilai_idm'],
    ),
    statusIdm: json['status_idm'] ?? json['status'] ?? 'Berkembang',
    skorIks: _asDouble(
      json['sosial_idm'] ?? json['skor_iks'] ?? json['nilai_iks'],
    ),
    skorIke: _asDouble(
      json['ekonomi_idm'] ?? json['skor_ike'] ?? json['nilai_ike'],
    ),
    skorIkl: _asDouble(
      json['lingkungan_idm'] ?? json['skor_ikl'] ?? json['nilai_ikl'],
    ),
    catatan: json['catatan'],
    createdAt: json['created_at'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'tahun_idm': tahun,
    'score_idm': skorIdm,
    'status_idm': statusIdm,
    'sosial_idm': skorIks,
    'ekonomi_idm': skorIke,
    'lingkungan_idm': skorIkl,
    'catatan': catatan,
    'created_at': createdAt,
  };
}

int _asInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

double _asDouble(dynamic value, [double fallback = 0.0]) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? fallback;
}

class PendudukStatsModel {
  final int totalPenduduk;
  final int lakiLaki;
  final int perempuan;
  final int kepalaKeluarga;
  final int pendudukMiskin;
  final double rasioJenisKelamin;

  const PendudukStatsModel({
    required this.totalPenduduk,
    required this.lakiLaki,
    required this.perempuan,
    required this.kepalaKeluarga,
    required this.pendudukMiskin,
    required this.rasioJenisKelamin,
  });

  factory PendudukStatsModel.fromJson(Map<String, dynamic> json) =>
      PendudukStatsModel(
        totalPenduduk: _asInt(json['total_penduduk'] ?? json['total']),
        lakiLaki: _asInt(
          json['penduduk_laki'] ?? json['laki_laki'] ?? json['laki'],
        ),
        perempuan: _asInt(json['penduduk_perempuan'] ?? json['perempuan']),
        kepalaKeluarga: _asInt(json['kepala_keluarga'] ?? json['jumlah_kk']),
        pendudukMiskin: _asInt(json['penduduk_miskin'] ?? json['miskin']),
        rasioJenisKelamin: _asDouble(json['rasio_jenis_kelamin']),
      );
}

class KelompokUmurModel {
  final String kelompok;
  final int jumlah;
  final double persentase;

  const KelompokUmurModel({
    required this.kelompok,
    required this.jumlah,
    required this.persentase,
  });

  factory KelompokUmurModel.fromJson(Map<String, dynamic> json) =>
      KelompokUmurModel(
        kelompok:
            json['kelompok_usia'] ?? json['kelompok'] ?? json['label'] ?? '',
        jumlah: _asInt(json['jumlah_jiwa'] ?? json['jumlah'] ?? json['value']),
        persentase: _asDouble(json['persentase']),
      );
}

class PendidikanModel {
  final String tingkat;
  final int jumlah;
  final double persentase;

  const PendidikanModel({
    required this.tingkat,
    required this.jumlah,
    required this.persentase,
  });

  factory PendidikanModel.fromJson(Map<String, dynamic> json) =>
      PendidikanModel(
        tingkat:
            json['tingkat_pendidikan'] ??
            json['tingkat'] ??
            json['label'] ??
            '',
        jumlah: _asInt(json['jumlah_jiwa'] ?? json['jumlah'] ?? json['value']),
        persentase: _asDouble(json['persentase']),
      );
}

class PekerjaanModel {
  final String jenis;
  final int jumlah;
  final double persentase;

  const PekerjaanModel({
    required this.jenis,
    required this.jumlah,
    required this.persentase,
  });

  factory PekerjaanModel.fromJson(Map<String, dynamic> json) => PekerjaanModel(
    jenis: json['jenis_pekerjaan'] ?? json['jenis'] ?? json['label'] ?? '',
    jumlah: _asInt(json['jumlah_jiwa'] ?? json['jumlah'] ?? json['value']),
    persentase: _asDouble(json['persentase']),
  );
}
