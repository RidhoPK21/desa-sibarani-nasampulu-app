import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 1. Inisialisasi Brankas Penyimpanan
final secureStorage = const FlutterSecureStorage();

// 2. Class Satpam versi Riverpod 3 (Menggunakan Notifier)
class AuthNotifier extends Notifier<bool> {
  // Fungsi build() adalah pengganti super() di versi lama.
  // Fungsi ini wajib ada untuk menentukan nilai awal state.
  @override
  bool build() {
    checkLoginStatus(); // Cek token di background saat aplikasi pertama kali jalan
    return false; // Nilai default awal: false (belum login)
  }

  // Cek brankas untuk memastikan sesi
  Future<void> checkLoginStatus() async {
    String? token = await secureStorage.read(key: 'auth_token');
    // Jika token ada, ubah state menjadi true.
    // Di Riverpod 3, mengubah variabel 'state' akan otomatis memperbarui UI.
    state = token != null;
  }

  // Dipanggil saat login sukses dari API
  Future<void> login(String token) async {
    await secureStorage.write(key: 'auth_token', value: token);
    state = true;
  }

  // Dipanggil saat tekan tombol Logout
  Future<void> logout() async {
    await secureStorage.delete(key: 'auth_token');
    state = false;
  }
}

// 3. Provider baru menggunakan NotifierProvider
final authProvider = NotifierProvider<AuthNotifier, bool>(() {
  return AuthNotifier();
});
