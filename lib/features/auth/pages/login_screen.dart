import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    // Simulasi Login
    await ref.read(authProvider.notifier).login("dummy_session_token");
    if (mounted) {
      context.go('/admin');
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF5BAA7B);
    const darkGreen = Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              // --- JUDUL ATAS ---
              const Text(
                "SISTEM INFORMASI DESA\nSIBARANI NASAMPULU",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 40),

              // --- LOGO ---
              Image.asset(
                'assets/logo-toba.jpg',
                height: 180,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.account_balance, size: 120, color: primaryGreen),
              ),

              const SizedBox(height: 30),

              // --- TEKS LOGIN ---
              const Text(
                "Login",
                style: TextStyle(
                  color: Color(0xFF00695C),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // --- INPUT USERNAME ---
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Username',
                  hintStyle: const TextStyle(color: Colors.black26),
                  prefixIcon: const Icon(Icons.account_circle, color: primaryGreen, size: 35),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: primaryGreen),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- INPUT PASSWORD ---
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Colors.black26),
                  prefixIcon: const Icon(Icons.lock, color: primaryGreen, size: 30),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: IconButton(
                      icon: Icon(
                        Icons.visibility,
                        color: Colors.grey.shade300,
                        size: 25,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: primaryGreen),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- TOMBOL LOGIN ---
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- LUPA PASSWORD ---
              TextButton(
                onPressed: () {},
                child: const Text(
                  "Lupa Password?",
                  style: TextStyle(
                    color: Color(0xFF8DC6A6),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
