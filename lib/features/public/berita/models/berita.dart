import 'package:json_annotation/json_annotation.dart';

part 'berita.g.dart';

@JsonSerializable()
class Berita {
  final String id;
  final String judul;
  final String slug;
  final String konten;
  @JsonKey(name: 'gambar_url')
  final String? gambarUrl;
  @JsonKey(name: 'is_published')
  final bool isPublished;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Berita({
    required this.id,
    required this.judul,
    required this.slug,
    required this.konten,
    this.gambarUrl,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Berita.fromJson(Map<String, dynamic> json) => _$BeritaFromJson(json);
  Map<String, dynamic> toJson() => _$BeritaToJson(this);
}
