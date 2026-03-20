import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../data/expense_model.dart';

class ExpenseProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  Future<void> addExpense(Expense expense) async {
    await _api.addExpense(expense.toJson());
  }
}