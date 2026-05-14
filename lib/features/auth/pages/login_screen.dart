import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

// PASTIKAN path import ini sesuai dengan folder di proyekmu!
import '../../../core/network/api_client.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController(); // TAMBAHAN: Controller Email
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose(); // Jangan lupa dibuang
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim(); // Ambil data email
    final password = _passwordController.text;

    // Validasi 3 Input Kosong
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom (Username, Email, Password) wajib diisi!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TEMBAK API!
      // Karena kita sudah tahu rute resminya dari React adalah /auth/portal-pemdes
      // Pastikan api_client.dart kamu baseUrl-nya adalah: 'http://127.0.0.1:9000/api'
      final response = await api.post('/auth/portal-pemdes', data: {
        'username': username,
        'email': email,       // TAMBAHAN: Kirim email ke server
        'password': password,
      });

      final token = response.data['token'] ?? response.data['data']?['token'];

      if (token != null) {
        await ref.read(authProvider.notifier).login(token);
        if (mounted) {
          context.go('/admin');
        }
      } else {
        throw Exception("Token tidak ditemukan dalam respons server.");
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Terjadi kesalahan saat login.';

        if (e.toString().contains('401')) {
          errorMessage = 'Username, email, atau password salah!';
        } else if (e.toString().contains('422')) {
          errorMessage = 'Format input tidak valid. Periksa kembali email Anda.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF5BAA7B);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: [
              const SizedBox(height: 50),

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

              Image.asset(
                'logoDesa.jpg', // Sesuaikan nama logo
                height: 150,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.account_balance, size: 120, color: primaryGreen),
              ),
              const SizedBox(height: 30),

              const Text(
                "Masuk ke Akun Anda",
                style: TextStyle(
                  color: Color(0xFF00695C),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // --- INPUT USERNAME ---
              TextField(
                controller: _usernameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Username',
                  prefixIcon: const Icon(Icons.person, color: primaryGreen),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 20),

              // --- INPUT EMAIL (BARU) ---
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email, color: primaryGreen),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 20),

              // --- INPUT PASSWORD ---
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleLogin(),
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock, color: primaryGreen),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 30),

              // --- TOMBOL LOGIN ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Masuk", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}