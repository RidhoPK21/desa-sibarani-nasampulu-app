import 'package:flutter/material.dart';

class BeritaCard extends StatelessWidget {
  const BeritaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  color: Colors.black45,
                  child: const Center(
                      child: Icon(Icons.image, color: Colors.white38, size: 50)),
                ),
                Positioned(
                  bottom: 8, left: 12, right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Berita Terkini',
                          style: TextStyle(color: Color(0xFF80CBC4), fontSize: 11)),
                      Text('Judul Berita',
                          style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('MC Flow & DJ Beats',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(children: const [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('Mar 20, 2026',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  SizedBox(width: 16),
                  Icon(Icons.access_time, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('9:00 PM',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ]),
                const SizedBox(height: 4),
                Row(children: const [
                  Icon(Icons.location_on, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('Desa Sibarani Nasampulu',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ]),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('View Details →',
                        style: TextStyle(color: Color(0xFF4DB6AC))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}