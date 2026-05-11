// lib/shared/layouts/public_layout.dart

import 'package:flutter/material.dart';
import 'navbar.dart'; // 🔥 Import Navbar buatan temanmu

class PublicLayout extends StatefulWidget {
  final Widget child;
import '../../core/constants/app_assets.dart';

class PublicLayout extends StatelessWidget {
  final Widget child; // Ini adalah pengganti <Outlet /> dari React
  final String location;

  const PublicLayout({super.key, required this.child, required this.location});

  @override
  State<PublicLayout> createState() => _PublicLayoutState();
}
  Widget build(BuildContext context) {
    final currentIndex = switch (location) {
      '/idm' => 1,
      '/ppid' => 2,
      '/galeri' => 3,
      _ => 0,
    };
    final title = switch (location) {
      '/idm' => 'IDM Desa',
      '/ppid' => 'PPID Desa',
      '/galeri' => 'Galeri Desa',
      _ => 'Desa Sibarani',
    };

class _PublicLayoutState extends State<PublicLayout> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToTop();
  }

  @override
  void didUpdateWidget(covariant PublicLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _scrollToTop();
    }
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(0);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      body: SafeArea(
        child: Column(
          children: [
            Navbar(location: widget.location),

            // 2. Konten Halaman (Child)
            Expanded(
              child: PrimaryScrollController(
                controller: _scrollController,
                child: widget.child,
              ),
            ),
          ],
        ),
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(AppAssets.logoDesa, width: 30, height: 30),
            const SizedBox(width: 10),
            Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
          ],
        ),
        backgroundColor: const Color(0xFF4EA674),
      ),
      body: child, // Konten halaman akan muncul di sini
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == currentIndex) return;
          final path = switch (index) {
            1 => '/idm',
            2 => '/ppid',
            3 => '/galeri',
            _ => '/',
          };
          context.go(path);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'IDM'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_copy), label: 'PPID'),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Galeri',
          ),
        ],
      ),
    );
  }
}