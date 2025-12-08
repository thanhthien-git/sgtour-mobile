import 'package:intl/intl.dart';

/// Formatter utility for displaying data in user-friendly formats
class Formatters {
  // Format currency
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  // Format date
  static String formatDate(DateTime date, {String format = 'MMM dd, yyyy'}) {
    return DateFormat(format).format(date);
  }

  // Format time
  static String formatTime(DateTime time, {String format = 'HH:mm'}) {
    return DateFormat(format).format(time);
  }

  // Format date and time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }

  // Format phone number
  static String formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[\D]'), '');
    if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    } else if (cleaned.length == 11) {
      return '+${cleaned.substring(0, 1)} (${cleaned.substring(1, 4)}) ${cleaned.substring(4, 7)}-${cleaned.substring(7)}';
    }
    return phone;
  }

  // Format number with commas
  static String formatNumber(num number) {
    return NumberFormat('#,##0.##').format(number);
  }

  // Format percentage
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  // Shorten text with ellipsis
  static String truncateText(String text, int length) {
    return text.length > length ? '${text.substring(0, length)}...' : text;
  }

  // Format duration (e.g., 1h 30m)
  static String formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    
    if (hours == 0) {
      return '${minutes}m';
    } else if (minutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${minutes}m';
  }
}
