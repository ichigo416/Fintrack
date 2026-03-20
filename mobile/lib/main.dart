import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/expense/presentation/expense_provider.dart';
import 'features/expense/presentation/add_expense_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FinTrack',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AddExpenseScreen(), // 👈 your main screen
      ),
    );
  }
}