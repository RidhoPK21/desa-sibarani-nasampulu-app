import 'package:flutter/material.dart';

class AdminLayout extends StatelessWidget {
  final Widget child; // Pengganti <Outlet />

  const AdminLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Admin'),
        backgroundColor: Colors.blueGrey,
      ),
      // Drawer akan otomatis memunculkan tombol Garis Tiga (Hamburger) di AppBar
      drawer: Drawer(
        child: ListView(
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueGrey),
              child: Text('Menu Admin', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
            ),
          ],
        ),
      ),
      body: child, // Konten admin akan masuk ke sini
    );
  }
}