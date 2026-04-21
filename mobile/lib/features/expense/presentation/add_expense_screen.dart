// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'expense_provider.dart';
import '../data/expense_model.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../main.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen>
    with SingleTickerProviderStateMixin {
  final merchantController = TextEditingController();
  final amountController = TextEditingController();
  late AnimationController _fabAnimController;
  bool _showForm = false;
  int? _touchedIndex;

  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Health',
    'Others'
  ];
  String _selectedCategory = 'Food';

  static const List<Color> _chartColors = [
    Color(0xFF6C63FF),
    Color(0xFF00D4AA),
    Color(0xFFFF6B6B),
    Color(0xFFFFD93D),
    Color(0xFF4ECDC4),
    Color(0xFFFF8C42),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().fetchExpenses();
    });
  }

  @override
  void dispose() {
    merchantController.dispose();
    amountController.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  void _toggleForm() {
    setState(() => _showForm = !_showForm);
    if (_showForm) {
      _fabAnimController.forward();
    } else {
      _fabAnimController.reverse();
    }
  }

  Future<void> _submit() async {
    final merchant = merchantController.text.trim();
    final amountText = amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (merchant.isEmpty || amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields correctly'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final expense = Expense(
      merchant: merchant,
      amount: amount,
      category: _selectedCategory,
      date: DateTime.now(),
    );

    await context.read<ExpenseProvider>().addExpense(expense);

    merchantController.clear();
    amountController.clear();
    setState(() {
      _showForm = false;
      _selectedCategory = 'Food';
    });
    _fabAnimController.reverse();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Expense added!'),
          backgroundColor: const Color(0xFF6C63FF),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, dynamic id,
      String merchant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Expense'),
        content: Text('Remove "$merchant"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<ExpenseProvider>().deleteExpense(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Expense deleted'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  List<PieChartSectionData> _buildChartSections(
      Map<String, double> data, double total) {
    int i = 0;
    return data.entries.map((e) {
      final isTouched = i == _touchedIndex;
      final radius = isTouched ? 70.0 : 55.0;
      final section = PieChartSectionData(
        value: e.value,
        title: isTouched
            ? '${((e.value / total) * 100).toStringAsFixed(1)}%'
            : '',
        radius: radius,
        color: _chartColors[i % _chartColors.length],
        titleStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white),
        badgeWidget: isTouched
            ? null
            : null,
      );
      i++;
      return section;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final provider = context.watch<ExpenseProvider>();
    final _ = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F1A)
          : const Color(0xFFF8F7FF),
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor:
                isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF8F7FF),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 20, bottom: 16),
              title: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF00D4AA)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bolt,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'FinTrack',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Theme toggle
              GestureDetector(
                onTap: () => context.read<ThemeProvider>().toggle(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1E30)
                        : const Color(0xFFECEBFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        size: 16,
                        color: const Color(0xFF6C63FF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isDark ? 'Dark' : 'Light',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Body ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Summary Cards ─────────────────────────────────
                  if (!provider.isLoading && provider.expenses.isNotEmpty)
                    _SummaryRow(provider: provider, isDark: isDark),

                  const SizedBox(height: 24),

                  // ── Donut Chart ───────────────────────────────────
                  if (!provider.isLoading &&
                      provider.expenses.isNotEmpty &&
                      provider.categoryTotals.isNotEmpty)
                    _ChartCard(
                      isDark: isDark,
                      categoryTotals: provider.categoryTotals,
                      total: provider.total,
                      touchedIndex: _touchedIndex,
                      chartColors: _chartColors,
                      onTouch: (i) => setState(() => _touchedIndex = i),
                      buildSections: _buildChartSections,
                    ),

                  const SizedBox(height: 24),

                  // ── Add Expense Form ──────────────────────────────
                  AnimatedSize(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    child: _showForm
                        ? _AddExpenseCard(
                            isDark: isDark,
                            merchantController: merchantController,
                            amountController: amountController,
                            categories: _categories,
                            selectedCategory: _selectedCategory,
                            onCategoryChanged: (v) =>
                                setState(() => _selectedCategory = v!),
                            onSubmit: _submit,
                            onCancel: _toggleForm,
                          )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 24),

                  // ── Expenses Header ───────────────────────────────
                  Row(
                    children: [
                      Text(
                        'Transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A2E),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      if (!provider.isLoading)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${provider.expenses.length} items',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6C63FF),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Expense List ──────────────────────────────────
                  if (provider.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                    )
                  else if (provider.error != null)
                    Center(
                      child: Text('Error: ${provider.error}',
                          style:
                              const TextStyle(color: Colors.red)),
                    )
                  else if (provider.expenses.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 64,
                                color: isDark
                                    ? Colors.white24
                                    : Colors.black26),
                            const SizedBox(height: 12),
                            Text(
                              'No expenses yet\nTap + to add one',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white38
                                    : Colors.black38,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.expenses.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final e = provider.expenses[index];
                        final category =
                            e['category'] ?? 'Others';
                        final colorIndex =
                            _categories.indexOf(category) % _chartColors.length;
                        final color = colorIndex >= 0
                            ? _chartColors[colorIndex]
                            : _chartColors[5];

                        return _ExpenseTile(
                          expense: e,
                          color: color,
                          isDark: isDark,
                          onDelete: () => _confirmDelete(
                              context, e['id'], e['merchant'] ?? ''),
                        );
                      },
                    ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── FAB ────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleForm,
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 8,
        icon: AnimatedRotation(
          turns: _showForm ? 0.125 : 0,
          duration: const Duration(milliseconds: 300),
          child: const Icon(Icons.add),
        ),
        label: Text(
          _showForm ? 'Cancel' : 'Add Expense',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary Row
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final ExpenseProvider provider;
  final bool isDark;

  const _SummaryRow({required this.provider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Total Spent',
            value:
                '₹${provider.total.toStringAsFixed(0)}',
            icon: Icons.account_balance_wallet_outlined,
            gradient: const [Color(0xFF6C63FF), Color(0xFF9B97FF)],
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Top Category',
            value: provider.topCategory,
            icon: Icons.trending_up,
            gradient: const [Color(0xFF00D4AA), Color(0xFF00B894)],
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final List<Color> gradient;
  final bool isDark;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.9), size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chart Card
// ─────────────────────────────────────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  final bool isDark;
  final Map<String, double> categoryTotals;
  final double total;
  final int? touchedIndex;
  final List<Color> chartColors;
  final Function(int?) onTouch;
  final List<PieChartSectionData> Function(Map<String, double>, double)
      buildSections;

  const _ChartCard({
    required this.isDark,
    required this.categoryTotals,
    required this.total,
    required this.touchedIndex,
    required this.chartColors,
    required this.onTouch,
    required this.buildSections,
  });

  @override
  Widget build(BuildContext context) {
    final entries = categoryTotals.entries.toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E30) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Breakdown',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Donut chart
              SizedBox(
                height: 160,
                width: 160,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback:
                          (FlTouchEvent event, pieTouchResponse) {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          onTouch(null);
                          return;
                        }
                        onTouch(pieTouchResponse
                            .touchedSection!.touchedSectionIndex);
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 3,
                    centerSpaceRadius: 40,
                    sections: buildSections(categoryTotals, total),
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entries.asMap().entries.map((entry) {
                    final i = entry.key;
                    final e = entry.value;
                    final pct = total > 0
                        ? ((e.value / total) * 100).toStringAsFixed(1)
                        : '0';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: chartColors[i % chartColors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              e.key,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF4A4A6A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '$pct%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: chartColors[i % chartColors.length],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Expense Card
// ─────────────────────────────────────────────────────────────────────────────
class _AddExpenseCard extends StatelessWidget {
  final bool isDark;
  final TextEditingController merchantController;
  final TextEditingController amountController;
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const _AddExpenseCard({
    required this.isDark,
    required this.merchantController,
    required this.amountController,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E30) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Expense',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: merchantController,
            style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
            decoration: const InputDecoration(
              labelText: 'Merchant / Description',
              prefixIcon: Icon(Icons.store_outlined, color: Color(0xFF6C63FF)),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
            decoration: const InputDecoration(
              labelText: 'Amount (₹)',
              prefixIcon: Icon(Icons.currency_rupee, color: Color(0xFF6C63FF)),
            ),
          ),

          const SizedBox(height: 12),

          // Category selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E1E30)
                  : const Color(0xFFF0EFFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                dropdownColor:
                    isDark ? const Color(0xFF1E1E30) : Colors.white,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: Color(0xFF6C63FF)),
                items: categories.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Row(
                      children: [
                        const Icon(Icons.label_outline,
                            size: 18, color: Color(0xFF6C63FF)),
                        const SizedBox(width: 8),
                        Text(
                          c,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A1A2E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: onCategoryChanged,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save Expense',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Expense Tile
// ─────────────────────────────────────────────────────────────────────────────
class _ExpenseTile extends StatelessWidget {
  final dynamic expense;
  final Color color;
  final bool isDark;
  final VoidCallback onDelete;

  const _ExpenseTile({
    required this.expense,
    required this.color,
    required this.isDark,
    required this.onDelete,
  });

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_outlined;
      case 'Transport':
        return Icons.directions_car_outlined;
      case 'Shopping':
        return Icons.shopping_bag_outlined;
      case 'Entertainment':
        return Icons.movie_outlined;
      case 'Health':
        return Icons.favorite_outline;
      default:
        return Icons.receipt_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final merchant = expense['merchant'] ?? 'Unknown';
    final category = expense['category'] ?? 'Others';
    final amount = (expense['amount'] ?? 0).toDouble();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E30) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_iconForCategory(category), color: color, size: 22),
          ),

          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchant,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color:
                        isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(width: 8),

          // Delete
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline,
                  color: Colors.red, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}