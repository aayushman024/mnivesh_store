import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/appModel.dart';

class ApiService {
  static const String baseUrl = "http://192.168.31.37:5000/api";

  Future<List<AppModel>> fetchApps() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/getApps'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => AppModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load apps: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }
}