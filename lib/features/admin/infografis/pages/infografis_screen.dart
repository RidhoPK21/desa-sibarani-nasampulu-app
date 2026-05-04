import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InfografisScreen extends StatelessWidget {
  const InfografisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF4EA674);
    const teal900 = Color(0xFF134E4A);

    // Mock Data untuk demonstrasi UI Full
    final mockDusuns = [
      {'id': 'D01', 'nama': 'Dusun 1', 'L': 345, 'P': 320, 'total': 665},
      {'id': 'D02', 'nama': 'Dusun 2', 'L': 210, 'P': 240, 'total': 450},
      {'id': 'D03', 'nama': 'Dusun 3', 'L': 450, 'P': 430, 'total': 880},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Row(
                children: [
                  Image.asset('assets/logo-toba.jpg', height: 60, 
                    errorBuilder: (c, e, s) => const Icon(Icons.account_balance, size: 50, color: primaryGreen)),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      "Infografis & Demografi Dusun",
                      style: TextStyle(color: teal900, fontWeight: FontWeight.w900, fontSize: 22, fontFamily: 'Georgia'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // --- TITLE & ADD BUTTON ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Daftar Dusun & Total Penduduk",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: teal900),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/admin/infografis/tambah'),
                    icon: const Icon(Icons.add_circle, size: 18),
                    label: const Text("Tambah Dusun", style: TextStyle(fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(0xFF10B981).withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- TABLE CONTAINER ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))
                  ],
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  children: [
                    // Header Tabel
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFECFDF5),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 40, child: Text("ID", style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF064E3B), fontSize: 12))),
                          Expanded(child: Text("Nama Dusun", style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF064E3B), fontSize: 12))),
                          SizedBox(width: 60, child: Text("Total", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF064E3B), fontSize: 12))),
                          SizedBox(width: 60, child: Text("Aksi", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF064E3B), fontSize: 12))),
                        ],
                      ),
                    ),
                    
                    // List Item
                    ...mockDusuns.map((dusun) => _buildTableRow(dusun, teal900)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> dusun, Color teal900) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(dusun['id'], style: TextStyle(fontWeight: FontWeight.w900, color: teal900, fontSize: 13))),
          Expanded(child: Text(dusun['nama'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155)))),
          SizedBox(
            width: 60, 
            child: Text(
              "${dusun['total']}", 
              textAlign: TextAlign.center, 
              style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF059669), fontSize: 16)
            )
          ),
          SizedBox(
            width: 60, 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_note, color: Colors.blue.shade400, size: 22),
                const SizedBox(width: 8),
                Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
