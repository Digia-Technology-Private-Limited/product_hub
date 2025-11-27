// import 'package:digia_ui/digia_ui.dart'; // Uncomment when using real SDK
import 'package:digia_ui/digia_ui.dart';
import 'app_config.dart';

/// Initialization strategy for Digia UI
enum InitStrategy {
  networkFirst,
  cacheFirst,
  localFirst,
}

/// Digia UI configuration and initialization logic
class DigiaConfig {
  /// Get the appropriate flavor based on environment and build mode
  ///
  /// Available flavor types:
  /// - Flavor.debug(): For development with branch name and environment
  /// - Flavor.staging(): For staging deployments with environment
  /// - Flavor.release(): For production with init strategy and asset paths
  /// - Flavor.versioned(): For versioned releases (less common)
  ///
  /// Currently using debug flavor for development.
  static Flavor getFlavor() {
    return Flavor.debug(
      branchName: AppConfig.branch,
      environment: AppConfig.environment,
    );
  }

  /// Initialize Digia UI with all configurations
  ///
  /// DigiaUIOptions configuration options:
  ///
  /// Required:
  /// - accessKey: Your Digia Studio access key for authentication
  /// - flavor: Environment-specific configuration (debug/staging/release)
  ///
  /// Optional:
  /// - networkConfiguration: Custom network settings for API behavior
  ///   (timeouts, retries, custom headers, etc.)
  ///
  /// Additional developerConfig is automatically set by the SDK for
  /// debugging and development features.
  ///
  /// For advanced usage, DigiaUIOptions.internal() provides access to:
  /// - Custom DeveloperConfig with the following options:
  ///   * proxyUrl: HTTP proxy for debugging network traffic
  ///   * inspector: Custom inspector for debug information capture
  ///   * host: Custom hosting environment configuration
  ///   * baseUrl: Custom backend API URL override
  /// - This is primarily used internally by the SDK but can be used for
  ///   advanced customization when needed
  ///
  /// Example configurations:
  /// ```dart
  /// // Standard configuration
  /// DigiaUIOptions(
  ///   accessKey: 'your_access_key',
  ///   flavor: flavor,
  ///   networkConfiguration: NetworkConfiguration(
  ///     timeout: Duration(seconds: 30),
  ///     retryCount: 3,
  ///   ),
  /// )
  ///
  /// // Advanced internal configuration
  /// DigiaUIOptions.internal(
  ///   accessKey: 'your_access_key',
  ///   flavor: flavor,
  ///   networkConfiguration: NetworkConfiguration(...),
  ///   developerConfig: DeveloperConfig(
  ///     proxyUrl: '192.168.1.100:8888', // Charles Proxy
  ///     inspector: MyCustomInspector(),
  ///     host: DashboardHost(),
  ///     baseUrl: 'https://dev-api.digia.tech/api/v1',
  ///   ),
  /// )
  /// ```
  static Future<DigiaUI> initialize() async {
    final flavor = getFlavor();

    return await DigiaUI.initialize(
      DigiaUIOptions(
        accessKey: AppConfig.getAccessKey(),
        flavor: flavor,
        // Optional: Add network configuration if needed
        // networkConfiguration: NetworkConfiguration(...),
      ),
    );
  }
}
