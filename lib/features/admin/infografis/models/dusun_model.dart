class DusunModel {
  final int? id;
  final String namaDusun;
  final int pendudukLaki;
  final int pendudukPerempuan;

  DusunModel({
    this.id,
    required this.namaDusun,
    required this.pendudukLaki,
    required this.pendudukPerempuan,
  });

  factory DusunModel.fromJson(Map<String, dynamic> json) {
    return DusunModel(
      id: json['id'],
      namaDusun: json['nama_dusun'] ?? '',
      pendudukLaki: int.tryParse(json['penduduk_laki']?.toString() ?? '0') ?? 0,
      pendudukPerempuan: int.tryParse(json['penduduk_perempuan']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_dusun': namaDusun,
      'penduduk_laki': pendudukLaki,
      'penduduk_perempuan': pendudukPerempuan,
    };
  }
}
