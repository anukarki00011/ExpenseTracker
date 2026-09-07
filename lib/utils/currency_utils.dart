import 'package:intl/intl.dart';

class CurrencyUtils {
  static String format(double amount) {
    final format = NumberFormat.currency(symbol: 'Rs', decimalDigits: 2);
    return format.format(amount);
  }
}
