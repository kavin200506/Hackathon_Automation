import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';

class Helpers {
  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String truncateText(String text, {int maxLength = 100}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
      case 'PAID':
      case 'COMPLETED':
        return AppTheme.success100;
      case 'INACTIVE':
        return AppTheme.gray100;
      case 'PENDING':
      case 'UNPAID':
        return AppTheme.warning100;
      case 'STARTED':
        return AppTheme.primary100;
      default:
        return AppTheme.gray100;
    }
  }

  static Color getStatusTextColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
      case 'PAID':
      case 'COMPLETED':
        return AppTheme.success700;
      case 'INACTIVE':
        return AppTheme.gray700;
      case 'PENDING':
      case 'UNPAID':
        return AppTheme.warning600;
      case 'STARTED':
        return AppTheme.primary700;
      default:
        return AppTheme.gray700;
    }
  }
}

