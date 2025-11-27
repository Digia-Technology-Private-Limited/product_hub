import 'package:digia_ui/digia_ui.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart'; // Commented out - not using .env for now
import 'package:producthub_demo/config/digia_config.dart';

/// Integration Mode - Controls how Digia UI integrates with the app
///
/// Defines the primary integration strategy for Digia UI components.
/// This affects initialization, navigation, and component rendering.
enum IntegrationMode {
  /// Full Digia App - Entire UI managed by Digia Studio
  /// Best for: New apps, complete UI overhaul, maximum flexibility
  fullDigia,

  /// Hybrid Mode - Mix of native Flutter screens and Digia pages
  /// Best for: Gradual migration, specific native requirements, mixed teams
  hybrid,
}

/// Application Configuration - Central configuration management
///
/// This class manages all app-wide configuration including:
/// - Integration modes and strategies
/// - Access keys and credentials
/// - Environment settings
/// - Feature flags
/// - Build mode detection
///
/// Security Notes:
/// - Never commit real access keys to version control
/// - Use environment variables or secure key management in production
/// - Consider flutter_secure_storage for sensitive data
///
/// Usage:
/// ```dart
/// await AppConfig.loadConfig();
/// final accessKey = AppConfig.getAccessKey();
/// final isDebug = AppConfig.isDebugMode;
/// ```
class AppConfig {
  // ==================== INTEGRATION MODE ====================
  /// Primary integration strategy for Digia UI
  ///
  /// Change this to switch between full Digia and hybrid integration.
  /// Affects app initialization and component rendering strategies.
  static const IntegrationMode mode = IntegrationMode.fullDigia;

  // ==================== ACCESS KEYS ====================
  /// Digia Studio access key storage
  static String? _accessKey;

  // ==================== ENVIRONMENT ====================
  /// Current environment setting
  static Environment? _environment;

  // ==================== INIT STRATEGY ====================
  /// Digia UI initialization strategy
  static InitStrategy? _initStrategy;

  // ==================== SHOPIFY INTEGRATION ====================
  /// Shopify Storefront API access token
  static String? _shopifyAccessToken;

  /// Shopify store name (subdomain)
  static String? _shopifyStoreName;

  // ==================== BUILD CONFIGURATION ====================
  /// Branch name for environment-specific configurations
  static const String branch = String.fromEnvironment(
    'BRANCH',
    defaultValue: 'main',
  );

  // ==================== FEATURE FLAGS ====================
  /// Enable Firebase Analytics integration
  static const bool enableFirebaseAnalytics = true;

  /// Enable Sentry error reporting
  static const bool enableSentry = true;

  /// Enable push notification support
  static const bool enablePushNotifications = true;

  /// Enable Gokwik payment gateway
  static const bool enableGokwikPayment = true;

  // ==================== CONFIGURATION LOADING ====================
  /// Load application configuration
  ///
  /// Initializes all configuration values from various sources.
  /// In production, this should load from:
  /// - Environment variables
  /// - Secure key storage
  /// - Remote configuration services
  /// - Build-time variables
  ///
  /// Security Warning:
  /// The current implementation uses hardcoded demo values.
  /// Replace with secure configuration loading in production.
  static Future<void> loadConfig() async {
    // TODO: Replace with secure configuration loading
    // Production implementation should use:
    // - flutter_dotenv for .env files
    // - flutter_secure_storage for sensitive keys
    // - Remote config services (Firebase Remote Config, etc.)

    // Demo values - NEVER use in production
    _accessKey =
        '6926e1aba1a01416f0dc2c04'; // Replace with your actual access key
    _environment = Environment.development; // Default to development
    _initStrategy = InitStrategy.networkFirst; // Default strategy
    _shopifyAccessToken = 'a28935969323e9d5c8c7472e3ebe497e';
    _shopifyStoreName = 'digia-open-fashion'; // Replace with your store name

    // Production security checklist:
    // ✅ Access keys from environment variables or secure storage
    // ✅ Never commit real keys to version control
    // ✅ Different keys for different environments
    // ✅ Consider flutter_secure_storage for sensitive data
    // ✅ Validate configuration on app startup
  }

  // ==================== ENVIRONMENT GETTERS ====================
  /// Get current environment setting
  static Environment get environment => _environment ?? Environment.development;

  /// Get initialization strategy
  static InitStrategy get initStrategy =>
      _initStrategy ?? InitStrategy.networkFirst;

  // ==================== SHOPIFY CONFIGURATION ====================
  /// Get Shopify Storefront API access token
  ///
  /// Returns the access token for Shopify GraphQL API calls.
  /// In production, this should come from secure storage.
  static String get shopifyAccessToken {
    return _shopifyAccessToken ?? 'YOUR_PROD_SHOPIFY_ACCESS_TOKEN_HERE';
  }

  /// Get Shopify store name (subdomain)
  ///
  /// Returns the store subdomain for Shopify API URLs.
  /// Format: {storeName}.myshopify.com
  static String get shopifyStoreName {
    return _shopifyStoreName ?? 'YOUR_PROD_SHOPIFY_STORE_NAME_HERE';
  }

  // ==================== ACCESS KEY MANAGEMENT ====================
  /// Get Digia Studio access key
  ///
  /// Returns the access key required for Digia UI initialization.
  /// This key authenticates your app with Digia Studio.
  static String getAccessKey() {
    return _accessKey ?? 'YOUR_PROD_ACCESS_KEY_HERE';
  }

  // ==================== BUILD MODE DETECTION ====================
  /// Check if running in debug mode
  static bool get isDebugMode => kDebugMode;

  /// Check if running in release mode
  static bool get isReleaseMode => kReleaseMode;

  /// Check if running in profile mode
  static bool get isProfileMode => kProfileMode;
}
