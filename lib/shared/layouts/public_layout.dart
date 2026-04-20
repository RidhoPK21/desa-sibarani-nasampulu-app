import 'package:flutter/material.dart';

class PublicLayout extends StatelessWidget {
  final Widget child; // Ini adalah pengganti <Outlet /> dari React

  const PublicLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desa Sibarani'),
        backgroundColor: const Color(0xFF4EA674),
      ),
      body: child, // Konten halaman akan muncul di sini
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Berita'),
        ],
      ),
    );
  }
}