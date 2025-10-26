import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Helpers {
  /// Generate a random ID
  static String generateId() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        16,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
  
  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
  
  /// Get file extension from path
  static String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }
  
  /// Get file name from path
  static String getFileName(String filePath) {
    return filePath.split('/').last;
  }
  
  /// Check if file exists
  static Future<bool> fileExists(String filePath) async {
    try {
      return await File(filePath).exists();
    } catch (e) {
      return false;
    }
  }
  
  /// Launch URL
  static Future<bool> launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      return false;
    }
  }
  
  /// Launch phone call
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    return await launchUrl(uri);
  }
  
  /// Launch SMS
  static Future<bool> sendSMS(String phoneNumber, {String? message}) async {
    final uri = Uri.parse('sms:$phoneNumber${message != null ? '?body=$message' : ''}');
    return await launchUrl(uri);
  }
  
  /// Launch email
  static Future<bool> sendEmail(String email, {String? subject, String? body}) async {
    final uri = Uri.parse('mailto:$email?subject=${subject ?? ''}&body=${body ?? ''}');
    return await launchUrl(uri);
  }
  
  /// Show snackbar
  static void showSnackBar(BuildContext context, String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message ?? 'Chargement...'),
          ],
        ),
      ),
    );
  }
  
  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  /// Debounce function calls
  static Timer? _debounceTimer;
  static void debounce(VoidCallback callback, {Duration delay = const Duration(milliseconds: 500)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }
  
  /// Throttle function calls
  static DateTime? _lastThrottleTime;
  static void throttle(VoidCallback callback, {Duration delay = const Duration(milliseconds: 500)}) {
    final now = DateTime.now();
    if (_lastThrottleTime == null || now.difference(_lastThrottleTime!) >= delay) {
      _lastThrottleTime = now;
      callback();
    }
  }
  
  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  /// Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  /// Remove HTML tags from text
  static String removeHtmlTags(String htmlText) {
    return htmlText.replaceAll(RegExp(r'<[^>]*>'), '');
  }
  
  /// Get initials from name
  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'.toUpperCase();
  }
  
  /// Generate color from string
  static Color generateColorFromString(String text) {
    int hash = 0;
    for (int i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }
    
    final hue = (hash % 360).abs().toDouble();
    return HSVColor.fromAHSV(1.0, hue, 0.7, 0.8).toColor();
  }
  
  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal = sqrt(pow(size.width, 2) + pow(size.height, 2));
    return diagonal > 1100.0;
  }
  
  /// Get screen size category
  static String getScreenSizeCategory(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 600) {
      return 'mobile';
    } else if (width < 1024) {
      return 'tablet';
    } else {
      return 'desktop';
    }
  }
}

// Import Timer class
import 'dart:async';