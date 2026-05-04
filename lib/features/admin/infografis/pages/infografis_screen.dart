import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/dusun_provider.dart';
import '../models/dusun_model.dart';

class InfografisScreen extends ConsumerWidget {
  const InfografisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryGreen = Color(0xFF4EA674);
    final dusunAsync = ref.watch(dusunListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(dusunListProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                        color: const Color(0xFFA8D5BA).withValues(alpha: 0.5),
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
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(7),
                            topRight: Radius.circular(7),
                          ),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(width: 30, child: Text("No", style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(child: Text("Nama Dusun", style: TextStyle(fontWeight: FontWeight.bold))),
                            SizedBox(width: 80, child: Text("L", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                            SizedBox(width: 80, child: Text("P", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                            SizedBox(width: 40, child: Icon(Icons.settings, size: 18)),
                          ],
                        ),
                      ),
                      
                      // Table Body (Realtime Data)
                      dusunAsync.when(
                        data: (dusuns) {
                          if (dusuns.isEmpty) {
                            return const SizedBox(height: 100, child: Center(child: Text("Belum ada data dusun", style: TextStyle(color: Colors.grey))));
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: dusuns.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final dusun = dusuns[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                child: Row(
                                  children: [
                                    SizedBox(width: 30, child: Text("${index + 1}")),
                                    Expanded(child: Text(dusun.namaDusun, style: const TextStyle(fontWeight: FontWeight.w500))),
                                    SizedBox(width: 80, child: Text("${dusun.pendudukLaki}", textAlign: TextAlign.center)),
                                    SizedBox(width: 80, child: Text("${dusun.pendudukPerempuan}", textAlign: TextAlign.center)),
                                    SizedBox(
                                      width: 40, 
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                        onPressed: () => _confirmDelete(context, ref, dusun),
                                      )
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                        error: (err, stack) => SizedBox(height: 100, child: Center(child: Text("Gagal memuat data: $err", style: const TextStyle(color: Colors.red)))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, DusunModel dusun) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Data"),
        content: Text("Yakin ingin menghapus data Dusun ${dusun.namaDusun}?"),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              context.pop();
              await ref.read(dusunListProvider.notifier).deleteDusun(dusun.id!);
            }, 
            child: const Text("Hapus", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}
