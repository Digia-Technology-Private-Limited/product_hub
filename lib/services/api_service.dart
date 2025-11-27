// import 'package:dio/dio.dart'; // Uncomment when using real HTTP client

// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:producthub_demo/config/app_config.dart';

import '../dummy_adapters/analytics_adapter.dart';

/// API service using Dio for HTTP requests
/// Handles all network calls to backend APIs
/// Implemented as a singleton to ensure consistent API client configuration
///
/// Usage:
/// ```dart
/// // Initialize once (optional, with custom analytics)
/// ApiService.initialize(analytics: myAnalyticsAdapter);
///
/// // Use throughout the app
/// final cartData = await ApiService.instance.getCart(cartId);
/// ```
///
/// Benefits of singleton:
/// - Single Dio instance with consistent configuration
/// - Prevents multiple HTTP clients from being created
/// - Ensures thread-safe API calls
/// - Centralized error handling and analytics
class ApiService {
  late Dio _dio;
  final DummyAnalyticsAdapter _analytics;

  // Singleton instance
  static ApiService? _instance;

  /// Private constructor - use [instance] getter instead
  ApiService._internal({
    DummyAnalyticsAdapter? analytics,
  }) : _analytics = analytics ?? DummyAnalyticsAdapter() {
    // When using real Dio:
    _dio = Dio(
      BaseOptions(
        baseUrl:
            'https://${AppConfig.shopifyStoreName}.myshopify.com/api/2025-07/graphql.json',
      ),
    );
  }

  /// Get the singleton instance of ApiService
  /// Optionally pass analytics adapter on first initialization
  static ApiService get instance {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  /// Initialize the singleton with custom analytics adapter
  /// Call this once at app startup if you need custom analytics
  static void initialize({
    DummyAnalyticsAdapter? analytics,
  }) {
    if (_instance == null) {
      _instance = ApiService._internal(analytics: analytics);
    } else {
      // If already initialized, you could optionally update analytics
      // but for simplicity, we'll ignore subsequent calls
      print(
          '[ApiService] Singleton already initialized, ignoring initialize() call');
    }
  }

  Future<dynamic> getCart(String cartId) async {
    try {
      final response = await _dio.post(
        '',
        options: Options(
          headers: {
            'X-Shopify-Storefront-Access-Token': AppConfig.shopifyAccessToken,
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'query': '''
           query GetCart(\$cartId: ID!) {
  cart(id: \$cartId) {
    id
    checkoutUrl
    totalQuantity
    cost {
      subtotalAmount {
        amount
        currencyCode
      }
      totalAmount {
        amount
        currencyCode
      }
    }
    lines(first: 20) {
      edges {
        node {
          id
           quantity
          merchandise {
            ... on ProductVariant {
              id
             title
              price {
                amount
                currencyCode
              }
              compareAtPrice {
                amount
                currencyCode
              }
              image {
                url
                altText
              }
              product {
                title
                handle
              }
            }
          }
        }
      }
    }
    discountCodes {
      code
      applicable
    }
    discountAllocations {
      discountedAmount {
        amount
        currencyCode
      }
    }
  }
}

          ''',
          'variables': {'cartId': cartId},
        },
      );

      return response.data;
    } catch (e) {
      print('[ApiService] Error fetching cart: $e');
      _analytics.logEvent('api_error', {'error': e.toString()});
      return null;
    }
  }
}
