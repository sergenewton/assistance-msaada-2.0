import '../constants/app_constants.dart';

class Validators {
  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\\'adresse email est requise';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Adresse email invalide';
    }
    
    return null;
  }
  
  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return 'Le mot de passe doit contenir au moins ${AppConstants.minPasswordLength} caractères';
    }
    
    if (value.length > AppConstants.maxPasswordLength) {
      return 'Le mot de passe ne doit pas dépasser ${AppConstants.maxPasswordLength} caractères';
    }
    
    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Le mot de passe doit contenir au moins une majuscule';
    }
    
    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Le mot de passe doit contenir au moins une minuscule';
    }
    
    // Check for at least one digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Le mot de passe doit contenir au moins un chiffre';
    }
    
    // Check for at least one special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Le mot de passe doit contenir au moins un caractère spécial';
    }
    
    return null;
  }
  
  /// Validate confirm password
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'La confirmation du mot de passe est requise';
    }
    
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    
    return null;
  }
  
  /// Validate phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone number is optional in some cases
    }
    
    // Remove spaces and special characters
    final cleanedValue = value.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Check for international format or local format
    final phoneRegex = RegExp(r'^(\+[1-9]\d{1,14}|0[1-9]\d{8})$');
    if (!phoneRegex.hasMatch(cleanedValue)) {
      return 'Numéro de téléphone invalide';
    }
    
    return null;
  }
  
  /// Validate name (first name, last name)
  static String? validateName(String? value, {String fieldName = 'Ce champ'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }
    
    if (value.length < 2) {
      return '$fieldName doit contenir au moins 2 caractères';
    }
    
    if (value.length > 50) {
      return '$fieldName ne doit pas dépasser 50 caractères';
    }
    
    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp(r'^[a-zA-ZÀ-ÿ\s\-\']+$');
    if (!nameRegex.hasMatch(value)) {
      return '$fieldName ne doit contenir que des lettres, espaces, tirets et apostrophes';
    }
    
    return null;
  }
  
  /// Validate age
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\\'âge est requis';
    }
    
    final age = int.tryParse(value);
    if (age == null) {
      return 'Âge invalide';
    }
    
    if (age < 13) {
      return 'Vous devez avoir au moins 13 ans';
    }
    
    if (age > 120) {
      return 'Âge invalide';
    }
    
    return null;
  }
  
  /// Validate report text
  static String? validateReportText(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le contenu du signalement est requis';
    }
    
    if (value.length > AppConstants.maxReportTextLength) {
      return 'Le texte ne doit pas dépasser ${AppConstants.maxReportTextLength} caractères';
    }
    
    if (value.trim().length < 10) {
      return 'Le signalement doit contenir au moins 10 caractères';
    }
    
    return null;
  }
  
  /// Validate required field
  static String? validateRequired(String? value, {String fieldName = 'Ce champ'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }
  
  /// Validate URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is often optional
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'URL invalide';
    }
    
    return null;
  }
  
  /// Validate file size
  static String? validateFileSize(int fileSizeInBytes) {
    if (fileSizeInBytes > AppConstants.maxFileSize) {
      final maxSizeInMB = (AppConstants.maxFileSize / (1024 * 1024)).toStringAsFixed(1);
      return 'Le fichier ne doit pas dépasser ${maxSizeInMB}MB';
    }
    return null;
  }
  
  /// Validate file extension
  static String? validateFileExtension(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    if (!AppConstants.allowedFileTypes.contains(extension)) {
      return 'Type de fichier non autorisé. Types acceptés: ${AppConstants.allowedFileTypes.join(', ')}';
    }
    return null;
  }
}