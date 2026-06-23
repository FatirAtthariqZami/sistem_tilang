import 'package:flutter/material.dart';

import 'api_service.dart';
import 'login_page.dart';

class DashboardPage
    extends StatefulWidget {

  const DashboardPage(
      {super.key});

  @override
  State<DashboardPage>
  createState() =>
      _DashboardPageState();
}

class _DashboardPageState
    extends State<DashboardPage> {

  String name="";

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile()
  async {

    final data =
        await ApiService()
            .getProfile();

    if(data!=null){

      setState(() {

        name =
        data["user"]
        ["name"];

      });

    }

  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title:
        const Text(
            "Dashboard"),

        actions: [

          IconButton(
            onPressed: () async {

              await ApiService()
                  .logout();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder:(_)=>
                  const LoginPage(),
                ),
                    (route)=>false,
              );

            },
            icon:
            const Icon(
                Icons.logout),
          )

        ],
      ),

      body: Center(
        child: Text(
          "Selamat Datang $name",
          style:
          const TextStyle(
            fontSize:22,
          ),
        ),
      ),
    );
  }
}