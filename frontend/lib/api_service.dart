import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ApiService {

  static const String baseUrl =
      "http://192.168.18.10:3000";

  Future<bool> login(
      String email,
      String password) async {

    final response =
        await http.post(
      Uri.parse(
          "$baseUrl/login"),
      headers: {
        "Content-Type":
            "application/json"
      },
      body: jsonEncode({
        "email": email,
        "password": password
      }),
    );

    if (response.statusCode == 200) {

      final data =
          jsonDecode(response.body);

      SharedPreferences prefs =
          await SharedPreferences
              .getInstance();

      await prefs.setString(
          "token",
          data["token"]);

      return true;
    }

    return false;
  }

  Future<String?> getToken()
  async {

    SharedPreferences prefs =
        await SharedPreferences
            .getInstance();

    return prefs.getString(
        "token");
  }

  Future<Map<String,dynamic>?>
  getProfile() async {

    final token =
        await getToken();

    if(token==null){
      return null;
    }

    final response =
        await http.get(
      Uri.parse(
          "$baseUrl/me"),
      headers: {
        "Authorization":
            "Bearer $token"
      },
    );

    if(response.statusCode==200){

      return jsonDecode(
          response.body);

    }

    return null;
  }

  Future<void> logout()
  async {

    SharedPreferences prefs =
        await SharedPreferences
            .getInstance();

    await prefs.clear();

  }

  Future<Map<String, dynamic>?> getDashboardStats() async {

    final token = await getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/dashboard/stats"),
      headers: {
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }

  Future<List<dynamic>> getPelanggaran() async {

    final token = await getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/pelanggaran"),
      headers: {
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {

      return jsonDecode(response.body);

    }

    return [];
  }

  Future<bool> savePelanggaran({
    required String nama,
    required String nik,
    required String platNomor,
    required String kendaraan,
    required String jenisPelanggaran,
    required String lokasi,
    required String status,
    File? foto,
  }) async {

    final token = await getToken();

    var request =
        http.MultipartRequest(
      "POST",
      Uri.parse(
        "$baseUrl/pelanggaran",
      ),
    );

    request.headers[
        "Authorization"] =
        "Bearer $token";

    request.fields["nama"] = nama;
    request.fields["nik"] = nik;
    request.fields["plat_nomor"] =
        platNomor;
    request.fields["kendaraan"] =
        kendaraan;
    request.fields[
        "jenis_pelanggaran"] =
        jenisPelanggaran;
    request.fields["lokasi"] =
        lokasi;
    request.fields["status"] =
        status;

    if (foto != null) {

      request.files.add(
        await http.MultipartFile
            .fromPath(
          "foto",
          foto.path,
        ),
      );

    }

    final response =
        await request.send();

    return response.statusCode ==
        201;
  }

  Future<bool> deletePelanggaran(
      int id) async {

    final token =
        await getToken();

    final response =
        await http.delete(
      Uri.parse(
        "$baseUrl/pelanggaran/$id",
      ),
      headers: {
        "Authorization":
            "Bearer $token"
      },
    );

    return response.statusCode ==
            200;
  }

  Future<Map<String,dynamic>?>
  getDetailPelanggaran(
      int id) async {

    final token =
        await getToken();

    final response =
        await http.get(
      Uri.parse(
        "$baseUrl/pelanggaran/$id",
      ),
      headers: {
        "Authorization":
            "Bearer $token"
      },
    );

    if(response.statusCode==200){

      return jsonDecode(
          response.body);

    }

    return null;
  }

  Future<bool> updatePelanggaran({
    required int id,
    required String nama,
    required String nik,
    required String platNomor,
    required String kendaraan,
    required String jenisPelanggaran,
    required String lokasi,
    required String status,
    File? foto,
  }) async {

    final token =
        await getToken();

    var request =
        http.MultipartRequest(
      "PUT",
      Uri.parse(
        "$baseUrl/pelanggaran/$id",
      ),
    );

    request.headers[
        "Authorization"] =
        "Bearer $token";

    request.fields["nama"] =
        nama;

    request.fields["nik"] =
        nik;

    request.fields["plat_nomor"] =
        platNomor;

    request.fields["kendaraan"] =
        kendaraan;

    request.fields[
        "jenis_pelanggaran"] =
        jenisPelanggaran;

    request.fields["lokasi"] =
        lokasi;

    request.fields["status"] =
        status;

    if(foto!=null){

      request.files.add(
        await http.MultipartFile
            .fromPath(
          "foto",
          foto.path,
        ),
      );

    }

    final response =
        await request.send();

    return response.statusCode ==
        200;
  }

  Future<Map<String,dynamic>?> loginWithFace(
      File image) async {

    var request =
        http.MultipartRequest(
      "POST",
      Uri.parse(
        "http://192.168.18.10:5000/recognize-face",
      ),
    );

    request.files.add(

      await http.MultipartFile
          .fromPath(
        "image",
        image.path,
      ),

    );

    final response =
        await request.send();

    if(response.statusCode==200){

      final responseBody =
          await response.stream
              .bytesToString();

      final data =
          jsonDecode(
              responseBody);

      SharedPreferences prefs =
          await SharedPreferences
              .getInstance();

      await prefs.setString(
        "token",
        data["token"],
      );

      return data;

    }

    return null;
  }

  Future<String> askChatbot(
      String message) async {

    try {

      final response =
          await http.post(

        Uri.parse(
          "http://192.168.18.10:8000/chat",
        ),

        headers: {
          "Content-Type":
          "application/json",
        },

        body: jsonEncode({
          "message": message,
        }),

      );

      if(response.statusCode==200){

        final data =
            jsonDecode(
                response.body);

        return data["response"];

      }

      return "Maaf, saya tidak dapat memproses pertanyaan Anda.";

    } catch (e) {

      return "Gagal terhubung ke server NLP.";

    }

  }

}