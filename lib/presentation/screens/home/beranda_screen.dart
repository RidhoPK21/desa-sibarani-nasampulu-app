import 'package:flutter/material.dart';
import '../../widgets/home/nav_tab_bar.dart';
import '../../widgets/home/sambutan_card.dart';
import '../../widgets/home/berita_card.dart';
import '../../widgets/home/demografi_card.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  int _selectedTab = 0;

  final List<String> _tabs = [
    'Beranda', 'Profil', 'Infografis', 'Kegiatan',
    'IDM', 'Dokumentasi', 'Berita', 'APB Desa', 'Galeri'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3D8B6E),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            NavTabBar(
              tabs: _tabs,
              selectedIndex: _selectedTab,
              onTabSelected: (i) => setState(() => _selectedTab = i),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 16),
                    Text(
                      'Selamat Datang di Mobile Desa Sibarani',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    SambutanCard(),
                    SizedBox(height: 24),
                    Text(
                      'Berita Terkini',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    BeritaCard(),
                    SizedBox(height: 24),
                    Text(
                      'Ringkasan Demografi Desa',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    DemografiSection(),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white24,
            child: Icon(Icons.location_city, color: Colors.white),
          ),
          const SizedBox(width: 10),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              children: [
                TextSpan(text: 'Sibarani ',
                  style: TextStyle(color: Colors.white)),
                TextSpan(text: 'Nasampulu',
                  style: TextStyle(color: Color(0xFFB2DFDB))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}