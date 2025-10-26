import 'package:intl/intl.dart';

class DateFormatter {
  // Date formats
  static const String _defaultDateFormat = 'dd/MM/yyyy';
  static const String _defaultTimeFormat = 'HH:mm';
  static const String _defaultDateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String _apiDateFormat = 'yyyy-MM-ddTHH:mm:ss.SSSZ';
  
  /// Format date to string using default format
  static String formatDate(DateTime date, {String? format}) {
    final formatter = DateFormat(format ?? _defaultDateFormat, 'fr_FR');
    return formatter.format(date);
  }
  
  /// Format time to string using default format
  static String formatTime(DateTime date, {String? format}) {
    final formatter = DateFormat(format ?? _defaultTimeFormat, 'fr_FR');
    return formatter.format(date);
  }
  
  /// Format datetime to string using default format
  static String formatDateTime(DateTime date, {String? format}) {
    final formatter = DateFormat(format ?? _defaultDateTimeFormat, 'fr_FR');
    return formatter.format(date);
  }
  
  /// Format date for API consumption
  static String formatForApi(DateTime date) {
    final formatter = DateFormat(_apiDateFormat);
    return formatter.format(date);
  }
  
  /// Parse API date string to DateTime
  static DateTime parseFromApi(String dateString) {
    return DateTime.parse(dateString);
  }
  
  /// Get relative time string (e.g., "il y a 2 heures")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return formatDate(date);
    } else if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'à l\\'instant';
    }
  }
  
  /// Get time of day from DateTime
  static String getTimeOfDay(DateTime date) {
    final hour = date.hour;
    
    if (hour >= 5 && hour < 12) {
      return 'Matin';
    } else if (hour >= 12 && hour < 18) {
      return 'Après-midi';
    } else if (hour >= 18 && hour < 22) {
      return 'Soir';
    } else {
      return 'Nuit';
    }
  }
  
  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }
  
  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
           date.month == yesterday.month &&
           date.day == yesterday.day;
  }
  
  /// Get day name in French
  static String getDayName(DateTime date, {bool abbreviated = false}) {
    final dayNames = abbreviated
        ? ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam']
        : ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
    
    return dayNames[date.weekday % 7];
  }
  
  /// Get month name in French
  static String getMonthName(DateTime date, {bool abbreviated = false}) {
    final monthNames = abbreviated
        ? ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc']
        : ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    
    return monthNames[date.month - 1];
  }
}