import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
class AuthConfig {
  static const Map<String, String> googleSignInClientIds = {
    'web': '718241966892-8eq4imq8ee94cr9ou3p8kt917uep97ko.apps.googleusercontent.com',
    'android': '718241966892-jfp5vo5drrvj7f6ecc7kb3o4elbth5vu.apps.googleusercontent.com',
    // Add other platforms if needed
  };

  static String getClientId() {
    if (kIsWeb) return googleSignInClientIds['web']!;
    if (Platform.isAndroid) return googleSignInClientIds['android']!;
    throw UnsupportedError('Unsupported platform');
  }
}