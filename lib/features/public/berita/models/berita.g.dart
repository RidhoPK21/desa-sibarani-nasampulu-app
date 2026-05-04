// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'berita.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Berita _$BeritaFromJson(Map<String, dynamic> json) => Berita(
  id: json['id'] as String,
  judul: json['judul'] as String,
  slug: json['slug'] as String,
  konten: json['konten'] as String,
  gambarUrl: json['gambar_url'] as String?,
  isPublished: json['is_published'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$BeritaToJson(Berita instance) => <String, dynamic>{
  'id': instance.id,
  'judul': instance.judul,
  'slug': instance.slug,
  'konten': instance.konten,
  'gambar_url': instance.gambarUrl,
  'is_published': instance.isPublished,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
