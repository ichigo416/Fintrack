import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    } else {
      // Android emulator needs 10.0.2.2 to reach host machine's localhost
      return 'http://10.0.2.2:5000/api';
    }
  }

  // ADD EXPENSE
  Future<Map<String, dynamic>> addExpense(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/expenses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add expense: ${response.body}');
    }
  }

  // GET ALL EXPENSES
  Future<List<dynamic>> getExpenses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/expenses'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load expenses: ${response.body}');
    }
  }

  // DELETE EXPENSE
  Future<void> deleteExpense(dynamic id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/expenses/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete expense: ${response.body}');
    }
  }
}