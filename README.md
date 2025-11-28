# ProductHub Demo - Comprehensive Digia SDK Integration

A full-featured e-commerce demo app showcasing **all Digia UI SDK integration patterns and use cases**.

## 🎯 What This Demo Covers

This example demonstrates every major SDK integration scenario:

### Integration Patterns (4 Modes)
- ✅ **Full Digia App** - Entire UI from Digia Studio
- ✅ **Hybrid Mode** - Native Flutter + Digia pages mixed
- ✅ **Component Embedding** - Digia components in native screens
- ✅ **Custom Widgets** - Native widgets registered for Digia Studio

### Flavors & Init Strategies (Complete Coverage)
- ✅ `Flavor.debug` with branch switching
- ✅ `Flavor.staging` for QA
- ✅ `Flavor.versioned` for A/B testing
- ✅ `Flavor.release` with NetworkFirst / CacheFirst / LocalFirst strategies

### State Management (All Patterns)
- ✅ Global state via `DUIAppState()`
- ✅ Page-level state
- ✅ Component state
- ✅ Reactive updates with `StreamBuilder`
- ✅ Bidirectional sync (Native ↔ Digia)

### Dummy Service Integrations
- ✅ Analytics Adapter (placeholder for Firebase Analytics)
- ✅ Message Handler (Native ↔ Digia communication)
- ✅ API Service (placeholder for Dio HTTP client)
- ✅ Storage Service (placeholder for SharedPreferences)
- ✅ Custom Widgets (DeliveryTypeStatus example)

### Advanced Features
- ✅ Custom widgets registration
- ✅ Environment variables
- ✅ Message bus for Native ↔ Digia communication
- ✅ Analytics integration
- ✅ Font configuration
- ✅ Asset management

## 🚀 Quick Start

### Prerequisites
- Flutter SDK ≥ 2.18.0
- Digia Studio account and access key

### Installation

1. **Navigate to the project directory:**
   ```bash
   cd /Users/ram/Digia/product_hub
   ```

2. **Install dependencies:**
   ```bash
   fvm flutter pub get
   ```

3. **Configure access key:**
   
   Edit `lib/config/app_config.dart`:
   ```dart
   static String getAccessKey() {
     // Return your Digia Studio access key
     return 'YOUR_DIGIA_ACCESS_KEY';
   }
   ```

4. **Run the app:**
   ```bash
   # Debug mode (default)
   fvm flutter run
   
   # With specific environment
   fvm flutter run --dart-define=ENVIRONMENT=staging
   ```

## 📋 Integration Modes

### Mode 1: Full Digia App
Entire app UI managed by Digia Studio. Perfect for maximum flexibility and OTA updates.

**Features:**
- All screens loaded from Digia Studio
- Zero native UI code
- Complete OTA update capability

### Mode 2: Hybrid Mode
Mix of native Flutter screens and Digia pages. Best for gradual migration or specific native requirements.

**Features:**
- Native splash/onboarding
- Digia-powered catalog, search, product pages
- Native profile/settings
- Seamless navigation between native and Digia

### Mode 3: Component Embedding
Native Flutter app embedding specific Digia components. Ideal for enhancing existing apps.

**Features:**
- Fully native app structure
- Digia components for specific widgets (product cards, filters, etc.)
- Maximum control over app architecture

### Mode 4: Custom Widgets
Register native Flutter widgets for use in Digia Studio. Use only when Digia UI cannot provide required functionality.

**Features:**
- Native platform features (camera, GPS, sensors)
- Third-party Flutter packages
- Performance-critical custom logic
- Specialized components missing from Digia UI

**Example Use Cases:**
- Camera integration for product photos
- GPS-based delivery tracking
- Biometric authentication
- Custom payment flows
- Third-party SDK integrations (maps, analytics, etc.)

**See Also:** [Custom Widgets Guide](docs/custom-widgets-guide.md) for implementation details.

## 🎨 Example Flows

### State Bridging Example

**From Native to Digia:**
```dart
// After user logs in
DUIAppState().update('user', {
  'id': user.id,
  'name': user.name,
  'email': user.email,
  'avatar': user.avatarUrl,
});
DUIAppState().update('isLoggedIn', true);
```

**From Digia to Native:**
```dart
// Listen to cart updates
DUIAppState().listen('cartCount', (count) {
  setState(() => _cartBadgeCount = count);
});
```

### Message Bus Communication

**In Digia Studio (Action):**
```json
{
  "action": "callExternalMethod",
  "channel": "open_cart",
  "data": {
    "productId": "${productId}"
  }
}
```

**In Native Code:**
```dart
// From lib/dummy_adapters/message_handler.dart
void send(Message message, BuildContext context) async {
  final name = message.name;
  final payload = message.payload;
  
  switch (name) {
    case 'open_cart':
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CartScreenByDigiaUI(),
        ),
      );
      break;
  }
}
```

### Custom Widget Registration

```dart
// From lib/widgets/delivery_type_status.dart
void registerDeliveryTypeStatusCustomWidgets() {
  DUIFactory().registerWidget<DeliveryTypeWidgetProps>(
    'custom/deliverytype-1BsfGx', // ID in Digia Studio
    DeliveryTypeWidgetProps.fromJson,
    (props, childGroups) => DeliveryTypeStatus(
      props: props,
      commonProps: null,
      parent: null,
      refName: 'custom_deliveryType',
    ),
  );
}
```

## 🔧 Flavor Configuration

### Development (Debug)
```bash
fvm flutter run
```
- Real-time updates from server
- Hot reload support
- Branch-specific testing

### Staging
```bash
fvm flutter run --dart-define=ENVIRONMENT=staging
```
- Stable configuration for QA
- Pre-production testing

### Production (Release)
```bash
# 1. Download assets from Digia Studio
# 2. Place in assets/ directory
# 3. Build:
fvm flutter build apk --release
```

## 📁 Project Structure

```
product_hub/
├── lib/
│   ├── main.dart                    # Entry point with integration examples
│   ├── config/
│   │   ├── app_config.dart          # App configuration & access keys
│   │   ├── digia_config.dart        # Digia initialization logic
│   │   └── environment.dart         # Environment-specific settings
│   ├── dummy_adapters/
│   │   ├── analytics_adapter.dart   # Analytics integration placeholder
│   │   └── message_handler.dart     # Message bus implementation
│   ├── screens/
│   │   ├── cart_screen.dart         # Cart screen with Digia components
│   │   └── home_page.dart           # Home page
│   ├── services/
│   │   └── api_service.dart         # API client placeholder
│   └── widgets/
│       ├── delivery_type_status.dart # Custom widget example
│       └── README.md                # Widget documentation
├── assets/
│   ├── app_config.json              # Digia config (download from Studio)
│   └── functions.json               # JS functions (download from Studio)
├── fonts/                           # Custom fonts
├── docs/
│   ├── getting-started.md           # Setup guide
│   ├── flavors-guide.md             # Flavor configuration details
│   ├── state-management.md          # State patterns explained
│   ├── third-party-sdks.md          # SDK integration guides
│   └── troubleshooting.md           # Common issues
├── scripts/
│   ├── build-debug.sh               # Build debug variant
│   ├── build-staging.sh             # Build staging variant
│   └── build-release.sh             # Build production release
├── pubspec.yaml                     # Dependencies (minimal dummy services)
└── README.md                        # This file
```

## 📚 Documentation

- [Getting Started Guide](docs/getting-started.md) - Detailed setup instructions
- [Custom Widgets Guide](docs/custom-widgets-guide.md) - Registering native widgets for Digia Studio
- [Third-Party SDKs](docs/third-party-sdks.md) - SDK integration guides
- [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions

## 🔗 Links

- [Digia Documentation](../../../digiaDocs/docs/jargon/sdk-integration-flutter/getting-started.md)
- [Digia Studio](https://app.digia.tech)
- [Flutter Documentation](https://flutter.dev/docs)

## 📄 License

This example is provided for demonstration purposes. See LICENSE for details.

## 💬 Support

- 📧 Email: admin@digia.tech
- 📖 Docs: https://docs.digia.tech
