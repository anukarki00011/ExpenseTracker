import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'all'; // all, income, expense
  String _selectedCategory = 'all';
  String _selectedMonth = 'all'; // format: YYYY-MM

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter logic
  List<TransactionModel> _filterTransactions(List<TransactionModel> all) {
    List<TransactionModel> filtered = all;

    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered
          .where((t) =>
              t.title.toLowerCase().contains(query) ||
              (t.description?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    if (_selectedType != 'all') {
      filtered = filtered.where((t) => t.type == _selectedType).toList();
    }

    if (_selectedCategory != 'all') {
      filtered =
          filtered.where((t) => t.category == _selectedCategory).toList();
    }

    if (_selectedMonth != 'all') {
      final parts = _selectedMonth.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      filtered = filtered
          .where((t) => t.date.year == year && t.date.month == month)
          .toList();
    }

    // sort newest first
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  Future<void> _deleteTransaction(TransactionModel tx) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Delete "${tx.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      final success = await provider.deleteTransaction(tx.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Failed to delete')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final allTransactions = transactionProvider.transactions;
    final filtered = _filterTransactions(allTransactions);

    // Generate month options from existing transactions
    final monthOptions = <String>{};
    for (final tx in allTransactions) {
      final y = tx.date.year;
      final m = tx.date.month.toString().padLeft(2, '0');
      monthOptions.add('$y-$m');
    }
    final sortedMonths = monthOptions.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Type and Category filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        items: const [
                          DropdownMenuItem(
                              value: 'all', child: Text('All Types')),
                          DropdownMenuItem(
                              value: 'income', child: Text('Income')),
                          DropdownMenuItem(
                              value: 'expense', child: Text('Expense')),
                        ],
                        onChanged: (v) => setState(() => _selectedType = v!),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: [
                          const DropdownMenuItem(
                              value: 'all', child: Text('All Categories')),
                          ...AppConstants.allCategories.map((cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat))),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedCategory = v!),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Month filter
                DropdownButtonFormField<String>(
                  value: _selectedMonth,
                  items: [
                    const DropdownMenuItem(
                        value: 'all', child: Text('All Months')),
                    ...sortedMonths.map((m) => DropdownMenuItem(
                        value: m, child: Text(_formatMonthLabel(m)))),
                  ],
                  onChanged: (v) => setState(() => _selectedMonth = v!),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Transaction list
          Expanded(
            child: transactionProvider.isLoading
                ? const LoadingWidget()
                : transactionProvider.error != null
                    ? ErrorStateWidget(message: transactionProvider.error!)
                    : filtered.isEmpty
                        ? EmptyStateWidget(
                            message: 'No transactions match your filters',
                            icon: Icons.search_off,
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final tx = filtered[index];
                              return Dismissible(
                                key: Key(tx.id),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) => _deleteTransaction(tx),
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  color: Colors.red,
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                                child: TransactionCard(
                                  transaction: tx,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddTransactionScreen(
                                            transaction: tx),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatMonthLabel(String monthStr) {
    final parts = monthStr.split('-');
    final year = parts[0];
    final month = parts[1];
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final mIndex = int.parse(month) - 1;
    return '${monthNames[mIndex]} $year';
  }
}
