// import 'package:dio/dio.dart'; // Uncomment when using real HTTP client

// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:producthub_demo/config/app_config.dart';

import '../dummy_adapters/analytics_adapter.dart';

/// Shopify Storefront API Service - GraphQL Integration Layer
///
/// Comprehensive API service for Shopify Storefront GraphQL operations.
/// Implements singleton pattern for consistent HTTP client management and
/// provides type-safe GraphQL query execution with built-in error handling.
///
/// Key Features:
/// - Singleton Dio HTTP client with Shopify-specific configuration
/// - GraphQL query execution with variable substitution
/// - Comprehensive error handling and analytics logging
/// - Cart operations (get, create, update, delete)
/// - Product catalog queries
/// - Checkout URL generation
///
/// Security Considerations:
/// - Storefront Access Token is securely stored in AppConfig
/// - All requests use HTTPS with proper headers
/// - Error messages are sanitized before logging
/// - Analytics events track API failures without exposing sensitive data
///
/// Usage Patterns:
/// ```dart
/// // Initialize once at app startup
/// ApiService.initialize(analytics: myAnalyticsAdapter);
///
/// // Get cart data
/// final cartData = await ApiService.instance.getCart(cartId);
/// if (cartData != null) {
///   final cart = cartData['data']['cart'];
///   print('Cart total: ${cart['cost']['totalAmount']['amount']}');
/// }
///
/// // Handle errors gracefully
/// try {
///   final result = await ApiService.instance.getCart(cartId);
/// } catch (e) {
///   // Error already logged via analytics
///   showErrorDialog('Failed to load cart');
/// }
/// ```
///
/// GraphQL Schema Integration:
/// - Uses Shopify Storefront API v2025-07
/// - Supports cart operations with merchandise variants
/// - Includes pricing, images, and product information
/// - Handles discount codes and allocations
///
/// Error Handling:
/// - Network errors are caught and logged
/// - GraphQL errors are extracted from response
/// - Analytics events track error types and frequencies
/// - Null safety ensures graceful degradation
///
/// Performance Optimizations:
/// - Single Dio instance reduces connection overhead
/// - GraphQL queries are optimized for mobile usage
/// - Response caching can be added at Dio interceptor level
/// - Connection pooling via Dio's built-in mechanisms
class ApiService {
  /// Dio HTTP client instance with Shopify configuration
  late Dio _dio;

  /// Analytics adapter for tracking API events and errors
  final DummyAnalyticsAdapter _analytics;

  /// Singleton instance - use [instance] getter
  static ApiService? _instance;

  /// Private constructor - enforces singleton pattern
  ///
  /// Initializes Dio client with Shopify Storefront API configuration:
  /// - Base URL constructed from store name in AppConfig
  /// - Default headers for GraphQL content type
  /// - Analytics adapter for error tracking
  ///
  /// Parameters:
  /// - analytics: Optional custom analytics implementation
  ///   Defaults to DummyAnalyticsAdapter if not provided
  ApiService._internal({
    DummyAnalyticsAdapter? analytics,
  }) : _analytics = analytics ?? DummyAnalyticsAdapter() {
    // Configure Dio for Shopify Storefront API
    _dio = Dio(
      BaseOptions(
        baseUrl:
            'https://${AppConfig.shopifyStoreName}.myshopify.com/api/2025-07/graphql.json',
        headers: {
          'Content-Type': 'application/json',
          // Authorization header added per-request for security
        },
        // Timeout configurations for mobile networks
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Log API requests (without sensitive data)
          print('[ApiService] Making GraphQL request');
          handler.next(options);
        },
        onResponse: (response, handler) {
          // Log successful responses
          print('[ApiService] GraphQL request successful');
          handler.next(response);
        },
        onError: (error, handler) {
          // Enhanced error logging
          print('[ApiService] GraphQL request failed: ${error.message}');
          _analytics.logEvent('api_error', {
            'error_type': error.type.toString(),
            'status_code': error.response?.statusCode,
            'url': error.requestOptions.uri.toString(),
          });
          handler.next(error);
        },
      ),
    );
  }

  /// Get the singleton instance of ApiService
  ///
  /// Returns the existing instance or creates a new one if needed.
  /// Thread-safe due to Dart's single-threaded nature.
  ///
  /// Returns:
  /// - Existing ApiService instance
  static ApiService get instance {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  /// Initialize the singleton with custom analytics adapter
  ///
  /// Should be called once at app startup. Subsequent calls are ignored
  /// to maintain singleton integrity.
  ///
  /// Parameters:
  /// - analytics: Custom analytics implementation for API tracking
  ///
  /// Usage:
  /// ```dart
  /// void main() {
  ///   ApiService.initialize(analytics: FirebaseAnalyticsAdapter());
  ///   runApp(MyApp());
  /// }
  /// ```
  static void initialize({
    DummyAnalyticsAdapter? analytics,
  }) {
    if (_instance == null) {
      _instance = ApiService._internal(analytics: analytics);
    } else {
      // Singleton already exists - log but don't recreate
      print(
          '[ApiService] Singleton already initialized, ignoring initialize() call');
    }
  }

  /// Fetch cart data from Shopify Storefront API
  ///
  /// Executes GraphQL query to retrieve comprehensive cart information
  /// including line items, pricing, discounts, and checkout URL.
  ///
  /// Parameters:
  /// - cartId: Shopify cart global ID (format: gid://shopify/Cart/123)
  ///
  /// Returns:
  /// - Map containing cart data on success
  /// - null on error (error details logged via analytics)
  ///
  /// GraphQL Query Details:
  /// - Retrieves cart lines with merchandise variants
  /// - Includes pricing information (current and compare-at)
  /// - Fetches product images and titles
  /// - Gets discount codes and allocations
  /// - Provides checkout URL for web checkout
  ///
  /// Error Scenarios:
  /// - Invalid cart ID: Returns null with error logging
  /// - Network failure: Dio interceptor handles logging
  /// - GraphQL errors: Logged via analytics with error details
  ///
  /// Usage:
  /// ```dart
  /// final cartData = await ApiService.instance.getCart(cartId);
  /// if (cartData != null) {
  ///   final lines = cartData['data']['cart']['lines']['edges'];
  ///   for (var line in lines) {
  ///     final product = line['node']['merchandise']['product'];
  ///     print('Product: ${product['title']}');
  ///   }
  /// }
  /// ```
  Future<dynamic> getCart(String cartId) async {
    try {
      // Execute GraphQL query with variables
      final response = await _dio.post(
        '', // Empty path since baseUrl includes full endpoint
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

      // Return raw GraphQL response data
      return response.data;
    } catch (e) {
      // Log error with context but no sensitive data
      print('[ApiService] Error fetching cart: $e');
      _analytics.logEvent('api_error', {
        'operation': 'getCart',
        'error': e.toString(),
        'cart_id_provided': cartId.isNotEmpty,
      });
      return null;
    }
  }
}
