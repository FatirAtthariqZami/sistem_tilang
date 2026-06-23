import 'package:flutter/material.dart';
import 'pelanggaran_form_page.dart';
import 'detail_pelanggaran_page.dart';
import 'api_service.dart';
import 'login_page.dart';
import 'chat_page.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Latar belakang abu-abu sangat muda agar kartu lebih menonjol
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          "Sistem Tilang",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined, color: Colors.blueAccent),
            tooltip: "Chat Bot",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatPage()),
              );
            },
          ),
          IconButton(
            onPressed: loadData,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh Data",
          ),
          IconButton(
            onPressed: () async {
              await ApiService().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: "Logout",
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Bagian Sambutan ---
            Text(
              "Selamat Datang,",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              name ?? "Petugas",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // --- Bagian Statistik ---
            Row(
              children: [
                Expanded(child: _buildStatCard("Total", total, Icons.analytics, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard("Menunggu", menunggu, Icons.pending_actions, Colors.orange)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard("Diproses", diproses, Icons.autorenew, Colors.purple)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard("Selesai", selesai, Icons.check_circle_outline, Colors.green)),
              ],
            ),
            const SizedBox(height: 24),

            // --- Judul Daftar ---
            const Text(
              "Daftar Pelanggaran",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // --- Daftar Pelanggaran ---
            Expanded(
              child: pelanggaran.isEmpty
                  ? Center(
                      child: Text(
                        "Belum ada data pelanggaran.",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: pelanggaran.length,
                      itemBuilder: (context, index) {
                        final item = pelanggaran[index];
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailPelanggaranPage(
                                    id: item["id"],
                                  ),
                                ),
                              );
                              loadData();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Ikon List
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.receipt_long, color: Colors.blue),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Informasi Pelanggaran
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item["nama"] ?? "Tanpa Nama",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${item["plat_nomor"] ?? "-"} • ${item["jenis_pelanggaran"] ?? "-"}",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Petugas: ${item["petugas"] ?? "-"}",
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Status dan Panah
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          item["status"] ?? "Unknown",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Icon(Icons.chevron_right, color: Colors.grey),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PelanggaranFormPage(),
            ),
          );
          if (result == true) {
            loadData();
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Data", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // Tambahkan widget helper ini di dalam class State Anda
  Widget _buildStatCard(String title, dynamic count, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color.shade600, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count?.toString() ?? "0",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}