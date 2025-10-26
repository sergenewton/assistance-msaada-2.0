class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://api.assistance-msaada.com';
  static const String apiVersion = '/api/v1';
  
  // Auth Endpoints
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String logout = '$apiVersion/auth/logout';
  static const String refreshToken = '$apiVersion/auth/refresh';
  
  // Report Endpoints
  static const String reports = '$apiVersion/reports';
  static const String submitReport = '$apiVersion/reports/submit';
  static const String reportStatus = '$apiVersion/reports/status';
  
  // Content Endpoints
  static const String articles = '$apiVersion/content/articles';
  static const String videos = '$apiVersion/content/videos';
  
  // Notification Endpoints
  static const String notifications = '$apiVersion/notifications';
  
  // Chat Endpoints
  static const String chat = '$apiVersion/chat';
  static const String chatHistory = '$apiVersion/chat/history';
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Timeout
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}