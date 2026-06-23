import 'package:flutter/material.dart';
import 'pelanggaran_form_page.dart';
import 'api_service.dart';

class DetailPelanggaranPage extends StatefulWidget {

  final int id;

  const DetailPelanggaranPage({
    super.key,
    required this.id,
  });

  @override
  State<DetailPelanggaranPage> createState() =>
      _DetailPelanggaranPageState();
}

class _DetailPelanggaranPageState
    extends State<DetailPelanggaranPage> {

  Map<String, dynamic>? data;

  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {

    final result =
        await ApiService()
            .getDetailPelanggaran(
        widget.id);

    setState(() {

      data = result;

      loading = false;

    });

  }

  Future<void> deleteData() async {

    final confirm =
    await showDialog<bool>(

      context: context,

      builder: (context) {

        return AlertDialog(

          title:
          const Text(
              "Konfirmasi"),

          content:
          const Text(
              "Hapus data ini?"),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(
                    context,
                    false);

              },

              child:
              const Text(
                  "Batal"),

            ),

            TextButton(

              onPressed: () {

                Navigator.pop(
                    context,
                    true);

              },

              child:
              const Text(
                "Hapus",
                style:
                TextStyle(
                    color:
                    Colors.red),
              ),

            ),

          ],

        );

      },

    );

    if (confirm != true) {
      return;
    }

    bool success =
    await ApiService()
        .deletePelanggaran(
        widget.id);

    if (success) {

      if (!mounted) return;

      Navigator.pop(
          context,
          true);

    }

  }

  Widget buildItem(
      String title,
      dynamic value) {

    return Padding(

      padding:
      const EdgeInsets.only(
          bottom: 12),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(

            title,

            style:
            const TextStyle(
              fontWeight:
              FontWeight.bold,
            ),

          ),

          const SizedBox(
              height: 4),

          Text(
            value?.toString() ??
                "-",
          ),

        ],

      ),

    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Latar belakang yang lembut
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          "Detail Tilang",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent),
            tooltip: "Edit Data",
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PelanggaranFormPage(
                    editData: data,
                  ),
                ),
              );
              if (result == true) {
                loadData();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            tooltip: "Hapus Data",
            onPressed: deleteData,
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Kartu Informasi Detail ---
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailItem("Nomor Tilang", data!["nomor_tilang"]),
                          const Divider(height: 16), // Garis pemisah tipis
                          _buildDetailItem("Nama", data!["nama"]),
                          const Divider(height: 16),
                          _buildDetailItem("NIK", data!["nik"]),
                          const Divider(height: 16),
                          _buildDetailItem("Plat Nomor", data!["plat_nomor"]),
                          const Divider(height: 16),
                          _buildDetailItem("Kendaraan", data!["kendaraan"]),
                          const Divider(height: 16),
                          _buildDetailItem("Jenis Pelanggaran", data!["jenis_pelanggaran"]),
                          const Divider(height: 16),
                          _buildDetailItem("Lokasi", data!["lokasi"]),
                          const Divider(height: 16),
                          _buildDetailItem("Status", data!["status"], isStatus: true),
                          const Divider(height: 16),
                          _buildDetailItem("Dibuat Oleh", data!["dibuat_oleh"]),
                          const Divider(height: 16),
                          _buildDetailItem("Diubah Oleh", data!["diubah_oleh"]),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // --- Bagian Foto Bukti ---
                  if (data!["foto_url"] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: Text(
                            "Foto Bukti",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              data!["foto_url"],
                              height: 250,
                              fit: BoxFit.cover,
                              // Fallback jika gambar gagal dimuat
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 250,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image_rounded,
                                      color: Colors.grey,
                                      size: 50,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  // Tambahkan fungsi helper ini di dalam class State Anda untuk merapikan layout teks
  Widget _buildDetailItem(String label, dynamic value, {bool isStatus = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: isStatus
              ? Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      value?.toString() ?? "-",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                )
              : Text(
                  value?.toString() ?? "-",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
        ),
      ],
    );
  }

}