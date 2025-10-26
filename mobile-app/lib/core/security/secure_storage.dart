import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import 'encryption_service.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: IOSAccessibility.first_unlock_this_device,
    ),
  );
  
  /// Store access token securely
  static Future<void> storeAccessToken(String token) async {
    await _storage.write(
      key: AppConstants.accessTokenKey,
      value: EncryptionService.encrypt(token),
    );
  }
  
  /// Get access token
  static Future<String?> getAccessToken() async {
    final encryptedToken = await _storage.read(key: AppConstants.accessTokenKey);
    if (encryptedToken == null) return null;
    
    try {
      return EncryptionService.decrypt(encryptedToken);
    } catch (e) {
      // If decryption fails, remove the corrupted token
      await deleteAccessToken();
      return null;
    }
  }
  
  /// Delete access token
  static Future<void> deleteAccessToken() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
  }
  
  /// Store refresh token securely
  static Future<void> storeRefreshToken(String token) async {
    await _storage.write(
      key: AppConstants.refreshTokenKey,
      value: EncryptionService.encrypt(token),
    );
  }
  
  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    final encryptedToken = await _storage.read(key: AppConstants.refreshTokenKey);
    if (encryptedToken == null) return null;
    
    try {
      return EncryptionService.decrypt(encryptedToken);
    } catch (e) {
      await deleteRefreshToken();
      return null;
    }
  }
  
  /// Delete refresh token
  static Future<void> deleteRefreshToken() async {
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }
  
  /// Store user data
  static Future<void> storeUserData(Map<String, dynamic> userData) async {
    final jsonString = json.encode(userData);
    await _storage.write(
      key: AppConstants.userDataKey,
      value: EncryptionService.encrypt(jsonString),
    );
  }
  
  /// Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final encryptedData = await _storage.read(key: AppConstants.userDataKey);
    if (encryptedData == null) return null;
    
    try {
      final jsonString = EncryptionService.decrypt(encryptedData);
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      await deleteUserData();
      return null;
    }
  }
  
  /// Delete user data
  static Future<void> deleteUserData() async {
    await _storage.delete(key: AppConstants.userDataKey);
  }
  
  /// Store biometric setting
  static Future<void> storeBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: AppConstants.biometricEnabledKey,
      value: enabled.toString(),
    );
  }
  
  /// Get biometric setting
  static Future<bool> getBiometricEnabled() async {
    final value = await _storage.read(key: AppConstants.biometricEnabledKey);
    return value == 'true';
  }
  
  /// Store custom secure data
  static Future<void> storeSecureData(String key, String value) async {
    await _storage.write(
      key: key,
      value: EncryptionService.encrypt(value),
    );
  }
  
  /// Get custom secure data
  static Future<String?> getSecureData(String key) async {
    final encryptedValue = await _storage.read(key: key);
    if (encryptedValue == null) return null;
    
    try {
      return EncryptionService.decrypt(encryptedValue);
    } catch (e) {
      await _storage.delete(key: key);
      return null;
    }
  }
  
  /// Clear all secure storage
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}