import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../data/expense_model.dart';

class ExpenseProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<dynamic> _expenses = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get total =>
      _expenses.fold(0.0, (sum, e) => sum + ((e['amount'] ?? 0).toDouble()));

  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (var e in _expenses) {
      final category = e['category'] ?? 'Others';
      final amount = (e['amount'] ?? 0).toDouble();
      totals[category] = (totals[category] ?? 0) + amount;
    }
    return totals;
  }

  String get topCategory {
    if (categoryTotals.isEmpty) return '';
    return categoryTotals.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  double get topCategoryAmount {
    if (categoryTotals.isEmpty) return 0;
    return categoryTotals.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .value;
  }

  Future<void> fetchExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expenses = await _api.getExpenses();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await _api.addExpense(expense.toJson());
      await fetchExpenses();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteExpense(dynamic id) async {
    try {
      await _api.deleteExpense(id);
      _expenses.removeWhere((e) => e['id'] == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}