class AppConstants {
  // App Info
  static const String appName = 'Assistance Msaada 2.0';
  static const String appVersion = '2.0.0';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String notificationsEnabledKey = 'notifications_enabled';
  
  // Theme
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFileTypes = [
    'jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'
  ];
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int maxReportTextLength = 2000;
  
  // Emergency
  static const List<String> emergencyNumbers = [
    '117', // Police
    '118', // Pompiers
    '115', // SAMU
  ];
  
  // Languages
  static const List<String> supportedLanguages = ['fr', 'en'];
  static const String defaultLanguage = 'fr';
}