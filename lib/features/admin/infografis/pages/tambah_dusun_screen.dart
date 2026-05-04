import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/dusun_provider.dart';
import '../models/dusun_model.dart';

class TambahDusunScreen extends ConsumerStatefulWidget {
  const TambahDusunScreen({super.key});

  @override
  ConsumerState<TambahDusunScreen> createState() => _TambahDusunScreenState();
}

class _TambahDusunScreenState extends ConsumerState<TambahDusunScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedDusun;
  final _lakiCtrl = TextEditingController(text: '0');
  final _perempuanCtrl = TextEditingController(text: '0');
  bool _isSaving = false;
  int _activeTabIndex = 0;

  final List<String> _tabs = [
    "Info Dasar",
    "Agama & Perkawinan",
    "Usia",
    "Pendidikan",
    "Pekerjaan"
  ];

  final List<String> _dusunOptions = ["Dusun 1", "Dusun 2", "Dusun 3"];

  @override
  void dispose() {
    _lakiCtrl.dispose();
    _perempuanCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpanData() async {
    if (_selectedDusun == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih Dusun terlebih dahulu")),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final newDusun = DusunModel(
        namaDusun: _selectedDusun!,
        pendudukLaki: int.parse(_lakiCtrl.text),
        pendudukPerempuan: int.parse(_perempuanCtrl.text),
      );

      await ref.read(dusunListProvider.notifier).addDusun(newDusun);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data Dusun Berhasil Disimpan!")),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Gagal menyimpan: $e"),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF4EA674);
    const lightGreenBg = Color(0xFFE8F5E9);
    const greyBg = Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Image.asset(
                    'assets/logo-toba.jpg',
                    height: 60,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.account_balance, size: 50, color: primaryGreen),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "SISTEM INFORMASI DESA",
                          style: TextStyle(
                            color: primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "SIBARANI NASAMPULU",
                          style: TextStyle(
                            color: primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- MENU & BUTTONS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFC8E6C9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black),
                      onPressed: () {},
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Batal"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _simpanData,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle_outline, size: 20),
                    label: const Text("Simpan Data"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),

            // --- BANNER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              color: const Color(0xFFD7DFD9),
              child: Row(
                children: [
                  const Icon(Icons.menu_book, size: 20, color: primaryGreen),
                  const SizedBox(width: 8),
                  const Text(
                    "Input Data Dusun & Demografi Baru",
                    style: TextStyle(
                      color: Color(0xFF1B5E20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // --- TABS ---
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: const Color(0xFFA5D6A7),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final isSelected = _activeTabIndex == index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        _tabs[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (val) => setState(() => _activeTabIndex = index),
                      selectedColor: primaryGreen,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      showCheckmark: false,
                    ),
                  );
                },
              ),
            ),

            // --- FORM CONTENT ---
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Section Profil Dusun
                      _buildSectionHeader("Profil Dusun"),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Pilih Dusun", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedDusun,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              hint: const Text("--Pilih Dusun--"),
                              items: _dusunOptions.map((e) {
                                return DropdownMenuItem(value: e, child: Text(e));
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedDusun = val),
                            ),
                          ],
                        ),
                      ),

                      // Section Total Penduduk
                      _buildSectionHeader("Total Penduduk (Master)"),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Penduduk Laki-Laki (Jiwa)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _lakiCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text("Penduduk Perempuan (Jiwa)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _perempuanCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: const Color(0xFFEEEEEE),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
