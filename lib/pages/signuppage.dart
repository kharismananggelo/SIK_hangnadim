import 'package:flutter/material.dart';
import 'package:sik_hangnadim_mobile/services/auth_service.dart';
import 'package:sik_hangnadim_mobile/pages/loginpage.dart';
import 'package:sik_hangnadim_mobile/pages/homepage.dart';
import 'package:sik_hangnadim_mobile/utils/validators.dart';
import '../widgets/text_global.dart';
import '../widgets/button_global.dart';

class Daftar extends StatefulWidget {
  const Daftar({Key? key}) : super(key: key);

  @override
  _DaftarState createState() => _DaftarState();
}

// A small stateful widget used inside the dialog so we can track scroll
// position reliably and enable the "Saya Setuju" button only after the
// user has scrolled to the bottom.
class _TermsDialogContent extends StatefulWidget {
  const _TermsDialogContent({Key? key}) : super(key: key);

  @override
  State<_TermsDialogContent> createState() => _TermsDialogContentState();
}

class _TermsDialogContentState extends State<_TermsDialogContent> {
  final ScrollController _sc = ScrollController();
  bool _canAgree = false;

  @override
  void initState() {
    super.initState();
    _sc.addListener(() {
      if (!_canAgree && _sc.hasClients) {
        final max = _sc.position.maxScrollExtent;
        final current = _sc.position.pixels;
        // consider near-bottom as bottom (tolerance 16 px)
        if (max - current <= 16) {
          if (mounted) setState(() => _canAgree = true);
        }
      }
    });

    // In case content fits without scrolling, enable the agree button
    // after the first frame when the scroll metrics are available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_sc.hasClients) {
        final max = _sc.position.maxScrollExtent;
        final current = _sc.position.pixels;
        if (max - current <= 16) {
          if (mounted && !_canAgree) setState(() => _canAgree = true);
        }
      }
    });
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Syarat & Ketentuan'),
      content: SizedBox(
        width: double.maxFinite,
        child: Scrollbar(
          thumbVisibility: true,
          controller: _sc,
          child: SingleChildScrollView(
            controller: _sc,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Isi Ikrar Pemuda Pancasila'),
                SizedBox(height: 8),
                Text(
                  'Bertanah Air satu, Tanah Air Indonesia: Menegaskan kesetiaan pada satu-satunya tanah air, yaitu Indonesia.',
                ),
                SizedBox(height: 6),
                Text(
                  'Berbangsa Satu, Bangsa Indonesia: Menunjukkan persatuan di antara berbagai keberagaman yang ada di Indonesia.',
                ),
                SizedBox(height: 6),
                Text(
                  'Berbahasa Satu, Bahasa Indonesia: Menjadikan Bahasa Indonesia sebagai bahasa pemersatu bangsa di tengah keragaman bahasa daerah.',
                ),
                SizedBox(height: 6),
                Text(
                  'Berideologi satu, Ideologi Pancasila: Berpegang teguh pada Pancasila sebagai dasar negara dan falsafah hidup bangsa.',
                ),
                SizedBox(height: 12),
                Text('Isi Prinsip Organisasi Pemuda Pancasila'),
                SizedBox(height: 8),
                Text(
                  'Didirikan pada 28 Oktober 1959: Bertepatan dengan peringatan Sumpah Pemuda ke-31, didirikan oleh Jenderal Abdul Haris Nasution.',
                ),
                SizedBox(height: 6),
                Text(
                  'Tujuan awal: Bertujuan untuk menangkal pengaruh komunisme dan menegakkan Pancasila.',
                ),
                SizedBox(height: 6),
                Text(
                  'Prinsip "otot, omong, otak": Pada masa Orde Baru, organisasi ini mengembangkan tiga prinsip yaitu otot, omong, dan otak.',
                ),
                SizedBox(height: 6),
                Text(
                  '"Sekali Layar Terkembang, Surut Kita Berpantang": Merupakan semboyan organisasi ini, yang memiliki arti tekad untuk terus maju dan pantang mundur dalam perjuangan',
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Tutup'),
        ),
        TextButton(
          onPressed: _canAgree ? () => Navigator.of(context).pop(true) : null,
          child: const Text('Saya Setuju'),
        ),
      ],
    );
  }
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
  bool _canSubmit = false;
  //field-level errors
  String? brandError;
  String? emailError;
  String? vendorError;
  String? passwordError;
  String? confirmError;
  //track whether the user has opened/read the terms dialog
  bool hasSeenTerms = false;

  bool isPasswordStrong(String password) {
    final regex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );
    return regex.hasMatch(password);
  }

  void _updateFormState() {
    final brandName = brandNameController.text.trim();
    final email = emailController.text.trim();
    final vendorName = vendorNameController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();
    final can =
        brandName.isNotEmpty &&
        email.isNotEmpty &&
        vendorName.isNotEmpty &&
        password.isNotEmpty &&
        confirm.isNotEmpty &&
        isAgreed;
    if (can != _canSubmit) setState(() => _canSubmit = can);
  }

  /// Shows the terms dialog and returns true if the user pressed "Saya Setuju".
  /// The agree button is disabled until the user scrolls to the bottom.
  Future<bool> _showTermsDialogAsync() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _TermsDialogContent(),
    );

    final agreed = result == true;
    if (agreed) {
      //mark that the user has seen/accepted the terms
      setState(() {
        hasSeenTerms = true;
      });
    }
    return agreed;
  }

  Future<void> registerUser() async {
    final brandName = brandNameController.text.trim();
    final email = emailController.text.trim();
    final vendorName = vendorNameController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    //validasi input
    if (brandName.isEmpty ||
        email.isEmpty ||
        vendorName.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field wajib diisi!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi password tidak sama!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!isPasswordStrong(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password minimal 8 karakter, harus ada huruf besar, kecil, angka, dan simbol!',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus menyetujui Syarat & Ketentuan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final auth = AuthService();

      // Client-side format validation first
      if (!Validators.isEmailValid(email)) {
        setState(() {
          emailError = 'Format email tidak valid';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Format email tidak valid.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Ask backend whether this email exists (deliverable). We perform a
      // non-blocking check: if the check fails (network/error) we show a
      // warning but continue with registration. If the check returns false
      // (email definitely not deliverable), we block registration.
      bool emailExists = true;
      try {
        emailExists = await auth.checkEmailExists(email);
      } catch (err) {
        // Non-blocking: show warning but allow registration to continue.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Peringatan: pengecekan email gagal: ${err.toString()}',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }

      if (!emailExists) {
        setState(() {
          emailError = 'Email tidak ditemukan/tdk dapat di-deliver';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email tidak ada. Mohon periksa alamat email Anda.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Email exists or check inconclusive — proceed with registration.
      await auth.register(brandName, email, vendorName, password, confirm);

      // Treat any successful register response as success. Try to log the
      // user in automatically; if login fails, fall back to showing the
      // success message and navigate to the Login page.
      try {
        final user = await auth.login(email, password);
        // Login succeeded and token was saved by AuthService.login.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pendaftaran berhasil, masuk sebagai ${user.name}'),
            backgroundColor: Colors.green,
          ),
        );
        Future.delayed(const Duration(milliseconds: 800), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        });
      } catch (loginErr) {
        // Auto-login failed (server may require verification). Show
        // success message and redirect to Login so the user can try.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pendaftaran berhasil. Silakan login. ($loginErr)'),
            backgroundColor: Colors.green,
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
        });
      }
    } catch (e) {
      String msg = 'Terjadi kesalahan saat mendaftar';
      if (e is ApiException) {
        // If backend indicates the email is already registered, show a
        // clear, user-friendly message and set the field-level error.
        final lower = e.userMessage.toLowerCase();
        final hasEmailErrorKey =
            e.errors != null && e.errors!.containsKey('email');
        if (hasEmailErrorKey ||
            lower.contains('email') &&
                (lower.contains('already') || lower.contains('sudah'))) {
          setState(() {
            emailError = 'Email sudah ada!';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email sudah ada!'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        msg = e.userMessage;
        // map other field-level errors if present
        if (e.errors != null) {
          final errs = e.errors!;
          setState(() {
            if (errs.containsKey('name')) {
              final val = errs['name'];
              brandError = (val is List && val.isNotEmpty)
                  ? val.first.toString()
                  : val.toString();
            }
            if (errs.containsKey('email')) {
              final val = errs['email'];
              emailError = (val is List && val.isNotEmpty)
                  ? val.first.toString()
                  : val.toString();
            }
            if (errs.containsKey('vendor_name')) {
              final val = errs['vendor_name'];
              vendorError = (val is List && val.isNotEmpty)
                  ? val.first.toString()
                  : val.toString();
            }
            if (errs.containsKey('password')) {
              final val = errs['password'];
              passwordError = (val is List && val.isNotEmpty)
                  ? val.first.toString()
                  : val.toString();
            }
            if (errs.containsKey('password_confirmation')) {
              final val = errs['password_confirmation'];
              confirmError = (val is List && val.isNotEmpty)
                  ? val.first.toString()
                  : val.toString();
            }
            // some APIs return a password confirmation error under the password field
            if (confirmError == null &&
                passwordError != null &&
                passwordError!.toLowerCase().contains('confirmation')) {
              confirmError = passwordError;
              passwordError = null;
            }
          });
        }
      } else if (e is Exception) {
        // show exception message but remove verbose wrapper if present
        msg = e.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal daftar: $msg'),
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
                  error: brandError != null,
                  errorText: brandError,
                ),
                const SizedBox(height: 20),
                TextGlobal(
                  controller: emailController,
                  label: 'Email',
                  text: 'Masukkan email',
                  textInputType: TextInputType.emailAddress,
                  obscure: false,
                  error: emailError != null,
                  errorText: emailError,
                ),
                const SizedBox(height: 20),
                TextGlobal(
                  controller: vendorNameController,
                  label: 'Nama Legal Vendor',
                  text: 'Masukkan nama legal vendor',
                  textInputType: TextInputType.text,
                  obscure: false,
                  error: vendorError != null,
                  errorText: vendorError,
                ),
                const SizedBox(height: 20),
                TextGlobal(
                  controller: passwordController,
                  label: 'Password',
                  text: '********',
                  textInputType: TextInputType.text,
                  obscure: true,
                  error: passwordError != null,
                  errorText: passwordError,
                ),
                const SizedBox(height: 20),
                TextGlobal(
                  controller: confirmPasswordController,
                  label: 'Konfirmasi Password',
                  text: '********',
                  textInputType: TextInputType.text,
                  obscure: true,
                  error: confirmError != null,
                  errorText: confirmError,
                ),
                CheckboxListTile(
                  value: isAgreed,
                  onChanged: (v) async {
                    // If user is trying to check the box, ensure they open/read the terms first
                    if (v == true) {
                      if (hasSeenTerms) {
                        setState(() {
                          isAgreed = true;
                          _updateFormState();
                        });
                      } else {
                        final agreed = await _showTermsDialogAsync();
                        if (agreed) {
                          setState(() {
                            isAgreed = true;
                            hasSeenTerms = true;
                            _updateFormState();
                          });
                        } else {
                          setState(() {
                            isAgreed = false;
                            _updateFormState();
                          });
                        }
                      }
                    } else {
                      // unchecking is allowed anytime
                      setState(() {
                        isAgreed = false;
                        _updateFormState();
                      });
                    }
                  },
                  title: Row(
                    children: [
                      const Text('Saya menyetujui '),
                      GestureDetector(
                        onTap: () async {
                          final agreed = await _showTermsDialogAsync();
                          if (agreed) {
                            setState(() {
                              hasSeenTerms = true;
                              isAgreed = true;
                              _updateFormState();
                            });
                          }
                        },
                        child: const Text(
                          'Syarat & Ketentuan',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 10),
                ButtonGlobal(
                  buttonText: isLoading ? 'Memproses...' : 'Sign Up',
                  onTap: (!_canSubmit || isLoading) ? null : registerUser,
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

  @override
  void dispose() {
    brandNameController.dispose();
    emailController.dispose();
    vendorNameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
