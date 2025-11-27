import 'package:flutter/material.dart';
import 'package:producthub_demo/screens/cart_screen.dart';

import 'analytics_adapter.dart';
import 'package:digia_ui/digia_ui.dart';
// import 'package:flutter/services.dart'; // For Share functionality

/// Message handler for Digia UI communication
/// Demonstrates proper message bus pattern for Native <-> Digia communication
class CustomMessageHandler {
  final DummyAnalyticsAdapter? _analytics;

  CustomMessageHandler({DummyAnalyticsAdapter? analytics})
      : _analytics = analytics;

  /// Handle messages from Digia pages
  void send(Message message, BuildContext context) async {
    final name = message.name;
    final payload = message.payload;
    try {
      switch (name) {
        // ==================== PAYMENT ====================
        case 'start_payment':
          await _handlePayment(payload);
          break;

        // ==================== SHARE ====================
        case 'share_product':
          await _handleShare(payload);
          break;

        // ==================== NAVIGATION ====================
        case 'open_url':
          await _handleOpenUrl(payload);
          break;

        // ==================== ANALYTICS ====================
        case 'log_event':
          _handleLogEvent(payload);
          break;

        case 'open_cart':
          // Handle open cart action
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
      // In production, report to Sentry
      // Sentry.captureException(e);
    }
  }

  // ==================== PAYMENT HANDLER ====================
  Future<void> _handlePayment(dynamic message) async {
    final paymentData =
        message is Map ? Map<String, dynamic>.from(message) : {};
    final result = {
      'success': true,
      'amount': paymentData['amount'],
      'orderId': 'ORDER12345'
    };

    // Update app state with payment result
    // In production with real SDK, uncomment:
    DUIAppState().update('paymentResult', result);

    // Log analytics event
    _analytics?.logEvent('payment_attempt', {
      'success': result['success'],
      'amount': result['amount'],
      'order_id': result['orderId'],
    });
  }

  // ==================== SHARE HANDLER ====================
  Future<void> _handleShare(dynamic message) async {
    final data = message is Map ? Map<String, dynamic>.from(message) : {};
    final url = data['url'] ?? '';
    final title = data['title'] ?? '';
    final text = data['text'] ?? '$title\n$url';

    // In production, use Share plugin:
    // await Share.share(text, subject: title);
    print('[Share] Would share: $text');

    _analytics?.logEvent('share', {
      'content_type': 'product',
      'item_id': data['productId'],
    });
  }

  // ==================== URL HANDLER ====================
  Future<void> _handleOpenUrl(dynamic message) async {
    final url = message is String ? message : message['url'];

    // In production, use url_launcher:
    // if (await canLaunchUrl(Uri.parse(url))) {
    //   await launchUrl(Uri.parse(url));
    // }

    _analytics?.logEvent('external_link_opened', {'url': url});
  }

  // ==================== ANALYTICS HANDLER ====================
  void _handleLogEvent(dynamic message) {
    final data = message is Map ? Map<String, dynamic>.from(message) : {};
    final eventName = data['name'] ?? 'custom_event';
    final params = data['params'] as Map<String, dynamic>?;

    _analytics?.logEvent(eventName, params);
  }

  // ==================== CUSTOM HANDLER ====================
  void _handleCustomChannel(Message message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Received message on unknown channel: ${message.name}'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
