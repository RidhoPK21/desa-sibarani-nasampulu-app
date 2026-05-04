// lib/features/public/apbdes/data/repositories/apbdes_repository.dart

import 'package:desa_sibarani_app/features/public/apbdes/data/models/apbdes_model.dart';

class ApbdesRepository {
  Future<List<ApbdesModel>> getApbdesList() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      ApbdesModel(
        id: '1',
        tahun: 'APBDes 2024',
        imageUrl: 'https://picsum.photos/seed/apbdes2024/600/300',
        tanggal: 'Mar 15, 2026',
        jam: '8:00 PM',
        lokasi: 'Sibarani',
        catatanPerubahan: 'Perubahan anggaran tahun 2024 telah disetujui oleh BPD.',
        pelaksanaan: PelaksanaanModel(
          pendapatan: 'Rp 1.488.196.197',
          belanja: 'Rp 1.266.720.597',
          pembiayaan: 'Rp 221.475.600',
        ),
        pendapatan: [
          ItemKeuanganModel(nama: 'Pendapatan Asli Desa', jumlah: 'Rp 1.488.196.197'),
          ItemKeuanganModel(nama: 'Dana Desa', jumlah: 'Rp 1.266.720.597'),
          ItemKeuanganModel(nama: 'Alokasi Dana Desa', jumlah: 'Rp 221.475.600'),
          ItemKeuanganModel(nama: 'Bagi Hasil Pajak dan Retribusi', jumlah: 'Rp 221.475.600'),
          ItemKeuanganModel(nama: 'Lain-Lain Pendapatan Desa Yang Sah', jumlah: 'Rp 221.475.600'),
        ],
        belanja: [
          ItemKeuanganModel(nama: 'Bidang Penyelenggaraan Pemerintahan Desa', jumlah: 'Rp 1.488.196.197'),
          ItemKeuanganModel(nama: 'Bidang Pelaksanaan Pembangunan Desa', jumlah: 'Rp 1.266.720.597'),
          ItemKeuanganModel(nama: 'Bidang Pembinaan Kemasyarakatan', jumlah: 'Rp 221.475.600'),
          ItemKeuanganModel(nama: 'Bidang Pemberdayaan Masyarakat', jumlah: 'Rp 221.475.600'),
          ItemKeuanganModel(nama: 'Bidang Penanggulangan Bencana, Darurat dan Keadaan Mendesak', jumlah: 'Rp 221.475.600'),
        ],
        pembiayaan: [
          ItemKeuanganModel(nama: 'Silpa Tahun Sebelumnya', jumlah: 'Rp 1.488.196.197'),
          ItemKeuanganModel(nama: 'Penyertaan Modal Desa', jumlah: 'Rp 1.488.196.197'),
        ],
      ),
      ApbdesModel(
        id: '2',
        tahun: 'APBDes 2025',
        imageUrl: 'https://picsum.photos/seed/apbdes2025/600/300',
        tanggal: 'Mar 15, 2026',
        jam: '8:00 PM',
        lokasi: 'Sibarani',
        catatanPerubahan: 'Perubahan anggaran tahun 2025 telah disetujui oleh BPD.',
        pelaksanaan: PelaksanaanModel(
          pendapatan: 'Rp 1.500.000.000',
          belanja: 'Rp 1.450.000.000',
          pembiayaan: 'Rp 25.000.000',
        ),
        pendapatan: [
          ItemKeuanganModel(nama: 'Pendapatan Asli Desa', jumlah: 'Rp 1.500.000.000'),
          ItemKeuanganModel(nama: 'Dana Desa', jumlah: 'Rp 1.300.000.000'),
          ItemKeuanganModel(nama: 'Alokasi Dana Desa', jumlah: 'Rp 350.000.000'),
          ItemKeuanganModel(nama: 'Bagi Hasil Pajak dan Retribusi', jumlah: 'Rp 120.000.000'),
          ItemKeuanganModel(nama: 'Lain-Lain Pendapatan Desa Yang Sah', jumlah: 'Rp 30.000.000'),
        ],
        belanja: [
          ItemKeuanganModel(nama: 'Bidang Penyelenggaraan Pemerintahan Desa', jumlah: 'Rp 1.300.000.000'),
          ItemKeuanganModel(nama: 'Bidang Pelaksanaan Pembangunan Desa', jumlah: 'Rp 400.000.000'),
          ItemKeuanganModel(nama: 'Bidang Pembinaan Kemasyarakatan', jumlah: 'Rp 100.000.000'),
          ItemKeuanganModel(nama: 'Bidang Pemberdayaan Masyarakat', jumlah: 'Rp 50.000.000'),
          ItemKeuanganModel(nama: 'Bidang Penanggulangan Bencana, Darurat dan Keadaan Mendesak', jumlah: 'Rp 200.000.000'),
        ],
        pembiayaan: [
          ItemKeuanganModel(nama: 'Silpa Tahun Sebelumnya', jumlah: 'Rp 2.000.000'),
          ItemKeuanganModel(nama: 'Penyertaan Modal Desa', jumlah: 'Rp 1.500.000.000'),
        ],
      ),
    ];
  }

  Future<ApbdesModel> getApbdesDetail(String id) async {
    final list = await getApbdesList();
    return list.firstWhere((e) => e.id == id);
  }
}