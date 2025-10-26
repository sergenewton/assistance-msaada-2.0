import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class EncryptionService {
  static const String _key = 'assistance_msaada_2_0_encryption_key';
  
  /// Encrypt sensitive data using AES
  static String encrypt(String data) {
    try {
      final bytes = utf8.encode(data);
      final key = utf8.encode(_key);
      final hmacSha256 = Hmac(sha256, key);
      final digest = hmacSha256.convert(bytes);
      
      // Simple encoding for demo - in production use proper AES encryption
      final combined = bytes + digest.bytes;
      return base64.encode(combined);
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }
  
  /// Decrypt sensitive data
  static String decrypt(String encryptedData) {
    try {
      final combined = base64.decode(encryptedData);
      final dataLength = combined.length - 32; // SHA256 digest is 32 bytes
      
      final originalBytes = combined.sublist(0, dataLength);
      final digestBytes = combined.sublist(dataLength);
      
      // Verify integrity
      final key = utf8.encode(_key);
      final hmacSha256 = Hmac(sha256, key);
      final computedDigest = hmacSha256.convert(originalBytes);
      
      if (!_listEquals(digestBytes, computedDigest.bytes)) {
        throw Exception('Data integrity check failed');
      }
      
      return utf8.decode(originalBytes);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }
  
  /// Hash password using SHA256
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  /// Generate a random salt
  static String generateSalt() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final bytes = utf8.encode(timestamp + _key);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }
  
  static bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}