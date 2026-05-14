import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Navbar extends StatefulWidget {
  final String location;

  const Navbar({super.key, required this.location});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  bool _isOpen = false;

  static const _navItems = <_NavItem>[
    _NavItem(path: '/', label: 'Beranda', icon: Icons.home_rounded),
    _NavItem(path: '/profil', label: 'Profil', icon: Icons.badge_rounded),
    _NavItem(
      path: '/infografis',
      label: 'Infografis',
      icon: Icons.pie_chart_rounded,
    ),
    _NavItem(path: '/kegiatan', label: 'Kegiatan', icon: Icons.event_rounded),
    _NavItem(path: '/idm', label: 'Idm', icon: Icons.bar_chart_rounded),
    _NavItem(
      path: '/dokumentasi',
      label: 'Dokumentasi',
      icon: Icons.description_rounded,
    ),
    _NavItem(path: '/berita', label: 'Berita', icon: Icons.newspaper_rounded),
    _NavItem(path: '/apb-desa', label: 'APB Desa', icon: Icons.account_balance),
    _NavItem(
      path: '/galeri',
      label: 'Galeri',
      icon: Icons.photo_library_rounded,
    ),
  ];

  @override
  void didUpdateWidget(covariant Navbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location && _isOpen) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  void _goTo(String path) {
    if (_isOpen) {
      setState(() {
        _isOpen = false;
      });
    }

    final selectedRoute = _normalizeLocation(widget.location);
    if (selectedRoute == path) return;
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    final selectedRoute = _normalizeLocation(widget.location);

    return Material(
      color: const Color(0xFF4EA674),
      elevation: 2,
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;

            return Column(
              children: [
                SizedBox(
                  height: 72,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 24 : 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _goTo('/'),
                                borderRadius: BorderRadius.circular(8),
                                child: Row(
                                  children: [
                                    // BUNGKUS DENGAN SECRET LOGIN TRIGGER
                                    SecretLoginTrigger(
                                      child: Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Image.asset(
                                          'logoDesa.jpg', // Pastikan nama dan foldernya benar
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Icon(
                                            Icons.shield,
                                            color: Color(0xFF4EA674),
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Flexible(
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Desa Sibarani Nasampulu',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Kab. Toba Samosir',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Color(0xFFE8F5E9),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isDesktop)
                              Wrap(
                                spacing: 10,
                                children: _navItems.map((item) {
                                  final isSelected = selectedRoute == item.path;
                                  return _DesktopLink(
                                    label: item.label,
                                    selected: isSelected,
                                    onTap: () => _goTo(item.path),
                                  );
                                }).toList(),
                              )
                            else
                              IconButton(
                                tooltip: _isOpen ? 'Tutup menu' : 'Buka menu',
                                onPressed: () {
                                  setState(() {
                                    _isOpen = !_isOpen;
                                  });
                                },
                                icon: Icon(
                                  _isOpen
                                      ? Icons.close_rounded
                                      : Icons.menu_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (!isDesktop)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    child: _isOpen
                        ? Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4EA674),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 1180,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              8,
                              16,
                              14,
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                MediaQuery.sizeOf(context).height *
                                    0.62,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: _navItems.map((item) {
                                    final isSelected =
                                        selectedRoute == item.path;
                                    return _MobileLink(
                                      label: item.label,
                                      icon: item.icon,
                                      selected: isSelected,
                                      onTap: () => _goTo(item.path),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                        : const SizedBox.shrink(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

String _normalizeLocation(String location) {
  final path = Uri.tryParse(location)?.path ?? location;

  const paths = <String>[
    '/profil',
    '/infografis',
    '/kegiatan',
    '/idm',
    '/dokumentasi',
    '/berita',
    '/apb-desa',
    '/galeri',
  ];

  for (final itemPath in paths) {
    if (path == itemPath || path.startsWith('$itemPath/')) {
      return itemPath;
    }
  }

  return '/';
}

class _NavItem {
  final String path;
  final String label;
  final IconData icon;

  const _NavItem({required this.path, required this.label, required this.icon});
}

class _DesktopLink extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DesktopLink({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFFE8F5E9),
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MobileLink extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _MobileLink({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon = Icons.arrow_right_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: selected ? const Color(0xFF3B865D) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(icon, size: 19, color: const Color(0xFFE8F5E9)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── WIDGET PINTU RAHASIA (SILUMAN) ──
class SecretLoginTrigger extends StatefulWidget {
  final Widget child;
  const SecretLoginTrigger({super.key, required this.child});

  @override
  State<SecretLoginTrigger> createState() => _SecretLoginTriggerState();
}

class _SecretLoginTriggerState extends State<SecretLoginTrigger> {
  int _tapCount = 0;
  DateTime? _lastTap;

  void _handlePointerDown(PointerDownEvent event) {
    final now = DateTime.now();
    // Reset hitungan jika jeda lebih dari 500 milidetik
    if (_lastTap == null || now.difference(_lastTap!) > const Duration(milliseconds: 500)) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }
    _lastTap = now;

    // Jika ketukan mencapai 3, langsung teleportasi ke Login!
    if (_tapCount == 3) {
      _tapCount = 0; // Reset
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listener tidak memblokir efek klik dari InkWell milik Navbar
    return Listener(
      onPointerDown: _handlePointerDown,
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}