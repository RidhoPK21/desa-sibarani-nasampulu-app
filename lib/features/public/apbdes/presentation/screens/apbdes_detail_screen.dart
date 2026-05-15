// lib/features/public/apbdes/presentation/screens/apbdes_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desa_sibarani_app/features/public/apbdes/presentation/providers/apbdes_provider.dart';
import 'package:desa_sibarani_app/features/public/apbdes/presentation/widgets/apbdes_section_table.dart';
import 'package:desa_sibarani_app/features/public/apbdes/data/models/apbdes_model.dart';

class ApbdesDetailScreen extends ConsumerStatefulWidget {
  final String id;

  const ApbdesDetailScreen({super.key, required this.id});

  @override
  ConsumerState<ApbdesDetailScreen> createState() => _ApbdesDetailScreenState();
}

class _ApbdesDetailScreenState extends ConsumerState<ApbdesDetailScreen> {
  int _selectedVersi = 1;

  // 🔥 Taktik Intelijen: Warna seragam Publik
  static const primaryGreen = Color(0xFF57A677);
  static const textGreen = Color(0xFF4EA674);

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(apbdesDetailProvider(widget.id));

    return Scaffold(
      backgroundColor: Colors.grey[50], // Background dicerahkan
      appBar: AppBar(
        title: const Text(
          'Rincian APBDes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: primaryGreen, // Warna selaras dengan Profil/List
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: primaryGreen),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              Text(
                'Gagal memuat: $e',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        data: (detail) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pilih Versi Anggaran (Diperbarui tampilannya)
                  _buildVersiSelector(),
                  const SizedBox(height: 16),

                  // Catatan Perubahan (hanya muncul di Versi 2)
                  if (_selectedVersi == 2) _buildCatatanPerubahan(detail),
                  if (_selectedVersi == 2) const SizedBox(height: 16),

                  // Pelaksanaan
                  _buildPelaksanaan(detail.pelaksanaan),
                  const SizedBox(height: 16),

                  // Pendapatan
                  ApbdesSectionTable(
                    title: 'Pendapatan',
                    items: detail.pendapatan,
                    headerColor: primaryGreen, // Diubah jadi emerald
                  ),
                  const SizedBox(height: 16),

                  // Belanja
                  ApbdesSectionTable(
                    title: 'Belanja',
                    items: detail.belanja,
                    headerColor: Colors.orange.shade600, // Sedikit dicerahkan
                  ),
                  const SizedBox(height: 16),

                  // Pembiayaan
                  ApbdesSectionTable(
                    title: 'Pembiayaan',
                    items: detail.pembiayaan,
                    headerColor: Colors.blue.shade600, // Sedikit dicerahkan
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVersiSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, // Box putih bersih
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PILIH VERSI ANGGARAN',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Versi 1
              GestureDetector(
                onTap: () => setState(() => _selectedVersi = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedVersi == 1
                        ? primaryGreen
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedVersi == 1
                          ? primaryGreen
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    'Versi 1',
                    style: TextStyle(
                      color: _selectedVersi == 1
                          ? Colors.white
                          : Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Versi 2
              GestureDetector(
                onTap: () => setState(() => _selectedVersi = 2),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedVersi == 2
                        ? primaryGreen
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedVersi == 2
                          ? primaryGreen
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    'Versi 2 (Perubahan)',
                    style: TextStyle(
                      color: _selectedVersi == 2
                          ? Colors.white
                          : Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCatatanPerubahan(ApbdesModel detail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info, color: Colors.amber.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catatan Perubahan (Versi 2):',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  detail.catatanPerubahan ?? 'Tidak ada catatan perubahan yang dicantumkan.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.amber.shade900,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPelaksanaan(PelaksanaanModel pelaksanaan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Pelaksanaan',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: textGreen, // Menggunakan textGreen agar senada
            ),
          ),
          const SizedBox(height: 16),
          _buildPelaksanaanRow('PENDAPATAN', pelaksanaan.pendapatan),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
          _buildPelaksanaanRow('BELANJA', pelaksanaan.belanja),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
          _buildPelaksanaanRow('PEMBIAYAAN', pelaksanaan.pembiayaan),
        ],
      ),
    );
  }

  Widget _buildPelaksanaanRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}