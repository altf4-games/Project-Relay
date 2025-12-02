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
          e.message?.contains('activity') == true) {
        // If biometrics not set up or activity issue, allow access
        return true;
      }
      // User cancelled, locked out, or authentication failed
      return false;
    } catch (e) {
      // Unknown error - fail securely
      // Log error but don't expose details to user
      return false;
    }
  }
}
