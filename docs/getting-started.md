# Getting Started with ProductHub Demo

This guide walks you through setting up and running the ProductHub demo app.

## Prerequisites

- Flutter SDK (2.18.0 or later)
- Dart SDK (2.18.0 or later)
- IDE: VS Code or Android Studio
- Digia Studio account and access key

## Installation

### 1. Navigate to Project Directory

The ProductHub demo is located at:
```bash
cd /Users/ram/Digia/product_hub
```

### 2. Install Dependencies

```bash
fvm flutter pub get
```

### 3. Configure Digia Access Key

Edit `lib/config/app_config.dart`:

```dart
class AppConfig {
  static String getAccessKey() {
    // Replace with your actual Digia Studio access key
    return 'YOUR_DIGIA_ACCESS_KEY_HERE';
  }
  
  // ... other configuration
}
```

### 4. Download Digia Assets (Optional)

For production builds, download these files from Digia Studio:
- `app_config.json`
- `functions.json`

Place them in the `assets/` directory.

## Running the App

```bash
fvm flutter run
```


## Understanding the Demo

### Integration Patterns Demonstrated

1. **Automatic Initialization** (`AutomaticInitExample`)
   - Uses `DigiaUIAppBuilder` for simple setup
   - Automatic loading states and error handling
   - Best for: New apps, splash screens

2. **Manual Initialization** (`ManualInitExample`) 
   - Uses `DigiaUIScope` for full control
   - Custom loading states and error handling
   - Best for: Complex apps, dependency injection

### Key Components

- **Cart Screen**: Demonstrates component embedding with Digia UI components in native Flutter
- **Custom Widgets**: `DeliveryTypeStatus` shows how to register native widgets for Digia Studio
- **Message Handler**: Implements Native ↔ Digia communication patterns
- **Analytics Adapter**: Placeholder for analytics integration

### Configuration Files

- `lib/config/app_config.dart` - App-wide configuration
- `lib/config/digia_config.dart` - Digia SDK initialization
- `assets/app_config.json` - Digia Studio configuration (download from Studio)
- `assets/functions.json` - Custom functions (download from Studio)

## Troubleshooting

### Common Issues

1. **"DigiaUIManager is not initialized"**
   - Ensure you've set a valid access key in `app_config.dart`
   - Check that DigiaUI.initialize() completed successfully

2. **Missing assets in release mode**
   - Download `app_config.json` and `functions.json` from Digia Studio
   - Place them in the `assets/` directory

3. **Custom widgets not appearing**
   - Ensure `registerDeliveryTypeStatusCustomWidgets()` is called after SDK initialization and within the context of `DigiaUIAppBuilder` or `DigiaUIApp`
   - Check the widget ID matches in Digia Studio

### Debug Tips

- Use `fvm flutter run --debug` for detailed logging
- Check console output for Digia SDK initialization messages
- Verify network connectivity for Digia Studio assets

## Next Steps

- Explore the [main.dart](../lib/main.dart) file to understand initialization patterns
- Check [cart_screen.dart](../lib/screens/cart_screen.dart) for component embedding examples
- Review [message_handler.dart](../lib/dummy_adapters/message_handler.dart) for communication patterns
- Read the [widgets README](../lib/widgets/README.md) for custom widget guidelines

## Support

- 📧 Email: admin@digia.tech
- 📖 [Digia Documentation](../../../digiaDocs/docs/jargon/sdk-integration-flutter/getting-started.md)
