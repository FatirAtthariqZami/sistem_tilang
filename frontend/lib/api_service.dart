import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

}