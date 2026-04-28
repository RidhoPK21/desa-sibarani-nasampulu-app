import 'package:flutter/material.dart';

class SambutanCard extends StatelessWidget {
  const SambutanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.black54,
            child: const Center(
              child: Icon(Icons.image, color: Colors.white38, size: 60),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Salam',
                    style: TextStyle(color: Color(0xFF80CBC4), fontSize: 12)),
                  const Text('Kata Sambutan Kepala Desa',
                    style: TextStyle(color: Colors.white,
                        fontSize: 16, fontWeight: FontWeight.bold)),
                  const Text('Bapak Soltan Sibarani',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
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
          ),
        ],
      ),
    );
  }
}