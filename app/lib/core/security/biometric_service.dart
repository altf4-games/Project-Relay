import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> isAvailable() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      final isAvailable = await BiometricService.isAvailable();
      if (!isAvailable) {
        return true; // Allow access if biometrics not available
      }

      return await _auth.authenticate(
        localizedReason: 'Authenticate to access Relay',
      );
    } on PlatformException catch (e) {
      // Handle specific error cases
      if (e.code == 'NotAvailable' ||
          e.code == 'NotEnrolled' ||
          e.code == 'LockedOut' ||
          e.code == 'PermanentlyLockedOut' ||
          e.message?.contains('activity') == true) {
        // If biometrics not set up or activity issue, allow access
        return true;
      }
      // User cancelled or other errors
      return false;
    } catch (e) {
      // Unknown error, allow access for better UX
      return true;
    }
  }
}
