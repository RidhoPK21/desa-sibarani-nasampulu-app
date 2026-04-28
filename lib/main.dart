import 'package:flutter/material.dart';
import 'screens/beranda_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desa Sibarani Nasampulu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF3D8B6E),
      ),
      home: const BerandaScreen(),
    );
  }
}