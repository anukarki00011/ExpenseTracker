import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get collection reference for a user's transactions
  CollectionReference _collection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions');
  }

  // Add a new transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    await _collection(transaction.userId)
        .doc(transaction.id)
        .set(transaction.toMap());
  }

  // Update an existing transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _collection(transaction.userId)
        .doc(transaction.id)
        .update(transaction.toMap());
  }

  // Delete a transaction
  Future<void> deleteTransaction(String userId, String transactionId) async {
    await _collection(userId).doc(transactionId).delete();
  }

  // Get all transactions for a user
  Stream<List<TransactionModel>> getTransactions(String userId) {
    return _collection(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              TransactionModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

// Get transactions for a specific month (optional - can be done in provider)
}
