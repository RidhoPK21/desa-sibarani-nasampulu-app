// lib/shared/layouts/public_layout.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PublicLayout extends StatelessWidget {
  final Widget child;
  final String location;

  const PublicLayout({super.key, required this.child, required this.location});

  int get _currentIndex {
    if (location.startsWith('/idm')) return 1;
    if (location.startsWith('/kegiatan')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        title: Row(
          children: [
            // Logo lingkaran kecil (opsional, bisa ganti dengan asset logo desa)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_city_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Sibarani ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: 'Nasampulu',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == _currentIndex) return;
            switch (index) {
              case 0:
                context.go('/');
              case 1:
                context.go('/idm');
              case 2:
                context.go('/kegiatan');
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2E7D32),
          unselectedItemColor: const Color(0xFF9E9E9E),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'IDM',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined),
              activeIcon: Icon(Icons.event_rounded),
              label: 'Kegiatan',
            ),
          ],
        ),
      ),
    );
  }
}