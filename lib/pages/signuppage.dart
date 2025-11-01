import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sik_hangnadim_mobile/pages/loginpage.dart';
import 'package:sik_hangnadim_mobile/utils/constants.dart';
import '../widgets/text_global.dart';
import '../widgets/button_global.dart';
import '../utils/storage.dart'; // pastikan path sesuai

class Daftar extends StatefulWidget {
  const Daftar({Key? key}) : super(key: key);

  @override
  _DaftarState createState() => _DaftarState();
}

class _DaftarState extends State<Daftar> {
  final TextEditingController brandNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController vendorNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isAgreed = false;
  bool isLoading = false;

  bool isPasswordStrong(String password) {
    final regex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );
    return regex.hasMatch(password);
  }

  Future<void> registerUser() async {
    final brandName = brandNameController.text.trim();
    final email = emailController.text.trim();
    final vendorName = vendorNameController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    // Validasi input
    if (brandName.isEmpty ||
        email.isEmpty ||
        vendorName.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Semua field wajib diisi!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Konfirmasi password tidak sama!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!isPasswordStrong(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '❌ Password minimal 8 karakter, harus ada huruf besar, kecil, angka, dan simbol!',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Anda harus menyetujui Syarat & Ketentuan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final payload = {
        // backend expects 'name' field for the user/brand
        'name': brandName,
        'email': email,
        'vendor_name': vendorName,
        'password': password,
        'password_confirmation': confirm,
      };

      // Debug: log password lengths and equality (do not log raw passwords in production)
      // ignore: avoid_print
      print('Register payload - password.len=${password.length}, confirm.len=${confirm.length}, equal=${password == confirm}');
      // ignore: avoid_print
      print('Register payload json preview: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      // ignore: avoid_print
      print('Register response status: ${response.statusCode}');
      // ignore: avoid_print
      print('Register response body preview: ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');

      final body = response.body;
      Map<String, dynamic>? data;
      try {
        data = jsonDecode(body);
      } catch (_) {
        data = null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Simpan token jika ada
        if (data != null && data['token'] != null) {
          await Storage.saveToken(data['token']);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Pendaftaran berhasil, silakan login!'),
            backgroundColor: Colors.green,
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
        });
      } else {
        // try to extract helpful message from JSON error structure
        String message = 'Terjadi kesalahan';
        if (data != null) {
          if (data.containsKey('message')) {
            message = data['message'].toString();
          } else if (data.containsKey('errors')) {
            final errors = data['errors'];
            if (errors is Map && errors.isNotEmpty) {
              final first = errors.values.first;
              if (first is List && first.isNotEmpty) {
                message = first.first.toString();
              } else {
                message = first.toString();
              }
            }
          }
        } else if (body.isNotEmpty) {
          message = body;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Gagal daftar: $message',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error koneksi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Image.asset(
                    "assets/images/logo.png",
                    width: 150,
                    height: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Daftar Akun Anda",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextGlobal(
                  controller: brandNameController,
                  label: 'Nama Brand',
                  text: 'Masukkan nama brand',
                  textInputType: TextInputType.text,
                  obscure: false,
                ),
                const SizedBox(height: 20),
                TextGlobal(
                  controller: emailController,
                  label: 'Email',
                  text: 'Masukkan email',
                  textInputType: TextInputType.emailAddress,
                  obscure: false,
                ),
                const SizedBox(height: 20),
                TextGlobal(
                  controller: vendorNameController,
                  label: 'Nama Legal Vendor',
                  text: 'Masukkan nama legal vendor',
                  textInputType: TextInputType.text,
                  obscure: false,
                ),
                const SizedBox(height: 20),
                TextGlobal(
                  controller: passwordController,
                  label: 'Password',
                  text: '********',
                  textInputType: TextInputType.text,
                  obscure: true,
                ),
                const SizedBox(height: 20),
                TextGlobal(
                  controller: confirmPasswordController,
                  label: 'Konfirmasi Password',
                  text: '********',
                  textInputType: TextInputType.text,
                  obscure: true,
                ),
                CheckboxListTile(
                  value: isAgreed,
                  onChanged: (v) => setState(() => isAgreed = v ?? false),
                  title: const Text('Saya menyetujui Syarat & Ketentuan'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 10),
                ButtonGlobal(
                  buttonText: isLoading ? 'Memproses...' : 'Sign Up',
                  onTap: isLoading ? null : registerUser,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 50,
          color: Colors.white,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Sudah punya akun?'),
              const SizedBox(width: 5),
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
                child: const Text(
                  'Login',
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
