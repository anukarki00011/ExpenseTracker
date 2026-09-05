class TransactionModel {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String type; // 'income' or 'expense'
  final String category;
  final String? description;
  final DateTime date;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    this.description,
    required this.date,
    required this.createdAt,
  });
}
