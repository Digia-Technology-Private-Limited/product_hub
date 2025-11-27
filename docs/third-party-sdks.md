# Third-Party SDKs Integration Guide

Complete guide to integrating third-party SDKs with Digia in ProductHub demo.

## Overview

ProductHub demonstrates integration patterns using **dummy/placeholder adapters** that simulate real third-party SDK behavior. This approach allows you to:

- Test Digia UI integration without real service dependencies
- Understand the adapter pattern for future real implementations
- See how message bus routing works with external services

The demo includes dummy implementations for:

1. **Analytics Service** - Event tracking simulation
2. **Message Handler** - Push notification simulation
3. **Payment Service** - Payment gateway simulation
4. **API Service** - HTTP client simulation
5. **Storage Service** - Local storage simulation

---

## 1. Analytics Service (Dummy Implementation)

### Setup

**No external dependencies required** - uses dummy adapter for demonstration.

### Integration with Digia

**Dummy adapter (see `lib/adapters/dummy_analytics_adapter.dart`):**

```dart
class DummyAnalyticsAdapter {
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    // Simulate analytics logging
    print('📊 Analytics Event: $name');
    if (parameters != null) {
      print('   Parameters: $parameters');
    }
    
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 100));
  }
  
  Future<void> setUserId({String? userId}) async {
    print('👤 User ID set: $userId');
    await Future.delayed(Duration(milliseconds: 50));
  }
  
  Future<void> setUserProperties({
    required Map<String, String> properties,
  }) async {
    print('🏷️ User Properties: $properties');
    await Future.delayed(Duration(milliseconds: 50));
  }
  
  Future<void> logScreenView({
    required String screenName,
  }) async {
    print('📱 Screen View: $screenName');
    await Future.delayed(Duration(milliseconds: 50));
  }
}
```

### Using with Message Bus

**Wire into message bus (see `lib/adapters/message_bus_adapter.dart`):**

```dart
class AppMessageBus {
  final DummyAnalyticsAdapter analytics;
  
  AppMessageBus({required this.analytics});
  
  void on(String channel, Function(dynamic params) handler) {
    if (channel == 'log_event') {
      analytics.logEvent(
        name: params['event'],
        parameters: params['params'],
      );
    }
  }
}
```

### Track Events from Digia Pages

**In Digia Studio, configure event handler:**

```json
{
  "widget": "Button",
  "props": {
    "text": "Add to Cart"
  },
  "events": {
    "onPressed": {
      "action": "messageBus",
      "channel": "log_event",
      "params": {
        "event": "add_to_cart",
        "params": {
          "product_id": "{{widget.productId}}",
          "price": "{{widget.price}}"
        }
      }
    }
  }
}
```

---

## 2. Message Handler (Dummy Implementation)

### Setup

**No external dependencies required** - simulates push notification behavior.

### Integration

**Dummy adapter (see `lib/adapters/dummy_message_handler_adapter.dart`):**

```dart
class DummyMessageHandlerAdapter {
  Future<void> initialize() async {
    print('📨 Message Handler initialized (dummy)');
    await Future.delayed(Duration(milliseconds: 200));
  }
  
  Future<String?> getToken() async {
    // Return dummy FCM token
    return 'dummy_fcm_token_' + DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  Stream<Map<String, dynamic>> get onMessage {
    // Simulate incoming messages
    return Stream.periodic(Duration(seconds: 30), (count) {
      return {
        'title': 'Dummy Notification ${count + 1}',
        'body': 'This is a simulated push notification',
        'data': {'page': 'home', 'type': 'promo'}
      };
    });
  }
  
  Future<void> showLocalNotification(Map<String, dynamic> message) async {
    print('🔔 Local Notification: ${message['title']}');
    print('   Body: ${message['body']}');
  }
}
```

### Deep Linking from Notifications

**Handle notification tap:**

```dart
// In your app initialization
messageHandler.onMessage.listen((message) {
  final data = message['data'];
  
  if (data['page'] != null) {
    // Navigate to Digia page
    DUIAppState.of(context).navigateToPage(data['page']);
  }
});
```

---

## 3. Payment Service (Dummy Implementation)

### Setup

**No external dependencies required** - simulates payment gateway behavior.

### Integration

**Dummy adapter (see `lib/adapters/dummy_payment_adapter.dart`):**

```dart
class DummyPaymentAdapter {
  Future<Map<String, dynamic>> startPayment({
    required double amount,
    required String userId,
    required String orderId,
  }) async {
    print('💳 Starting payment: \$${amount} for order $orderId');
    
    // Simulate payment processing
    await Future.delayed(Duration(seconds: 2));
    
    // Random success/failure for demo
    final success = Random().nextBool();
    
    if (success) {
      return {
        'success': true,
        'transactionId': 'txn_dummy_${DateTime.now().millisecondsSinceEpoch}',
        'message': 'Payment successful',
      };
    } else {
      return {
        'success': false,
        'message': 'Payment failed (simulated)',
      };
    }
  }
  
  Future<Map<String, dynamic>> checkPaymentStatus(String transactionId) async {
    print('🔍 Checking payment status: $transactionId');
    
    await Future.delayed(Duration(milliseconds: 500));
    
    return {
      'status': 'completed',
      'amount': 99.99,
      'transactionId': transactionId,
    };
  }
}
```

### Using with Message Bus

**Handle payment from Digia pages:**

```dart
// In message_bus_adapter.dart
messageBus.on('start_payment', (params) async {
  final amount = params['amount'];
  final orderId = params['orderId'];
  
  final result = await paymentAdapter.startPayment(
    amount: amount,
    userId: 'user_demo',
    orderId: orderId,
  );
  
  if (result['success']) {
    analytics.logEvent(
      name: 'payment_success',
      parameters: {'amount': amount, 'order_id': orderId},
    );
    
    // Navigate to success page
    DUIAppState.of(context).navigateToPage('payment_success');
  } else {
    analytics.logEvent(
      name: 'payment_failed',
      parameters: {'reason': result['message']},
    );
  }
});
```

---

## 4. API Service (Dummy Implementation)

### Setup

**Uses Dio for HTTP client** - but connects to dummy endpoints.

### Integration

**Dummy service (see `lib/services/dummy_api_service.dart`):**

```dart
import 'package:dio/dio.dart';

class DummyApiService {
  final Dio _dio;
  
  DummyApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com', // Dummy API
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ));
  }
  
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await _dio.get('/posts');
      
      // Transform dummy data to product format
      return List<Map<String, dynamic>>.from(response.data.map((post) {
        return {
          'id': post['id'],
          'title': post['title'],
          'description': post['body'],
          'price': (post['id'] * 10.0), // Dummy price
          'image': 'https://via.placeholder.com/200x200?text=Product+${post['id']}',
        };
      }));
    } catch (e) {
      print('API Error: $e');
      // Return dummy fallback data
      return [
        {
          'id': 1,
          'title': 'Dummy Product',
          'description': 'This is a fallback product',
          'price': 29.99,
          'image': 'https://via.placeholder.com/200x200?text=Dummy',
        }
      ];
    }
  }
  
  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await _dio.get('/users/1');
    return response.data;
  }
}
```

### Using with Digia

**Call from message bus:**

```dart
messageBus.on('fetch_products', (params) async {
  DUIAppState.of(context).setState('productsLoading', true);
  
  try {
    final products = await apiService.getProducts();
    
    // Update DUIAppState
    DUIAppState.of(context).setState('products', products);
    DUIAppState.of(context).setState('productsLoading', false);
  } catch (e) {
    DUIAppState.of(context).setState('productsError', e.toString());
    DUIAppState.of(context).setState('productsLoading', false);
  }
});
```

---

## 5. Storage Service (Dummy Implementation)

### Setup

**Uses shared_preferences** - but with dummy data simulation.

### Integration

**Dummy service (see `lib/services/dummy_storage_service.dart`):**

```dart
import 'package:shared_preferences/shared_preferences.dart';

class DummyStorageService {
  final SharedPreferences _prefs;
  
  static Future<DummyStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return DummyStorageService._(prefs);
  }
  
  DummyStorageService._(this._prefs);
  
  // General storage with dummy data
  Future<void> setString(String key, String value) async {
    print('💾 Storing: $key = $value');
    await _prefs.setString(key, value);
  }
  
  String? getString(String key) {
    final value = _prefs.getString(key);
    print('📖 Retrieved: $key = $value');
    return value;
  }
  
  // Simulate user preferences
  Future<void> setUserPreferences(Map<String, dynamic> prefs) async {
    final jsonString = jsonEncode(prefs);
    await setString('user_prefs', jsonString);
    print('👤 User preferences saved');
  }
  
  Map<String, dynamic> getUserPreferences() {
    final jsonString = getString('user_prefs');
    if (jsonString == null) return {};
    
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      return {};
    }
  }
}
```

---

## Best Practices

### 1. Use Adapter Pattern for All External Services

✅ **Good:** Create adapter layer (e.g., `DummyAnalyticsAdapter`)
❌ **Bad:** Use services directly in Digia pages

### 2. Route Everything Through Message Bus

✅ **Good:** Digia pages → Message Bus → Adapter → Service
❌ **Bad:** Digia pages → Direct service calls

### 3. Log All Events (Even in Dummy Mode)

```dart
analytics.logEvent(name: 'payment_initiated');
analytics.logEvent(name: 'payment_success');
analytics.logEvent(name: 'payment_failed');
```

### 4. Handle Errors Gracefully

```dart
try {
  await payment.startPayment(...);
} catch (e) {
  analytics.logEvent(name: 'payment_error');
  // Show user-friendly error in Digia UI
  DUIAppState.of(context).setState('paymentError', 'Payment failed');
}
```

### 5. Make Adapters Easily Replaceable

```dart
// Easy to swap dummy for real implementation
abstract class AnalyticsAdapter {
  Future<void> logEvent({required String name, Map<String, dynamic>? parameters});
}

// Dummy implementation
class DummyAnalyticsAdapter implements AnalyticsAdapter { ... }

// Real implementation (future)
// class FirebaseAnalyticsAdapter implements AnalyticsAdapter { ... }
```

---

## Switching from Dummy to Real Services

When you're ready to integrate real third-party SDKs:

1. **Replace dummy adapters** with real implementations
2. **Update pubspec.yaml** with actual dependencies
3. **Modify initialization** in `main.dart`
4. **Test thoroughly** with real services

Example replacement:

```dart
// Before (dummy)
final analytics = DummyAnalyticsAdapter();

// After (real)
final analytics = FirebaseAnalyticsAdapter();
```

---

## Next Steps

- See [Getting Started](getting-started.md) for running the app
- See [State Management](state-management.md) for state sync patterns
- See [Flavors Guide](flavors-guide.md) for environment configuration
