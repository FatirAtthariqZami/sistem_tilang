import 'package:flutter/material.dart';
import 'pelanggaran_form_page.dart';
import 'detail_pelanggaran_page.dart';
import 'api_service.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {

  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() =>
      _DashboardPageState();

}

class _DashboardPageState
    extends State<DashboardPage> {

  String name = "";

  int total = 0;
  int menunggu = 0;
  int diproses = 0;
  int selesai = 0;

  List pelanggaran = [];

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData()
  async {

    final profile =
        await ApiService()
            .getProfile();

    final stats =
        await ApiService()
            .getDashboardStats();

    final data =
        await ApiService()
            .getPelanggaran();

    setState(() {

      if(profile!=null){

        name =
        profile["user"]["name"];

      }

      if(stats!=null){

        total =
        stats["total"];

        menunggu =
        stats["menunggu"];

        diproses =
        stats["diproses"];

        selesai =
        stats["selesai"];

      }

      pelanggaran =
          data;

    });

  }

  Widget statCard(
      String title,
      int value){

    return Expanded(
      child: Card(
        child: Padding(
          padding:
          const EdgeInsets.all(
              16),
          child: Column(
            children: [

              Text(
                title,
                style:
                const TextStyle(
                    fontSize:16),
              ),

              const SizedBox(
                  height:10),

              Text(
                value.toString(),
                style:
                const TextStyle(
                  fontSize:24,
                  fontWeight:
                  FontWeight.bold,
                ),
              )

            ],
          ),
        ),
      ),
    );

  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title:
        const Text(
            "Sistem Tilang"),

        actions: [

          IconButton(
            onPressed:
                loadData,
            icon:
            const Icon(
                Icons.refresh),
          ),

          IconButton(
            onPressed: () async {

              await ApiService()
                  .logout();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const LoginPage(),
                ),
                    (route) => false,
              );

            },
            icon:
            const Icon(
                Icons.logout),
          )

        ],
      ),

      body: Padding(

        padding:
        const EdgeInsets.all(
            12),

        child: Column(

          children: [

            Align(
              alignment:
              Alignment.centerLeft,
              child: Text(
                "Selamat Datang, $name",
                style:
                const TextStyle(
                  fontSize:22,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(
                height:15),

            Row(
              children: [

                statCard(
                    "Total",
                    total),

                statCard(
                    "Menunggu",
                    menunggu),

              ],
            ),

            Row(
              children: [

                statCard(
                    "Diproses",
                    diproses),

                statCard(
                    "Selesai",
                    selesai),

              ],
            ),

            const SizedBox(
                height:15),

            const Align(
              alignment:
              Alignment.centerLeft,
              child: Text(
                "Daftar Pelanggaran",
                style:
                TextStyle(
                  fontSize:20,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(
                height:10),

            Expanded(
              child:
              ListView.builder(

                itemCount:
                pelanggaran.length,

                itemBuilder:
                    (context,index){

                  final item =
                  pelanggaran[index];

                  return Card(

                    child: ListTile(

                      onTap: () async {

                        await Navigator.push(

                          context,

                          MaterialPageRoute(
                            builder: (_) =>
                                DetailPelanggaranPage(
                              id: item["id"],
                            ),
                          ),

                        );

                        loadData();

                      },

                      title: Text(
                        item["nama"] ?? "",
                      ),

                      subtitle: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          Text(
                            item["plat_nomor"] ?? "",
                          ),

                          Text(
                            item["jenis_pelanggaran"] ?? "",
                          ),

                          Text(
                            "Petugas: ${item["petugas"]}",
                          ),

                          Text(
                            "Status: ${item["status"]}",
                          ),

                        ],
                      ),

                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                      ),

                    ),

                  );

                },

              ),
            )

          ],

        ),

      ),

      floatingActionButton:
      FloatingActionButton(

        child:
        const Icon(Icons.add),

        onPressed: () async {

          final result =
          await Navigator.push(

            context,

            MaterialPageRoute(
              builder: (_) =>
              const PelanggaranFormPage(),
            ),

          );

          if(result==true){

            loadData();

          }

        },

      ),

    );

  }

}