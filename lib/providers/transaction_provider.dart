import 'dart:async'; // <-- Add this import
import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import 'auth_provider.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  AuthProvider? authProvider;

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Correct type: StreamSubscription, not Stream
  StreamSubscription<List<TransactionModel>>? _transactionSubscription;

  TransactionProvider({this.authProvider}) {
    if (authProvider?.user != null) {
      _listenToTransactions(authProvider!.user!.uid);
    }
  }

  void updateUser(String? userId) {
    _transactionSubscription?.cancel();
    _transactions = [];
    if (userId != null) {
      _listenToTransactions(userId);
    }
    notifyListeners();
  }

  void _listenToTransactions(String userId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _transactionSubscription =
        _transactionService.getTransactions(userId).listen(
      (transactions) {
        _transactions = transactions;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Failed to load transactions: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> addTransaction(TransactionModel transaction) async {
    try {
      await _transactionService.addTransaction(transaction);
      return true;
    } catch (e) {
      _error = 'Failed to add transaction: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction(TransactionModel transaction) async {
    try {
      await _transactionService.updateTransaction(transaction);
      return true;
    } catch (e) {
      _error = 'Failed to update transaction: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(String transactionId) async {
    final userId = authProvider?.user?.uid;
    if (userId == null) return false;
    try {
      await _transactionService.deleteTransaction(userId, transactionId);
      return true;
    } catch (e) {
      _error = 'Failed to delete transaction: $e';
      notifyListeners();
      return false;
    }
  }

  List<TransactionModel> get currentMonthTransactions {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .toList();
  }

  double get totalIncome {
    return _transactions
        .where((t) => t.type == 'income')
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => t.type == 'expense')
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get totalBalance => totalIncome - totalExpense;

  double get monthlyIncome {
    return currentMonthTransactions
        .where((t) => t.type == 'income')
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get monthlyExpense {
    return currentMonthTransactions
        .where((t) => t.type == 'expense')
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get monthlyBalance => monthlyIncome - monthlyExpense;

  List<TransactionModel> get recentTransactions {
    final sorted = [..._transactions]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  @override
  void dispose() {
    _transactionSubscription?.cancel();
    super.dispose();
  }
}
