import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_utils.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/summary_card.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    // If no transactions at all, show empty state
    if (provider.transactions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Statistics')),
        body: const EmptyStateWidget(
          message: 'No transactions yet. Add some to see statistics!',
          icon: Icons.pie_chart_outline,
        ),
      );
    }

    final monthTx = provider.currentMonthTransactions;

    // Expense breakdown by category for current month
    final expenseByCategory = <String, double>{};
    for (final tx in monthTx.where((t) => t.type == 'expense')) {
      expenseByCategory[tx.category] =
          (expenseByCategory[tx.category] ?? 0) + tx.amount;
    }

    final totalExpense =
        expenseByCategory.values.fold(0.0, (sum, v) => sum + v);
    final pieSections = expenseByCategory.entries.map((entry) {
      final percent = totalExpense > 0 ? (entry.value / totalExpense) * 100 : 0;
      return PieChartSectionData(
        value: entry.value,
        title: '${percent.toStringAsFixed(1)}%',
        radius: 80,
        color: _getCategoryColor(entry.key),
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Monthly summary cards
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Income',
                    amount: provider.monthlyIncome,
                    icon: Icons.arrow_upward,
                    color: AppColors.income,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    title: 'Expense',
                    amount: provider.monthlyExpense,
                    icon: Icons.arrow_downward,
                    color: AppColors.expense,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Balance',
                    amount: provider.monthlyBalance,
                    icon: Icons.account_balance_wallet,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    title: 'Transactions',
                    amount: monthTx.length.toDouble(),
                    icon: Icons.receipt_long,
                    color: AppColors.secondary,
                    isCurrency: false, //  Show plain number, not currency
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Expense breakdown
            const Text(
              'Expense Breakdown (This Month)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (totalExpense == 0)
              const Center(child: Text('No expenses this month'))
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: pieSections,
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...expenseByCategory.entries.map((entry) {
                        final percent = totalExpense > 0
                            ? (entry.value / totalExpense) * 100
                            : 0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(entry.key),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(entry.key)),
                              Text(
                                '${CurrencyUtils.format(entry.value)} (${percent.toStringAsFixed(1)}%)',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),
            // Income vs Expense (all time) bar chart
            const Text(
              'Income vs Expense (All Time)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (provider.totalIncome > provider.totalExpense
                              ? provider.totalIncome
                              : provider.totalExpense) *
                          1.2,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text('Income'),
                                  );
                                case 1:
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text('Expense'),
                                  );
                                default:
                                  return const SizedBox();
                              }
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: _calculateInterval(
                                provider.totalIncome, provider.totalExpense),
                            getTitlesWidget: (value, meta) {
                              if (value == 0) return const SizedBox();
                              return Text(
                                NumberFormat.compact().format(value),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: provider.totalIncome,
                              color: AppColors.income,
                              width: 40,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: provider.totalExpense,
                              color: AppColors.expense,
                              width: 40,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateInterval(double income, double expense) {
    double maxVal = income > expense ? income : expense;
    if (maxVal <= 0) return 1;
    double rawInterval = maxVal / 4;
    double magnitude = 1;
    while (rawInterval / magnitude >= 10) {
      magnitude *= 10;
    }
    double normalized = rawInterval / magnitude;
    if (normalized <= 1) {
      rawInterval = magnitude;
    } else if (normalized <= 2) {
      rawInterval = 2 * magnitude;
    } else if (normalized <= 5) {
      rawInterval = 5 * magnitude;
    } else {
      rawInterval = 10 * magnitude;
    }
    return rawInterval;
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.orange;
      case 'Transport':
        return Colors.blue;
      case 'Shopping':
        return Colors.purple;
      case 'Bills':
        return Colors.teal;
      case 'Entertainment':
        return Colors.pink;
      case 'Health':
        return Colors.green;
      case 'Education':
        return Colors.indigo;
      case 'Salary':
        return Colors.lightGreen;
      case 'Freelance':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }
}
