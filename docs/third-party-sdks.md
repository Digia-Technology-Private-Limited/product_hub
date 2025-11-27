# Third-Party SDKs Integration Guide

Complete guide to integrating third-party SDKs with Digia in ProductHub demo.

## Overview

ProductHub demonstrates integration patterns using **dummy/placeholder adapters** that simulate real third-party SDK behavior. This approach allows you to test Digia UI integration without real service dependencies.

The demo includes dummy implementations for:
- **Analytics Service** - Event tracking simulation
- **Message Handler** - Push notification simulation
- **Payment Service** - Payment gateway simulation
- **API Service** - HTTP client simulation

---

## 1. Analytics Service (Dummy Implementation)

### Setup
**No external dependencies required** - uses dummy adapter for demonstration.

### Integration with Digia

**Dummy adapter (see `lib/dummy_adapters/analytics_adapter.dart`):**

```dart
class DummyAnalyticsAdapter extends DUIAnalytics {
  @override
  void logEvent(String name, Map<String, dynamic>? parameters) {
    print('📊 Analytics Event: $name, Params: $parameters');
  }
  
  @override
  void setUserProperties(Map<String, dynamic> properties) {
    print('🏷️ User Properties: $properties');
  }
  
  @override
  void setUserId(String? userId) {
    print('👤 User ID: $userId');
  }
  
  @override
  void logScreenView(String screenName) {
    print('📱 Screen: $screenName');
  }

  @override
  void onDataSourceError(String dataSourceType, String source, DataSourceErrorInfo errorInfo) {}
  @override
  void onDataSourceSuccess(String dataSourceType, String source, metaData, perfData) {}
  @override
  void onEvent(List<AnalyticEvent> events) {}
}
```

### Key Points
- **Always extend DUIAnalytics** for proper Digia UI integration
- **Required methods**: `logEvent()`, `setUserProperties()`, `setUserId()`, `logScreenView()`

---

## 2. Message Handler (Dummy Implementation)

### Setup
**No external dependencies required** - simulates push notification behavior.

### Integration

**Dummy adapter (see `lib/dummy_adapters/message_handler.dart`):**

```dart
class CustomMessageHandler {
  final DummyAnalyticsAdapter? _analytics;

  CustomMessageHandler({DummyAnalyticsAdapter? analytics})
      : _analytics = analytics;
  
  void send(Message message, BuildContext context) async {
    switch (message.name) {
      case 'start_payment':
        await _handlePayment(message.payload);
        break;
      case 'log_event':
        _handleLogEvent(message.payload);
        break;
      case 'share_product':
        await _handleShare(message.payload);
        break;
      case 'open_url':
        await _handleOpenUrl(message.payload);
        break;
    }
  }

  Future<void> _handlePayment(dynamic message) async {
    final paymentData = message is Map ? Map<String, dynamic>.from(message) : {};
    _analytics?.logEvent('payment_attempt', {
      'success': true,
      'amount': paymentData['amount'],
      'order_id': 'ORDER12345'
    });
  }

  void _handleLogEvent(dynamic message) {
    final data = message is Map ? Map<String, dynamic>.from(message) : {};
    final eventName = data['name'] ?? 'custom_event';
    final params = data['params'] as Map<String, dynamic>?;
    _analytics?.logEvent(eventName, params);
  }
}
```

---

## 3. Payment Service (Dummy Implementation)

### Setup

**No external dependencies required** - simulates payment gateway behavior.

### Integration

**Dummy adapter (see `lib/dummy_adapters/payment_adapter.dart`):**

```dart
class DummyPaymentAdapter {
  Future<Map<String, dynamic>> startPayment({
    required double amount,
    required String userId,
    required String orderId,
  }) async {
    print('💳 Starting payment: \$${amount} for order $orderId');
    
    await Future.delayed(Duration(seconds: 2));
    final success = Random().nextBool();
    
    return success ? {
      'success': true,
      'transactionId': 'txn_dummy_${DateTime.now().millisecondsSinceEpoch}',
      'message': 'Payment successful',
    } : {
      'success': false,
      'message': 'Payment failed (simulated)',
    };
  }
}
```

### Using with Message Bus

```dart
messageBus.on('start_payment', (params) async {
  final result = await paymentAdapter.startPayment(
    amount: params['amount'],
    userId: 'user_demo',
    orderId: params['orderId'],
  );
  
  if (result['success']) {
    analytics.logEvent('payment_success', {'amount': params['amount']});
    DUIAppState().navigateToPage('payment_success');
  }
});
```

---

## 4. API Service (Dummy Implementation)

### Setup
**Uses Dio for HTTP client** - but connects to dummy endpoints.

### Integration

**Dummy service (see `lib/services/api_service.dart`):**

```dart
class ApiService {
  static late Dio _dio;
  static late DummyAnalyticsAdapter _analytics;
  
  static void initialize({required DummyAnalyticsAdapter analytics}) {
    _analytics = analytics;
    _dio = Dio(BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: Duration(seconds: 10),
    ));
  }
  
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await _dio.get('/posts');
      return List<Map<String, dynamic>>.from(response.data.map((post) {
        return {
          'id': post['id'],
          'title': post['title'],
          'price': (post['id'] * 10.0),
          'image': 'https://via.placeholder.com/200x200?text=Product+${post['id']}',
        };
      }));
    } catch (e) {
      _analytics.logEvent('api_error', {'error': e.toString()});
      return []; // Return empty list on error
    }
  }
}
```

---

## 5. Storage Service (Dummy Implementation)

### Setup
**Uses shared_preferences** - but with dummy data simulation.

### Integration

**Dummy service (see `lib/services/storage_service.dart`):**

```dart
class StorageService {
  final SharedPreferences _prefs;
  
  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }
  
  StorageService._(this._prefs);
  
  Future<void> setString(String key, String value) async {
    print('💾 Storing: $key = $value');
    await _prefs.setString(key, value);
  }
  
  String? getString(String key) {
    final value = _prefs.getString(key);
    print('📖 Retrieved: $key = $value');
    return value;
  }
}
```

---

## Custom Widgets Integration

### Overview
Custom widgets allow you to extend Digia UI with native Flutter components for native platform features, third-party packages, and complex UI components.

### Widget Registration Pattern

**1. Create Props Class:**
```dart
class DeliveryTypeWidgetProps {
  final String title;
  final Color color;
  DeliveryTypeWidgetProps({required this.title, required this.color});
  
  static DeliveryTypeWidgetProps fromJson(Map<String, dynamic> json) {
    return DeliveryTypeWidgetProps(
      title: json['title'] as String,
      color: Color(int.parse(json['color'].replaceFirst('#', '0xff'))),
    );
  }
}
```

**2. Create Widget Class:**
```dart
class DeliveryTypeStatus extends VirtualLeafStatelessWidget<DeliveryTypeWidgetProps> {
  DeliveryTypeStatus({required super.props, required super.commonProps, 
    required super.parent, required super.refName});

  @override
  Widget render(RenderPayload payload) {
    return DeliveryTypeStatusCustomWidget(title: props.title, color: props.color);
  }
}
```

**3. Register with DUIFactory:**
```dart
void registerDeliveryTypeStatusCustomWidgets() {
  DUIFactory().registerWidget<DeliveryTypeWidgetProps>(
    'custom/deliverytype-1BsfGx', //slug
    DeliveryTypeWidgetProps.fromJson,
    (props, childGroups) => DeliveryTypeStatus(
      props: props, commonProps: null, parent: null, refName: 'custom_deliveryType',
    ),
  );
}
```

**4. Call Registration in App Init:**
```dart
// WRONG - Don't call before Digia UI is initialized
void main() async {
  registerDeliveryTypeStatusCustomWidgets(); // ❌ DUIFactory not ready yet
  runApp(MyApp());
}

// CORRECT - Method 1: DigiaUIAppBuilder (Automatic Init)
void main() async {
  runApp(DigiaUIAppBuilder(
    options: DigiaUIOptions(...),
    builder: (context, status) {
      if (status.isLoading) return LoadingWidget();
      
      // ✅ Register after Digia UI is ready
      registerDeliveryTypeStatusCustomWidgets();
      
      return MyApp();
    },
  ));
}

// CORRECT - Method 2: DigiaUIApp (Manual Init)
void main() async {
  // Initialize Digia UI manually
  final digiaUI = await DigiaConfig.initialize();
  
  runApp(DigiaUIApp(
    digiaUI: digiaUI,
    builder: (context) {
      // ✅ Register after Digia UI is ready
      registerDeliveryTypeStatusCustomWidgets();
      
      return MyApp();
    },
  ));
}
```

### When to Use Custom Widgets vs Digia UI

| Scenario | Use Digia UI | Use Custom Widget |
|----------|--------------|-------------------|
| Product Card | ✅ | ❌ |
| Shopping Cart | ✅ | ❌ |
| Camera Button | ❌ | ✅ |
| Payment Form | ❌ | ✅ |
| GPS Location | ❌ | ✅ |

---

## Best Practices

### 1. Always Extend DUIAnalytics for Analytics
✅ **Good:** Extend DUIAnalytics and override required methods  
❌ **Bad:** Create standalone analytics class

### 2. Use Adapter Pattern for All External Services
✅ **Good:** Create adapter layer (e.g., `DummyAnalyticsAdapter`)  
❌ **Bad:** Use services directly in Digia pages

### 3. Route Everything Through Message Bus
✅ **Good:** Digia pages → Message Bus → Adapter → Service  
❌ **Bad:** Digia pages → Direct service calls

### 4. Handle Errors Gracefully
```dart
try {
  await payment.startPayment(...);
} catch (e) {
  analytics.logEvent('payment_error', {'error': e.toString()});
  DUIAppState().update('paymentError', 'Payment failed');
}
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

// After (real Firebase)
class FirebaseAnalyticsAdapter extends DUIAnalytics {
  final FirebaseAnalytics _firebase = FirebaseAnalytics.instance;
  
  @override
  void logEvent(String name, Map<String, dynamic>? parameters) {
    _firebase.logEvent(name: name, parameters: parameters);
  }
  
  // ... implement other required methods
}
```

---

## Message Handling with callExternalMethod

### Setup Message Handler

**Use DigiaMessageHandlerMixin for clean message handling:**

```dart
class _MyAppState extends State<MyApp> with DigiaMessageHandlerMixin {
  @override
  void initState() {
    super.initState();
    addMessageHandler('start_payment', _handlePayment);
    addMessageHandler('share_product', _handleShare);
    addMessageHandler('open_url', _handleOpenUrl);
    addMessageHandler('log_event', _handleLogEvent);
  }

  Future<void> _handlePayment(dynamic message) async {
    print('[Payment] Starting payment: $message');
    // Integrate with payment gateway
  }

  Future<void> _handleShare(dynamic message) async {
    final data = message is Map ? Map<String, dynamic>.from(message) : {};
    print('[Share] Would share: ${data['text']}');
  }

  Future<void> _handleOpenUrl(dynamic message) async {
    final url = message is String ? message : message['url'];
    print('[URL] Opening: $url');
  }

  void _handleLogEvent(dynamic message) {
    final event = message is Map ? Map<String, dynamic>.from(message) : {};
    print('[Analytics] Event: ${event['name']}');
  }
}
```

### Using callExternalMethod in Digia Studio

**Payment Example:**
```json
{
  "widget": "Button",
  "props": {"text": "Start Payment"},
  "events": {
    "onPressed": {
      "action": "callExternalMethod",
      "channel": "start_payment",
      "data": {"amount": "{{totalPrice}}", "orderId": "{{orderId}}"}
    }
  }
}
```

---

## Next Steps

- See [Getting Started](getting-started.md) for running the app
- See [State Management](state-management.md) for DUIAppState patterns
- See [Flavors Guide](flavors-guide.md) for environment configuration
- See [Custom Widgets](../lib/widgets/README.md) for widget development guide
