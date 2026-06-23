import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'api_service.dart';

class PelanggaranFormPage extends StatefulWidget {

  final Map<String, dynamic>? editData;

  const PelanggaranFormPage({
    super.key,
    this.editData,
  });

  @override
  State<PelanggaranFormPage> createState() =>
      _PelanggaranFormPageState();
}

class _PelanggaranFormPageState
    extends State<PelanggaranFormPage> {

  final namaController =
      TextEditingController();

  final nikController =
      TextEditingController();

  final platController =
      TextEditingController();

  final kendaraanController =
      TextEditingController();

  final jenisController =
      TextEditingController();

  final lokasiController =
      TextEditingController();

  String selectedStatus = "Menunggu";

  File? image;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    if (widget.editData != null) {

      namaController.text =
          widget.editData!["nama"] ?? "";

      nikController.text =
          widget.editData!["nik"] ?? "";

      platController.text =
          widget.editData!["plat_nomor"] ?? "";

      kendaraanController.text =
          widget.editData!["kendaraan"] ?? "";

      jenisController.text =
          widget.editData!["jenis_pelanggaran"] ?? "";

      lokasiController.text =
          widget.editData!["lokasi"] ?? "";

      selectedStatus =
        widget.editData!["status"] ??
        "Menunggu";
    }
  }

  Future<void> pickImage() async {

    final picker =
        ImagePicker();

    final picked =
        await picker.pickImage(
      source: ImageSource.camera,
    );

    if (picked != null) {

      setState(() {

        image =
            File(picked.path);

      });

    }

  }

  Future<void> saveData() async {

    setState(() {
      loading = true;
    });

    bool success;

    if (widget.editData == null) {

      success =
          await ApiService()
              .savePelanggaran(

        nama:
        namaController.text,

        nik:
        nikController.text,

        platNomor:
        platController.text,

        kendaraan:
        kendaraanController.text,

        jenisPelanggaran:
        jenisController.text,

        lokasi:
        lokasiController.text,

        status:
        selectedStatus,

        foto:
        image,

      );

    } else {

      success =
          await ApiService()
              .updatePelanggaran(

        id:
        widget.editData!["id"],

        nama:
        namaController.text,

        nik:
        nikController.text,

        platNomor:
        platController.text,

        kendaraan:
        kendaraanController.text,

        jenisPelanggaran:
        jenisController.text,

        lokasi:
        lokasiController.text,

        status:
        selectedStatus,

        foto:
        image,

      );

    }

    setState(() {
      loading = false;
    });

    if (success) {

      if (!mounted) return;

      Navigator.pop(
          context,
          true);

    } else {

      ScaffoldMessenger.of(
          context)
          .showSnackBar(
        const SnackBar(
          content: Text(
              "Gagal menyimpan"),
        ),
      );

    }

  }

  Widget field(
      TextEditingController controller,
      String label) {

    return Padding(

      padding:
      const EdgeInsets.only(
          bottom: 10),

      child: TextField(

        controller:
        controller,

        decoration:
        InputDecoration(

          labelText:
          label,

          border:
          const OutlineInputBorder(),

        ),

      ),

    );

  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(

          widget.editData == null
              ? "Tambah Tilang"
              : "Edit Tilang",

        ),

      ),

      body:
      SingleChildScrollView(

        padding:
        const EdgeInsets.all(
            16),

        child: Column(

          children: [

            field(
              namaController,
              "Nama",
            ),

            field(
              nikController,
              "NIK",
            ),

            field(
              platController,
              "Plat Nomor",
            ),

            field(
              kendaraanController,
              "Kendaraan",
            ),

            field(
              jenisController,
              "Jenis Pelanggaran",
            ),

            field(
              lokasiController,
              "Lokasi",
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(

              value: selectedStatus,

              decoration:
              const InputDecoration(
                labelText: "Status",
                border:
                OutlineInputBorder(),
              ),

              items: const [

                DropdownMenuItem(
                  value: "Menunggu",
                  child: Text(
                    "Menunggu",
                  ),
                ),

                DropdownMenuItem(
                  value: "Diproses",
                  child: Text(
                    "Diproses",
                  ),
                ),

                DropdownMenuItem(
                  value: "Selesai",
                  child: Text(
                    "Selesai",
                  ),
                ),

              ],

              onChanged: (value) {

                setState(() {

                  selectedStatus =
                      value!;

                });

              },

            ),

            const SizedBox(
                height: 10),

            ElevatedButton.icon(

              onPressed:
              pickImage,

              icon:
              const Icon(
                  Icons.camera_alt),

              label:
              const Text(
                  "Ambil Foto"),

            ),

            const SizedBox(
                height: 10),

            if (image != null)

              Image.file(
                image!,
                height: 200,
              ),

            const SizedBox(
                height: 20),

            SizedBox(

              width:
              double.infinity,

              child:
              ElevatedButton(

                onPressed:
                loading
                    ? null
                    : saveData,

                child: Text(

                  widget.editData ==
                      null
                      ? "Simpan"
                      : "Update",

                ),

              ),

            )

          ],

        ),

      ),

    );

  }
}