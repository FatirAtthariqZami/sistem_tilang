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
  Widget build(BuildContext context) {
    final isEdit = widget.editData != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          isEdit ? "Edit Data Tilang" : "Tambah Data Tilang",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Bagian Informasi Pelanggar ---
            const Text(
              "Informasi Pelanggar",
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField(namaController, "Nama Lengkap", Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField(nikController, "NIK", Icons.badge_outlined, isNumber: true),
            const SizedBox(height: 24),

            // --- Bagian Informasi Kendaraan & Lokasi ---
            const Text(
              "Data Kendaraan & Pelanggaran",
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            // Meletakkan Plat Nomor dan Kendaraan bersebelahan agar menghemat ruang
            Row(
              children: [
                Expanded(
                  child: _buildTextField(platController, "Plat Nomor", Icons.directions_car_outlined),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(kendaraanController, "Kendaraan", Icons.two_wheeler_outlined),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(jenisController, "Jenis Pelanggaran", Icons.warning_amber_rounded),
            const SizedBox(height: 16),
            _buildTextField(lokasiController, "Lokasi Kejadian", Icons.location_on_outlined),
            const SizedBox(height: 16),

            // --- Status Dropdown ---
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: InputDecoration(
                labelText: "Status Proses",
                prefixIcon: const Icon(Icons.pending_actions),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: const [
                DropdownMenuItem(value: "Menunggu", child: Text("Menunggu")),
                DropdownMenuItem(value: "Diproses", child: Text("Diproses")),
                DropdownMenuItem(value: "Selesai", child: Text("Selesai")),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedStatus = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // --- Bagian Foto Bukti ---
            const Text(
              "Foto Bukti Pelanggaran",
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  // Memberikan bingkai putus-putus atau solid ringan
                  border: Border.all(color: Colors.grey.shade400, width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(
                          image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, size: 48, color: Colors.blue[300]),
                          const SizedBox(height: 12),
                          const Text(
                            "Tap untuk mengambil foto",
                            style: TextStyle(
                              color: Colors.black54, 
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),

            // --- Tombol Simpan ---
            ElevatedButton(
              onPressed: loading ? null : saveData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isEdit ? "Update Data" : "Simpan Data",
                      style: const TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Tambahkan widget helper ini di dalam class State Anda
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}