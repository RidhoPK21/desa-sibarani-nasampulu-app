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

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(apbdesDetailProvider(widget.id));

    return Scaffold(
      backgroundColor: const Color(0xFF4EA674),
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Sibarani ',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              TextSpan(
                text: 'Nasampulu',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        error: (e, _) => Center(
          child: Text(
            'Gagal memuat: $e',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        data: (detail) => SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pilih Versi Anggaran
                  _buildVersiSelector(),
                  const SizedBox(height: 12),

                  // Catatan Perubahan (hanya muncul di Versi 2)
                  if (_selectedVersi == 2) _buildCatatanPerubahan(detail),
                  if (_selectedVersi == 2) const SizedBox(height: 12),

                  // Pelaksanaan
                  _buildPelaksanaan(detail.pelaksanaan),
                  const SizedBox(height: 12),

                  // Pendapatan
                  ApbdesSectionTable(
                    title: 'Pendapatan',
                    items: detail.pendapatan,
                    headerColor: const Color(0xFF2E7D32),
                  ),
                  const SizedBox(height: 12),

                  // Belanja
                  ApbdesSectionTable(
                    title: 'Belanja',
                    items: detail.belanja,
                    headerColor: Colors.orange.shade700,
                  ),
                  const SizedBox(height: 12),

                  // Pembiayaan
                  ApbdesSectionTable(
                    title: 'Pembiayaan',
                    items: detail.pembiayaan,
                    headerColor: Colors.blue.shade700,
                  ),
                  const SizedBox(height: 24),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PILIH VERSI ANGGARAN:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Versi 1
              GestureDetector(
                onTap: () => setState(() => _selectedVersi = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedVersi == 1
                        ? const Color(0xFF2E7D32)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedVersi == 1
                          ? const Color(0xFF2E7D32)
                          : Colors.white54,
                    ),
                  ),
                  child: Text(
                    'Versi 1',
                    style: TextStyle(
                      color: _selectedVersi == 1
                          ? Colors.white
                          : Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Versi 2
              GestureDetector(
                onTap: () => setState(() => _selectedVersi = 2),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedVersi == 2
                        ? const Color(0xFF2E7D32)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedVersi == 2
                          ? const Color(0xFF2E7D32)
                          : Colors.white54,
                    ),
                  ),
                  child: Text(
                    'Versi 2 (Perubahan)',
                    style: TextStyle(
                      color: _selectedVersi == 2
                          ? Colors.white
                          : Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.amber.shade700, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catatan Perubahan (Versi 2):',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail.catatanPerubahan ?? 'Tidak ada catatan perubahan.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber.shade900,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pelaksanaan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 12),
          _buildPelaksanaanRow('PENDAPATAN :', pelaksanaan.pendapatan),
          const SizedBox(height: 10),
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 10),
          _buildPelaksanaanRow('BELANJA :', pelaksanaan.belanja),
          const SizedBox(height: 10),
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 10),
          _buildPelaksanaanRow('PEMBIAYAAN :', pelaksanaan.pembiayaan),
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
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}