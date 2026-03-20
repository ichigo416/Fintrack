import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:5000/api";

  Future<Map<String, dynamic>> addExpense(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/expenses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }
}