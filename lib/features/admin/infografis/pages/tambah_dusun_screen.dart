import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TambahDusunScreen extends StatelessWidget {
  const TambahDusunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF4EA674);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER ---
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
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
                    ),

                    // --- ICON MENU & BUTTONS ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA8D5BA).withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.list, color: Colors.black87, size: 30),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () => context.pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDEDFE2),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Batal"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                            label: const Text("Simpan Data"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- SECTION TITLE ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      color: const Color(0xFFDEDFE2),
                      child: Row(
                        children: const [
                          Icon(Icons.map_outlined, size: 20),
                          SizedBox(width: 10),
                          Text(
                            "Input Data Dusun & Demografi Baru",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    // --- TAB TABS (Fixed and Responsive) ---
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      color: const Color(0xFFA8D5BA).withOpacity(0.5),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _buildTab("Info Dasar", true),
                            _buildTab("Agama & Perkawinan", false),
                            _buildTab("Usia", false),
                            _buildTab("Pendidikan", false),
                            _buildTab("Pekerjaan", false),
                          ],
                        ),
                      ),
                    ),

                    // --- FORM SECTION: PROFIL DUSUN ---
                    const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text("Profil Dusun", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Pilih Dusun", style: TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                hint: const Text("--Pilih Dusun--"),
                                isExpanded: true,
                                items: const [],
                                onChanged: (v) {},
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- FORM SECTION: TOTAL PENDUDUK ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      color: const Color(0xFFE8E8E8),
                      child: const Text("Total Penduduk (Master)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Penduduk Laki-Laki (Jiwa)", style: TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 8),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "0",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text("Penduduk Perempuan (Jiwa)", style: TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 8),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "0",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF2E7D32) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          if (!isActive)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
