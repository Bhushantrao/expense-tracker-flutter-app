import 'package:intl/intl.dart';

class CurrencyHelper {
  static final Map<String, String> supportedCurrencies = {
    'INR': '₹',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CAD': 'CA\$',
    'AUD': 'A\$',
    'AED': 'AED',
  };

  static String format(double amount, {String symbol = '₹', bool showDecimals = true}) {
    final formatter = NumberFormat(
      showDecimals ? '#,##0.00' : '#,##0',
      'en_US',
    );
    return '$symbol ${formatter.format(amount)}';
  }

  static String formatCompact(double amount, {String symbol = '₹'}) {
    if (amount >= 1000000) {
      return '$symbol ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol ${(amount / 1000).toStringAsFixed(1)}k';
    }
    return '$symbol ${amount.toStringAsFixed(0)}';
  }
}
