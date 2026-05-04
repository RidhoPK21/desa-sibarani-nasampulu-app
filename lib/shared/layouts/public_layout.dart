import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PublicLayout extends StatelessWidget {
  final Widget child;

  const PublicLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Tentukan index berdasarkan lokasi route saat ini
    final String location = GoRouterState.of(context).uri.toString();
    int currentIndex = location.startsWith('/berita') ? 1 : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Desa Sibarani', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4EA674),
        elevation: 0,
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFF4EA674),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            context.go('/');
          } else {
            context.go('/berita');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Berita'),
        ],
      ),
    );
  }
}
