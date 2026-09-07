import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final bool
      isCurrency; // if false, shows plain number (e.g., transaction count)

  const SummaryCard({
    Key? key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    this.isCurrency = true, // default to currency formatting
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format the amount: if isCurrency is true, use currency format; else show integer
    final String displayAmount = isCurrency
        ? 'Rs ${amount.toStringAsFixed(2)}'
        : amount.toInt().toString();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              displayAmount,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
