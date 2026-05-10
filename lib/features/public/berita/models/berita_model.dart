class BeritaModel {
  final String id;
  final String judul;
  final String slug;
  final String konten;
  final String? gambarUrl;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  BeritaModel({
    required this.id,
    required this.judul,
    required this.slug,
    required this.konten,
    this.gambarUrl,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    return BeritaModel(
      id: json['id']?.toString() ?? '',
      judul: json['judul'] ?? 'Tanpa Judul',
      slug: json['slug'] ?? '',
      // Menerima 'konten' atau 'isi_berita' dari Laravel
      konten: json['konten'] ?? json['isi_berita'] ?? '',
      gambarUrl: json['gambar_url'] ?? json['gambar'],
      isPublished: json['is_published'] == 1 || json['is_published'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at']).toLocal()
          : DateTime.now(),
    );
  }
}