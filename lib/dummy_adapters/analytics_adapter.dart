// Analytics adapter for Digia UI

import 'package:digia_ui/digia_ui.dart';

class DummyAnalyticsAdapter extends DUIAnalytics {
  /// Log an event to Firebase Analytics
  void logEvent(String name, Map<String, dynamic>? parameters) {
    print('[Analytics] Event: $name, Params: $parameters');
  }

  /// Set user properties
  void setUserProperties(Map<String, dynamic> properties) {
    print('[Analytics] User Properties: $properties');
  }

  /// Set user ID
  void setUserId(String? userId) {
    print('[Analytics] User ID: $userId');
  }

  /// Log screen view
  void logScreenView(String screenName) {
    print('[Analytics] Screen View: $screenName');
  }

  @override
  void onDataSourceError(
      String dataSourceType, String source, DataSourceErrorInfo errorInfo) {
    // TODO: implement onDataSourceError
  }

  @override
  void onDataSourceSuccess(
      String dataSourceType, String source, metaData, perfData) {
    // TODO: implement onDataSourceSuccess
  }

  @override
  void onEvent(List<AnalyticEvent> events) {
    // TODO: implement onEvent
  }
}
