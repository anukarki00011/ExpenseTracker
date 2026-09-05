import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: transactionProvider.isLoading
          ? const LoadingWidget()
          : transactionProvider.error != null
              ? ErrorStateWidget(message: transactionProvider.error!)
              : transactionProvider.transactions.isEmpty
                  ? const EmptyStateWidget(
                      message: 'No transactions yet',
                      icon: Icons.receipt_long,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: transactionProvider.transactions.length,
                      itemBuilder: (context, index) {
                        final tx = transactionProvider.transactions[index];
                        return TransactionCard(
                          transaction: tx,
                          onTap: () {
                            // Edit transaction (future)
                          },
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
