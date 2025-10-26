import 'package:local_auth/local_auth.dart';
// Android-specific messages are available via local_auth, avoid extra imports for cross-platform builds
import '../error/exceptions.dart';

class BiometricAuth {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  
  /// Check if biometric authentication is available
  static Future<bool> isAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }
  
  /// Get list of available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }
  
  /// Authenticate using biometrics
  static Future<bool> authenticate({
    String localizedReason = 'Veuillez vous authentifier pour continuer',
    bool biometricOnly = false,
  }) async {
    try {
      final isAvailable = await BiometricAuth.isAvailable();
      if (!isAvailable) {
        throw const BiometricException('Biometric authentication not available');
      }
      
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        // Use default platform messages to avoid platform-specific imports that break on web
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
          sensitiveTransaction: true,
        ),
      );
    } on Exception catch (e) {
      if (e.toString().contains('UserCancel')) {
        throw const BiometricException('Authentication cancelled by user');
      } else if (e.toString().contains('NotAvailable')) {
        throw const BiometricException('Biometric authentication not available');
      } else if (e.toString().contains('NotEnrolled')) {
        throw const BiometricException('No biometric credentials enrolled');
      } else if (e.toString().contains('LockedOut')) {
        throw const BiometricException('Biometric authentication locked out');
      } else {
        throw BiometricException('Authentication failed: ${e.toString()}');
      }
    }
  }
  
  /// Check if user has enrolled biometrics
  static Future<bool> hasEnrolledBiometrics() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  /// Get biometric type string for display
  static String getBiometricTypeString(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Empreinte digitale';
    } else if (types.contains(BiometricType.iris)) {
      return 'Reconnaissance d\'iris';
    } else if (types.contains(BiometricType.strong)) {
      return 'Authentification biométrique';
    } else if (types.contains(BiometricType.weak)) {
      return 'Authentification biométrique';
    } else {
      return 'Biométrie';
    }
  }
}