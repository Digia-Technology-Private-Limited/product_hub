import 'package:flutter/material.dart';
import 'package:producthub_demo/screens/cart_screen.dart';

import 'analytics_adapter.dart';
import 'package:digia_ui/digia_ui.dart';

/// Message Handler for Digia UI - Native Communication Bridge
///
/// This class implements the message bus pattern for bidirectional communication
/// between Digia UI components and native Flutter code. It handles messages
/// sent from Digia Studio pages via the postMessage API.
///
/// Key Responsibilities:
/// - Route messages from Digia UI to appropriate native handlers
/// - Handle navigation requests from Digia components
/// - Process analytics events from Digia UI
/// - Manage custom channel messages
/// - Provide error handling and logging
///
/// Message Flow:
/// Digia UI Component → postMessage() → MessageHandler → Native Action
///
/// Supported Channels:
/// - 'open_url': External URL navigation
/// - 'log_event': Analytics event tracking
/// - 'open_cart': Navigate to cart screen
/// - Custom channels: Handled by _handleCustomChannel()
///
/// Usage:
/// ```dart
/// final messageHandler = CustomMessageHandler(analytics: analytics);
/// // Messages are automatically routed when sent from Digia UI
/// ```
///
/// Error Handling:
/// - All message processing is wrapped in try-catch blocks
/// - Errors are logged but don't crash the app
/// - In production, errors should be sent to crash reporting services
class CustomMessageHandler {
  /// Analytics adapter for tracking message-related events
  final DummyAnalyticsAdapter? _analytics;

  /// Constructor with optional analytics integration
  ///
  /// [analytics] - Optional analytics adapter for event tracking
  CustomMessageHandler({DummyAnalyticsAdapter? analytics})
      : _analytics = analytics;

  /// Main message routing method - called by Digia UI components
  ///
  /// This method receives messages from Digia UI via the postMessage API
  /// and routes them to appropriate handlers based on the message channel.
  ///
  /// [message] - Message object containing name (channel) and payload
  /// [context] - BuildContext for navigation and UI operations
  ///
  /// Supported message formats:
  /// ```dart
  /// // Simple string message
  /// message.name = 'open_url'
  /// message.payload = 'https://example.com'
  ///
  /// // Complex object message
  /// message.name = 'log_event'
  /// message.payload = {'event': 'button_tap', 'params': {'id': 'checkout'}}
  /// ```
  void send(Message message, BuildContext context) async {
    final name = message.name;
    final payload = message.payload;

    try {
      switch (name) {
        // ==================== NAVIGATION ====================
        case 'open_url':
          await _handleOpenUrl(payload);
          break;

        // ==================== ANALYTICS ====================
        case 'log_event':
          _handleLogEvent(payload);
          break;

        case 'open_cart':
          // Handle open cart action - navigate to cart screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CartScreenByDigiaUI(),
            ),
          );
          break;

        // ==================== CUSTOM ====================
        default:
          _handleCustomChannel(message, context);
      }
    } catch (e) {
      // Log error for debugging - in production, send to Sentry/Crashlytics
      print('[MessageHandler] Error processing message "$name": $e');
      // Production: Sentry.captureException(e);

      // Track error analytics
      _analytics?.logEvent('message_handler_error', {
        'channel': name,
        'error': e.toString(),
        'payload_type': payload.runtimeType.toString(),
      });
    }
  }

  // ==================== URL HANDLER ====================
  /// Handle external URL navigation requests from Digia UI
  ///
  /// Opens URLs in external browser or handles deep links.
  /// In production, use url_launcher package for proper URL handling.
  ///
  /// [message] - URL string or object containing URL
  ///
  /// Example messages:
  /// - 'https://example.com' (string)
  /// - {'url': 'https://example.com', 'target': '_blank'} (object)
  Future<void> _handleOpenUrl(dynamic message) async {
    final url = message is String ? message : message['url'];

    if (url == null || url.isEmpty) {
      print('[MessageHandler] Invalid URL received: $message');
      return;
    }

    print('[MessageHandler] Opening URL: $url');

    // In production, use url_launcher:
    // if (await canLaunchUrl(Uri.parse(url))) {
    //   await launchUrl(Uri.parse(url));
    // } else {
    //   print('[MessageHandler] Could not launch URL: $url');
    // }

    // For demo purposes, just log the action
    print('[MessageHandler] Would open URL: $url');

    // Track analytics
    _analytics?.logEvent('external_link_opened', {'url': url});
  }

  // ==================== ANALYTICS HANDLER ====================
  /// Handle analytics events from Digia UI components
  ///
  /// Processes analytics events sent from Digia Studio and forwards
  /// them to the analytics service.
  ///
  /// [message] - Analytics event data
  ///
  /// Expected format:
  /// ```dart
  /// {
  ///   'name': 'event_name',
  ///   'params': {'key': 'value', ...}
  /// }
  /// ```
  void _handleLogEvent(dynamic message) {
    final data = message is Map ? Map<String, dynamic>.from(message) : {};
    final eventName = data['name'] ?? 'custom_event';
    final params = data['params'] as Map<String, dynamic>?;

    print('[MessageHandler] Analytics event: $eventName');

    // Forward to analytics service
    _analytics?.logEvent(eventName, params);
  }

  // ==================== CUSTOM CHANNEL HANDLER ====================
  /// Handle messages on unknown/custom channels
  ///
  /// Provides fallback handling for messages that don't match predefined channels.
  /// Shows user feedback and logs the unknown message for debugging.
  ///
  /// [message] - The unknown message object
  /// [context] - BuildContext for showing UI feedback
  ///
  /// In production, consider:
  /// - Adding more specific channel handlers
  /// - Sending unknown messages to analytics
  /// - Providing user-friendly error messages
  void _handleCustomChannel(Message message, BuildContext context) {
    print('[MessageHandler] Unknown channel: ${message.name}');

    // Show user feedback for unknown messages
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Received message on unknown channel: ${message.name}'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );

    // Track unknown channel usage for analytics
    _analytics?.logEvent('unknown_message_channel', {
      'channel': message.name,
      'payload_type': message.payload.runtimeType.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
