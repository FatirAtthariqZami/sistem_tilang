import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';
import 'dashboard_page.dart';

class LoginPage
    extends StatefulWidget {

  const LoginPage(
      {super.key});

  @override
  State<LoginPage>
  createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool isLoading=false;

  Future<void> login()
  async {

    setState(() {
      isLoading=true;
    });

    final success =
        await ApiService()
            .login(
          emailController.text,
          passwordController.text,
        );

    setState(() {
      isLoading=false;
    });

    if(success){

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:(_)=>
              const DashboardPage(),
        ),
      );

    }else{

      ScaffoldMessenger.of(
          context)
          .showSnackBar(
        const SnackBar(
          content:
          Text(
              "Login gagal"),
        ),
      );

    }

  }

  Future<void> loginWithFace()
  async {

    final picker =
        ImagePicker();

    final picked =
        await picker.pickImage(
      source:
      ImageSource.camera,
    );

    if(picked==null){
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result =
        await ApiService()
            .loginWithFace(
          File(
            picked.path,
          ),
        );

    setState(() {
      isLoading = false;
    });

    if(result!=null){

      if(!mounted)return;

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(
          builder:(_)=>
          const DashboardPage(),
        ),

      );

    }else{

      if(!mounted)return;

      ScaffoldMessenger.of(
          context)
          .showSnackBar(

        const SnackBar(
          content:
          Text(
            "Wajah tidak dikenali",
          ),
        ),

      );

    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Memberikan warna dasar yang bersih
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0), // Padding yang lebih lega
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Bagian Header/Logo ---
                const Icon(
                  Icons.gavel_rounded, // Ikon palu sidang untuk "Sistem Tilang"
                  size: 80,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Sistem Tilang",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Silakan masuk ke akun Anda",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),

                // --- Input Email ---
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 20),

                // --- Input Password ---
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 30),

                // --- Tombol Login ---
                ElevatedButton(
                  onPressed: isLoading ? null : login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Login",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 16),

                // --- Tombol Login Wajah ---
                OutlinedButton.icon(
                  onPressed: isLoading ? null : loginWithFace,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Colors.blueAccent),
                  ),
                  icon: const Icon(Icons.face_retouching_natural),
                  label: const Text(
                    "Login Dengan Wajah",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}