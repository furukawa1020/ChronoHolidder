import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConstants {
  // TODO: Replace with your actual Railway URL after deployment
  // FOR LOCAL RELEASE TESTING: We point this to localhost so the Release APK works with adb reverse.
  static const String _productionUrl = "http://127.0.0.1:8000";
  
  static String get backendUrl {
    if (kReleaseMode) return _productionUrl; // Production (Google Play)
    // NOTE: For Emulator use 10.0.2.2. For Real Device use 127.0.0.1 + adb reverse.
    // We default to 127.0.0.1 so it works for Real Devices (via install_android.bat).
    return "http://127.0.0.1:8000"; 
  }
}
