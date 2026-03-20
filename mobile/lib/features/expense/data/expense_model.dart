class Expense {
  final String merchant;
  final double amount;
  final String category;
  final DateTime date;

  Expense({
    required this.merchant,
    required this.amount,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      "merchant": merchant,
      "amount": amount,
      "category": category,
      "date": date.toIso8601String(),
      "userId": "1"
    };
  }
}