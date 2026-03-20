import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'expense_provider.dart';
import '../data/expense_model.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final merchantController = TextEditingController();
  final amountController = TextEditingController();
  
  bool? get kDebugMode => null;

  void submit() async {
  final merchant = merchantController.text.trim();
  final amountText = amountController.text.trim();

  final amount = double.tryParse(amountText);

  if (amount == null) {
    return;
  }

  final expense = Expense(
    merchant: merchant,
    amount: amount,
    category: "",
    date: DateTime.now(),
  );

  await Provider.of<ExpenseProvider>(context, listen: false)
      .addExpense(expense);

  // ✅ clear safely AFTER API call
  merchantController.clear();
  amountController.clear();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense")),
      body: SingleChildScrollView(
        // 🔥 ADD THIS
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: merchantController,
                decoration: const InputDecoration(labelText: "Merchant"),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: submit, child: const Text("Save")),
            ],
          ),
        ),
      ),
    );
  }
}
