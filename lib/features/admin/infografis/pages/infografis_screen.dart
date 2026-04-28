import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InfografisScreen extends StatelessWidget {
  const InfografisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF4EA674);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Row(
                children: [
                  Image.asset(
                    'assets/logo-toba.jpg',
                    height: 60,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.account_balance, size: 50, color: primaryGreen),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Text(
                      "SISTEM INFORMASI DESA\nSIBARANI NASAMPULU",
                      style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- SUBHEADER ---
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA8D5BA).withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.list, color: Colors.black87, size: 30),
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    "Infografis & Demografi Dusun",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- TOMBOL TAMBAH ---
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/admin/infografis/tambah'),
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  label: const Text("Tambah Dusun"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // --- TABLE CONTAINER ---
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade400,
                    style: BorderStyle.solid, // Note: Flutter doesn't native dashed border without package, using solid for now
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(7),
                          topRight: Radius.circular(7),
                        ),
                      ),
                      child: Row(
                        children: const [
                          SizedBox(width: 30, child: Text("No", style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 60, child: Text("Kode", style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text("Nama Dusun", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100, child: Center(child: Text("Belum ada data dusun", style: TextStyle(color: Colors.grey)))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
