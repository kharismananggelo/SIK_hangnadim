import 'package:flutter/material.dart';
import 'package:sik_hangnadim_mobile/utils/validators.dart';
import 'package:sik_hangnadim_mobile/widgets/social.dart';
import '../widgets/text_global.dart';
import '../widgets/button_global.dart';
import 'signuppage.dart';
import '../services/auth_service.dart';
import '../model/user_model.dart';
import '../utils/storage.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _emailError = false;
  bool _passwordError = false;
  String? _emailErrorText;
  String? _passwordErrorText;
  bool _isLoading = false;

  void _validateAndLogin() async {
    setState(() {
      _emailError = emailController.text.trim().isEmpty;
      _emailErrorText = _emailError ? 'Email harus diisi' : null;
      if (!_emailError && !Validators.isEmailValid(emailController.text)) {
        _emailError = true;
        _emailErrorText = 'Format email tidak valid';
      }

      _passwordError = passwordController.text.isEmpty;
      _passwordErrorText = _passwordError ? 'Password harus diisi' : null;
    });

    final missing = <String>[];
    if (_emailError) missing.add('Email');
    if (_passwordError) missing.add('Password');

    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Periksa isian: ${missing.join(', ')}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Semua input valid, mulai proses login
    setState(() => _isLoading = true);

    try {
      // 🔹 Panggil API login
      final User user = await _authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // 🔹 Simpan token di local storage untuk auto-login
      await Storage.saveToken(user.token ?? '');

      // 🔹 Tampilkan notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selamat datang, ${user.name}!'),
          backgroundColor: Colors.green,
        ),
      );

      // 🔹 Navigasi ke dashboard/home
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      // Map common server/format errors to friendly messages
      final errStr = e.toString();
      String userMessage = 'Login gagal. Silakan coba lagi.';

      if (errStr.contains('ENDPOINT_NOT_FOUND')) {
        userMessage = 'Endpoint tidak ditemukan. Periksa konfigurasi backend.';
      } else if (errStr.contains('SERVER_ERROR')) {
        userMessage = 'Server sedang bermasalah. Coba lagi nanti.';
      } else if (errStr.contains('INVALID_RESPONSE') || errStr.contains('<!DOCTYPE') || errStr.contains('<html')) {
        userMessage = 'Respons server tidak valid. Coba lagi nanti.';
      } else if (errStr.contains('LOGIN_FAILED') || errStr.contains('Login gagal')) {
        userMessage = 'Email atau password tidak valid.';
      } else {
        // Fallback: show the exception short form (without the leading 'Exception:')
        userMessage = errStr.replaceFirst('Exception: ', '');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userMessage), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 70),
                  child: Image.asset(
                    "assets/images/logo.png",
                    width: double.infinity,
                    height: 120,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  "Login ke akun anda",
                  style: TextStyle(
                    color: Color.fromRGBO(100, 100, 100, 0.8),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // Email input field
                TextGlobal(
                  controller: emailController,
                  label: 'Email',
                  text: 'Masukkan Email Anda',
                  textInputType: TextInputType.emailAddress,
                  obscure: false,
                  error: _emailError,
                  errorText: _emailErrorText,
                ),

                const SizedBox(height: 25),

                // Password input field
                TextGlobal(
                  controller: passwordController,
                  label: 'Password',
                  text: '*********',
                  textInputType: TextInputType.text,
                  obscure: true,
                  error: _passwordError,
                  errorText: _passwordErrorText,
                ),

                const SizedBox(height: 40),

                // 🔹 Login button (fix: tidak error meski onTap null)
                ButtonGlobal(
                  buttonText: _isLoading ? 'Loading...' : 'Login',
                  onTap: _isLoading ? () {} : _validateAndLogin,
                  isLoading: _isLoading, // jika ButtonGlobal punya param ini
                ),

                const SizedBox(height: 70),

                // 🔹 Hapus const biar tidak error
                SocialLogin(),
              ],
            ),
          ),
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 50,
          color: Colors.white,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Belum punya akun?'),
              const SizedBox(width: 5),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Daftar()),
                  );
                },
                child: const Text(
                  'Sign up',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
