// lib/shared/layouts/public_layout.dart

import 'package:flutter/material.dart';
import 'navbar.dart'; // 🔥 Import Navbar buatan temanmu

class PublicLayout extends StatefulWidget {
  final Widget child;
  final String location;

  const PublicLayout({super.key, required this.child, required this.location});

  @override
  State<PublicLayout> createState() => _PublicLayoutState();
}

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
      ),
    );
  }
}