// lib/features/public/apbdes/data/repositories/apbdes_repository.dart

import 'package:desa_sibarani_app/features/public/apbdes/data/models/apbdes_model.dart';

class ApbdesRepository {
  Future<List<ApbdesModel>> getApbdesList() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      ApbdesModel(
        id: '1',
        tahun: 'APBDes 2024',
        imageUrl: 'assets/images/apbdes_bg.jpg',
        tanggal: 'Mar 15, 2026',
        jam: '8:00 PM',
        lokasi: 'Sibarani',
        pelaksanaan: PelaksanaanModel(
          pendapatan: 'Rp 1.400.000.000',
          belanja: 'Rp 1.384.732.647',
          pembiayaan: 'Rp 22.475.000',
        ),
        pendapatan: [
          ItemKeuanganModel(nama: 'Dana Desa', jumlah: 'Rp 1.980.713.000'),
          ItemKeuanganModel(nama: 'Alokasi Dana Desa', jumlah: 'Rp 321.479.000'),
          ItemKeuanganModel(nama: 'Bagi Hasil Pajak dan Retribusi', jumlah: 'Rp 101.479.000'),
          ItemKeuanganModel(nama: 'Lain-lain Pendapatan Desa Yang Sah', jumlah: 'Rp 23.475.000'),
        ],
        belanja: [
          ItemKeuanganModel(nama: 'Bidang Penyelenggaraan Pemerintahan Desa', jumlah: 'Rp 1.264.732.647'),
          ItemKeuanganModel(nama: 'Bidang Pelaksanaan Pembangunan Desa', jumlah: 'Rp 313.476.000'),
          ItemKeuanganModel(nama: 'Bidang Pemberdayaan Masyarakat', jumlah: 'Rp 2.625.000'),
          ItemKeuanganModel(nama: 'Bidang Penanggulangan Bencana, Keadaan Darurat dan Keadaan Mendesak', jumlah: 'Rp 425.100.000'),
        ],
        pembiayaan: [
          ItemKeuanganModel(nama: 'Sisa Dana Sebelumnya', jumlah: 'Rp 1.880.547'),
          ItemKeuanganModel(nama: 'Pengeluaran Dana Desa', jumlah: 'Rp 1.480.000.000'),
        ],
      ),
      ApbdesModel(
        id: '2',
        tahun: 'APBDes 2025',
        imageUrl: 'assets/images/apbdes_bg.jpg',
        tanggal: 'Mar 15, 2026',
        jam: '8:00 PM',
        lokasi: 'Sibarani',
        pelaksanaan: PelaksanaanModel(
          pendapatan: 'Rp 1.500.000.000',
          belanja: 'Rp 1.450.000.000',
          pembiayaan: 'Rp 25.000.000',
        ),
        pendapatan: [
          ItemKeuanganModel(nama: 'Dana Desa', jumlah: 'Rp 2.100.000.000'),
          ItemKeuanganModel(nama: 'Alokasi Dana Desa', jumlah: 'Rp 350.000.000'),
          ItemKeuanganModel(nama: 'Bagi Hasil Pajak dan Retribusi', jumlah: 'Rp 120.000.000'),
          ItemKeuanganModel(nama: 'Lain-lain Pendapatan Desa Yang Sah', jumlah: 'Rp 30.000.000'),
        ],
        belanja: [
          ItemKeuanganModel(nama: 'Bidang Penyelenggaraan Pemerintahan Desa', jumlah: 'Rp 1.300.000.000'),
          ItemKeuanganModel(nama: 'Bidang Pelaksanaan Pembangunan Desa', jumlah: 'Rp 400.000.000'),
          ItemKeuanganModel(nama: 'Bidang Pemberdayaan Masyarakat', jumlah: 'Rp 50.000.000'),
          ItemKeuanganModel(nama: 'Bidang Penanggulangan Bencana, Keadaan Darurat dan Keadaan Mendesak', jumlah: 'Rp 200.000.000'),
        ],
        pembiayaan: [
          ItemKeuanganModel(nama: 'Sisa Dana Sebelumnya', jumlah: 'Rp 2.000.000'),
          ItemKeuanganModel(nama: 'Pengeluaran Dana Desa', jumlah: 'Rp 1.500.000.000'),
        ],
      ),
    ];
  }

  Future<ApbdesModel> getApbdesDetail(String id) async {
    final list = await getApbdesList();
    return list.firstWhere((e) => e.id == id);
  }
}