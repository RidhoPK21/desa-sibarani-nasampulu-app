import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PublicLayout extends StatelessWidget {
  final Widget child; // Ini adalah pengganti <Outlet /> dari React
  final String location;

  const PublicLayout({super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context) {
    final currentIndex = location == '/idm' ? 1 : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(location == '/idm' ? 'IDM Desa' : 'Desa Sibarani'),
        backgroundColor: const Color(0xFF4EA674),
      ),
      body: child, // Konten halaman akan muncul di sini
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == currentIndex) return;
          context.go(index == 0 ? '/' : '/idm');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'IDM'),
        ],
      ),
    );
  }
}
