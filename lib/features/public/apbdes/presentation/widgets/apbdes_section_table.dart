// lib/features/public/apbdes/presentation/widgets/apbdes_section_table.dart

import 'package:flutter/material.dart';
import 'package:desa_sibarani_app/features/public/apbdes/data/models/apbdes_model.dart';

class ApbdesSectionTable extends StatelessWidget {
  final String title;
  final List<ItemKeuanganModel> items;
  final Color headerColor;

  const ApbdesSectionTable({
    super.key,
    required this.title,
    required this.items,
    // 🔥 Taktik Intelijen: Ubah warna default menjadi Emerald/Teal kita
    this.headerColor = const Color(0xFF57A677),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // 🔥 Dibuat lebih membulat (16)
        border: Border.all(color: Colors.grey.shade100), // Tambahan border halus
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), // 🔥 Shadow lebih lembut & modern
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Tabel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: headerColor.withOpacity(0.1), // Opacity warna header lebih segar
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: headerColor.withOpacity(0.9), // Warna solid elegan
                    fontSize: 16,
                  ),
                ),
                Text(
                  'TOTAL',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: headerColor.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Items Tabel
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.nama} :',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54, // Warna teks abu-abu elegan
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        item.jumlah,
                        style: const TextStyle(
                          fontSize: 14, // Angka diperbesar sedikit
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < items.length - 1)
                  Divider(
                    height: 1,
                    color: Colors.grey.shade100, // Garis pembatas sangat halus
                    indent: 20,
                    endIndent: 20,
                  ),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}