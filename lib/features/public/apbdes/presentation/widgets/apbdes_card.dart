// lib/features/public/apbdes/presentation/widgets/apbdes_card.dart

import 'package:flutter/material.dart';
import 'package:desa_sibarani_app/features/public/apbdes/data/models/apbdes_model.dart';

class ApbdesCard extends StatelessWidget {
  final ApbdesModel apbdes;
  final VoidCallback onTap;

  const ApbdesCard({
    super.key,
    required this.apbdes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar + overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: _buildImage(),
                ),
                // Gradient overlay gelap
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.65),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Judul kiri bawah
                Positioned(
                  bottom: 10,
                  left: 12,
                  child: Text(
                    apbdes.tahun,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                // View Details kanan bawah
                Positioned(
                  bottom: 10,
                  right: 12,
                  child: Row(
                    children: const [
                      Text(
                        'View Details ',
                        style: TextStyle(
                          color: Color(0xFF90EE90),
                          fontSize: 12,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF90EE90),
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Info bawah
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(apbdes.tanggal,
                      style:
                      const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 12),
                  const Icon(Icons.access_time, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(apbdes.jam,
                      style:
                      const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 12),
                  const Icon(Icons.location_on, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(apbdes.lokasi,
                      style:
                      const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    // Coba load network image, fallback ke gradient
    if (apbdes.imageUrl.startsWith('http')) {
      return Image.network(
        apbdes.imageUrl,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildGradientBox();
        },
        errorBuilder: (_, __, ___) => _buildGradientBox(),
      );
    }
    return _buildGradientBox();
  }

  Widget _buildGradientBox() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade900,
            Colors.deepOrange.shade600,
            Colors.orange.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.account_balance,
          color: Colors.white30,
          size: 60,
        ),
      ),
    );
  }
}