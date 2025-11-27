// ignore_for_file: avoid_print

import 'package:digia_ui/digia_ui.dart';

/// Dummy Analytics Adapter for Digia UI SDK Integration
///
/// This adapter implements the DUIAnalytics interface to provide analytics
/// functionality for Digia UI components. In production, this would integrate
/// with real analytics services like Firebase Analytics, Mixpanel, or Amplitude.
///
/// Key Features:
/// - Event logging with parameters
/// - User property tracking
/// - Screen view tracking
/// - User identification
/// - Error and success event handling
///
/// Usage:
/// ```dart
/// final analytics = DummyAnalyticsAdapter();
/// analytics.logEvent('button_tapped', {'button_id': 'checkout'});
/// ```
///
/// Production Integration:
/// Replace print statements with actual analytics service calls:
/// - Firebase: `FirebaseAnalytics.instance.logEvent()`
/// - Mixpanel: `mixpanel.track()`
/// - Amplitude: `amplitude.logEvent()`
class DummyAnalyticsAdapter extends DUIAnalytics {
  /// Log a custom event with optional parameters
  ///
  /// [name] - The event name (e.g., 'button_tapped', 'purchase_completed')
  /// [parameters] - Optional key-value pairs providing additional context
  ///
  /// Example:
  /// ```dart
  /// analytics.logEvent('product_viewed', {
  ///   'product_id': '12345',
  ///   'category': 'electronics',
  ///   'price': 299.99
  /// });
  /// ```
  void logEvent(String name, Map<String, dynamic>? parameters) {
    print('[Analytics] Event: $name, Params: $parameters');
    // Production: Send to analytics service
  }

  /// Set user properties for segmentation and targeting
  ///
  /// [properties] - Map of user attributes like age, location, preferences
  ///
  /// Example:
  /// ```dart
  /// analytics.setUserProperties({
  ///   'user_type': 'premium',
  ///   'subscription_status': 'active',
  ///   'favorite_category': 'electronics'
  /// });
  /// ```
  void setUserProperties(Map<String, dynamic> properties) {
    print('[Analytics] User Properties: $properties');
    // Production: Set user properties in analytics service
  }

  /// Set the user ID for user tracking across sessions
  ///
  /// [userId] - Unique identifier for the user (can be null to clear)
  ///
  /// Example:
  /// ```dart
  /// analytics.setUserId('user_12345');
  /// ```
  void setUserId(String? userId) {
    print('[Analytics] User ID: $userId');
    // Production: Set user ID in analytics service
  }

  /// Log screen view events for navigation tracking
  ///
  /// [screenName] - The name of the screen being viewed
  ///
  /// Example:
  /// ```dart
  /// analytics.logScreenView('product_details');
  /// ```
  void logScreenView(String screenName) {
    print('[Analytics] Screen View: $screenName');
    // Production: Log screen view in analytics service
  }

  /// Handle data source errors from Digia UI components
  ///
  /// This method is called automatically by Digia UI when data fetching fails.
  /// Override to implement custom error tracking and reporting.
  ///
  /// [dataSourceType] - Type of data source (API, cache, etc.)
  /// [source] - Source identifier
  /// [errorInfo] - Error details and metadata
  @override
  void onDataSourceError(
      String dataSourceType, String source, DataSourceErrorInfo errorInfo) {
    print(
        '[Analytics] Data Source Error: $dataSourceType:$source - $errorInfo');
    // Production: Send error to crash reporting service (Sentry, Crashlytics)
    // logEvent('data_source_error', {
    //   'data_source_type': dataSourceType,
    //   'source': source,
    //   'error_code': errorInfo.code,
    //   'error_message': errorInfo.message,
    // });
  }

  /// Handle successful data source operations from Digia UI components
  ///
  /// This method is called automatically by Digia UI when data fetching succeeds.
  /// Useful for performance monitoring and success rate tracking.
  ///
  /// [dataSourceType] - Type of data source (API, cache, etc.)
  /// [source] - Source identifier
  /// [metaData] - Additional metadata about the operation
  /// [perfData] - Performance metrics (response time, data size, etc.)
  @override
  void onDataSourceSuccess(
      String dataSourceType, String source, metaData, perfData) {
    print('[Analytics] Data Source Success: $dataSourceType:$source');
    // Production: Track performance metrics
    // logEvent('data_source_success', {
    //   'data_source_type': dataSourceType,
    //   'source': source,
    //   'response_time_ms': perfData.responseTime,
    //   'data_size_bytes': perfData.dataSize,
    // });
  }

  /// Handle analytic events from Digia UI components
  ///
  /// This method receives events from Digia UI components and processes them.
  /// Called automatically by the Digia UI SDK for component interactions.
  ///
  /// [events] - List of analytic events from Digia UI components
  @override
  void onEvent(List<AnalyticEvent> events) {
    // Process each event in the batch
    for (var event in events) {
      _logAnalyticEvent(event);
    }
  }

  /// Internal method to log individual analytic events
  ///
  /// [event] - Single analytic event from Digia UI
  void _logAnalyticEvent(AnalyticEvent event) {
    print('[Analytics Event] Name: ${event.name}, Params: ${event.payload}');
    // Production: Send to analytics service
    // logEvent(event.name, event.payload);
  }
}
