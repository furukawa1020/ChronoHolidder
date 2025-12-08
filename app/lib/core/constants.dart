import 'package:flutter/foundation.dart';

class AppConstants {
  // TODO: Replace with your actual Railway URL after deployment
  static const String _productionUrl = "https://your-railway-app.up.railway.app";
  
  static String get backendUrl {
    if (kReleaseMode) return _productionUrl; // Production (Google Play)
    return "http://127.0.0.1:8000"; // Localhost (Web/Windows) & Android (via adb reverse)
  }
}
