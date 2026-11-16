import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static const String baseUrl =
      'http://localhost:3000';

  Future<List<dynamic>> getMessages()
  async {

    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/messages',
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return [];
  }
}
