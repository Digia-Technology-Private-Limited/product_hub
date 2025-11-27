import 'package:digia_ui/digia_ui.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart'; // Commented out - not using .env for now
import 'package:producthub_demo/config/digia_config.dart';

/// Integration mode determines how Digia UI is integrated into the app
enum IntegrationMode {
  /// Entire app UI managed by Digia Studio
  fullDigia,

  /// Mix of native Flutter screens and Digia pages
  hybrid,
}

/// App-wide configuration
class AppConfig {
  // ==================== INTEGRATION MODE ====================
  /// Change this to switch between integration patterns
  static const IntegrationMode mode = IntegrationMode.fullDigia;

  // ==================== ACCESS KEYS ====================
  static String? _accessKey;

  // ==================== ENVIRONMENT ====================
  static Environment? _environment;

  // ==================== INIT STRATEGY ====================
  static InitStrategy? _initStrategy;

  static String? _shopifyAccessToken;

  static String? _shopifyStoreName;

  static const String branch = String.fromEnvironment(
    'BRANCH',
    defaultValue: 'main',
  );

  // ==================== FEATURE FLAGS ====================
  static const bool enableFirebaseAnalytics = true;
  static const bool enableSentry = true;
  static const bool enablePushNotifications = true;
  static const bool enableGokwikPayment = true;

  // ==================== HELPERS ====================
  static Future<void> loadConfig() async {
    // For now, using hardcoded default values
    // TODO: In production, load from secure sources (environment variables, secure storage, etc.)
    // DO NOT hardcode sensitive values like access keys in production code
    _accessKey =
        '6926e1aba1a01416f0dc2c04'; // Replace with your actual access key
    _environment = Environment.development; // Default to development
    _initStrategy = InitStrategy.networkFirst; // Default strategy
    _shopifyAccessToken = 'a28935969323e9d5c8c7472e3ebe497e';
    _shopifyStoreName = 'digia-open-fashion'; // Replace with your store name

    // Production security note:
    // - Access keys should come from environment variables or secure key management
    // - Never commit real access keys to version control
    // - Use different keys for different environments
    // - Consider using flutter_secure_storage for sensitive data
  }

  static Environment get environment => _environment ?? Environment.development;

  static InitStrategy get initStrategy =>
      _initStrategy ?? InitStrategy.networkFirst;

  static String get shopifyAccessToken {
    return _shopifyAccessToken ?? 'YOUR_PROD_SHOPIFY_ACCESS_TOKEN_HERE';
  }

  static String get shopifyStoreName {
    return _shopifyStoreName ?? 'YOUR_PROD_SHOPIFY_STORE_NAME_HERE';
  }

  static String getAccessKey() {
    return _accessKey ?? 'YOUR_PROD_ACCESS_KEY_HERE';
  }

  static bool get isDebugMode => kDebugMode;
  static bool get isReleaseMode => kReleaseMode;
  static bool get isProfileMode => kProfileMode;
}
