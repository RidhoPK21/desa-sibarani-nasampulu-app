class BeritaModel {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final bool isPublished;
  final String? createdAt;

  const BeritaModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.isPublished,
    this.createdAt,
  });

  factory BeritaModel.fromJson(Map<String, dynamic> json) => BeritaModel(
    id: _asString(json['id']),
    title: _asString(json['judul'] ?? json['title']),
    content: _asString(json['konten'] ?? json['isi'] ?? json['content']),
    imageUrl: _nullableString(json['gambar_url'] ?? json['gambar']),
    isPublished: _asBool(json['is_published'] ?? json['published']),
    createdAt: _nullableString(json['created_at'] ?? json['tanggal']),
  );

  Map<String, dynamic> toPayload() => {
    'judul': title,
    'konten': content,
    'is_published': isPublished ? 1 : 0,
  };
}

class PpidDocumentModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String documentUrl;
  final String? createdAt;

  const PpidDocumentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.documentUrl,
    this.createdAt,
  });

  factory PpidDocumentModel.fromJson(Map<String, dynamic> json) =>
      PpidDocumentModel(
        id: _asString(json['id']),
        title: _asString(json['nama_ppid'] ?? json['judul'] ?? json['title']),
        description: _asString(
          json['deskripsi_ppid'] ?? json['deskripsi'] ?? json['description'],
        ),
        category: _asString(
          json['jenis_ppid'] ?? json['kategori'] ?? json['category'],
          fallback: 'Informasi Berkala',
        ),
        documentUrl: _asString(json['file_url'] ?? json['document_url']),
        createdAt: _nullableString(
          json['tanggal_upload'] ?? json['created_at'],
        ),
      );

  Map<String, dynamic> toPayload() => {
    'nama_ppid': title,
    'deskripsi_ppid': description,
    'jenis_ppid': category,
  };
}

class GaleriModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String? createdAt;

  const GaleriModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.createdAt,
  });

  factory GaleriModel.fromJson(Map<String, dynamic> json) => GaleriModel(
    id: _asString(json['id']),
    title: _asString(json['judul_kegiatan'] ?? json['judul'] ?? json['title']),
    description: _asString(
      json['deskripsi_kegiatan'] ?? json['deskripsi'] ?? json['description'],
    ),
    imageUrl: _asString(json['gambar_url'] ?? json['gambar'] ?? json['foto']),
    createdAt: _nullableString(json['tanggal_pelaksana'] ?? json['created_at']),
  );
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = '$value'.trim();
  return text.isEmpty ? fallback : text;
}

String? _nullableString(dynamic value) {
  final text = _asString(value);
  return text.isEmpty ? null : text;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = '$value'.toLowerCase();
  return text == '1' || text == 'true' || text == 'published';
}
