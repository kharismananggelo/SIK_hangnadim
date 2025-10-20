import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sik_hangnadim_mobile/pages/loginpage.dart';
import '../widgets/text_global.dart';
import '../widgets/button_global.dart';

class Signup extends StatefulWidget {
  Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController brandNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController vendorNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isAgreed = false;

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
                const SizedBox(height: 10,),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 50, right: 50),
                  child: Image.asset("assets/images/logo.png",
                  width: double.infinity,
                  height: 30,
                  ),
                ),
                const SizedBox(height: 20,),
                Text(
                  "Daftar Akun Anda",
                  style: TextStyle(
                    color : const Color.fromRGBO(100, 100, 100, 0.8),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 20),
                // Email input field
                TextGlobal(
                  controller: brandNameController,
                  label: 'Nama Brand',
                  text: 'Masukkan nama brand',
                  textInputType: TextInputType.emailAddress,
                  obscure: false, 
                ),

                const SizedBox(height: 25),
                // Email input field
                TextGlobal(
                  controller: emailController,
                  label: 'Email',
                  text: 'Masukkan email',
                  textInputType: TextInputType.emailAddress,
                  obscure: false, 
                ),

                const SizedBox(height: 25),
                // vendorName input field
                 TextGlobal(
                  controller: vendorNameController,
                  label: 'Nama Legal',
                  text: 'Masukkan nama legal Vendor',
                  textInputType: TextInputType.text,
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

                const SizedBox(height: 25),
                // Confirm Password field
                 TextGlobal(
                  controller: confirmPasswordController,
                  label: 'Konfirmasi Password',
                  text: '*********',
                  textInputType: TextInputType.text,
                  obscure: true, 
                ),
                const SizedBox(height: 10),

                // CHECKBOX
                CheckboxListTile(
                  value: isAgreed,
                  onChanged: (bool? value){
                    setState((){
                      isAgreed = value ?? false;
                    });
                  },
                  title: Text('Saya menyetujui Syarat & Ketentuan'),
                  controlAffinity: ListTileControlAffinity.leading, 
                ),
                const SizedBox(height: 20),

                // button
                ButtonGlobal(
                  buttonText: 'Sign Up',
                  onTap: (){
                    // Tampilkan Snackbar terlebih dahulu
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Register berhasil!'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    // Tunggu sebentar lalu navigasi
                    Future.delayed(Duration(milliseconds: 500), () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => Login())
                      );
                    });
                  },
                ),
              ],
            ),
          )
        )
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 50,
          color: Colors.white,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sudah punya akun?',
                ),
                Container(
                  margin: EdgeInsets.all(5),
                  child: InkWell(
                     onTap: ()  {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => Login()));
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color:Colors.blue
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}