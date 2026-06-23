import 'package:flutter/material.dart';

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

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
        const Text(
            "Sistem Tilang"),
      ),

      body: Padding(
        padding:
        const EdgeInsets.all(
            16),
        child: Column(

          children: [

            TextField(
              controller:
              emailController,
              decoration:
              const InputDecoration(
                labelText:
                "Email",
              ),
            ),

            const SizedBox(
                height:20),

            TextField(
              controller:
              passwordController,
              obscureText:
              true,
              decoration:
              const InputDecoration(
                labelText:
                "Password",
              ),
            ),

            const SizedBox(
                height:20),

            ElevatedButton(
              onPressed:
              isLoading
                  ? null
                  : login,
              child:
              const Text(
                  "Login"),
            )

          ],
        ),
      ),
    );
  }
}