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
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title:
        const Text(
            "Detail Tilang"),

        actions: [

          IconButton(

            icon:
            const Icon(Icons.edit),

            onPressed: () async {

              final result =
              await Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_) =>
                      PelanggaranFormPage(
                        editData: data,
                      ),

                ),

              );

              if(result==true){

                loadData();

              }

            },

          ),

          IconButton(

            icon:
            const Icon(Icons.delete),

            onPressed:
            deleteData,

          ),

        ],

      ),

      body: loading

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : SingleChildScrollView(

        padding:
        const EdgeInsets.all(
            16),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment
              .start,

          children: [

            buildItem(
              "Nomor Tilang",
              data![
              "nomor_tilang"],
            ),

            buildItem(
              "Nama",
              data!["nama"],
            ),

            buildItem(
              "NIK",
              data!["nik"],
            ),

            buildItem(
              "Plat Nomor",
              data![
              "plat_nomor"],
            ),

            buildItem(
              "Kendaraan",
              data![
              "kendaraan"],
            ),

            buildItem(
              "Jenis Pelanggaran",
              data![
              "jenis_pelanggaran"],
            ),

            buildItem(
              "Lokasi",
              data![
              "lokasi"],
            ),

            buildItem(
              "Status",
              data![
              "status"],
            ),

            buildItem(
              "Dibuat Oleh",
              data![
              "dibuat_oleh"],
            ),

            buildItem(
              "Diubah Oleh",
              data![
              "diubah_oleh"],
            ),

            if (data![
            "foto_url"] !=
                null)

              Column(

                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [

                  const Text(

                    "Foto Bukti",

                    style:
                    TextStyle(
                      fontWeight:
                      FontWeight
                          .bold,
                    ),

                  ),

                  const SizedBox(
                      height: 10),

                  Image.network(
                    data![
                    "foto_url"],
                    height: 250,
                  ),

                ],

              ),

          ],

        ),

      ),

    );

  }

}