import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sik_hangnadim_mobile/widgets/social.dart';
import '../widgets/text_global.dart';
import '../widgets/button_global.dart';
import 'signuppage.dart';

class Login extends StatelessWidget {
  Login({Key? key}) : super(key: key);
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
                  margin: EdgeInsets.only(left: 70, right: 70),
                  child: Image.asset(
                    "assets/images/logo.png",
                    width: double.infinity,
                    height: 120,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  "Login ke akun anda",
                  style: TextStyle(
                    color: const Color.fromRGBO(100, 100, 100, 0.8),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
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
                ),

                const SizedBox(height: 25),
                // Password input field
                TextGlobal(
                  controller: passwordController,
                  label: 'Password',
                  text: '*********',
                  textInputType: TextInputType.text,
                  obscure: true,
                ),
                const SizedBox(height: 40),
                //login button
                ButtonGlobal(
                  buttonText: 'Login',
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  },
                ),
                const SizedBox(height: 70),
                SocialLogin(),
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
              Text('Belum punya akun?'),
              Container(
                margin: EdgeInsets.all(5),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Signup()),
                    );
                  },
                  child: Text('Sign up', style: TextStyle(color: Colors.blue)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
