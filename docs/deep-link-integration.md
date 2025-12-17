# Deep Link Integration Guide

This guide explains how to integrate deep linking into the ProductHub demo app using the `app_links` package.

## Overview

Deep linking allows users to open specific screens in your app through URLs. This is useful for:
- Sharing specific content
- Push notifications
- QR codes
- Web-to-app navigation

## Supported Deep Links

The app currently supports these deep link paths:

- `yourapp://home` - Opens the home page
- `yourapp://cart` - Opens the cart screen
- `https://yourdomain.com/home` - Opens the home page (Universal Links/App Links)
- `https://yourdomain.com/cart` - Opens the cart screen (Universal Links/App Links)
- Any other path - Shows a snackbar message and navigates to home

### Web URL Examples

For production apps, use HTTPS URLs that work across platforms:

```bash
# Android (App Links)
adb shell am start -a android.intent.action.VIEW -d "https://yourdomain.com/home"

# iOS (Universal Links) 
xcrun simctl openurl booted "https://yourdomain.com/cart"
```

Web URLs provide better user experience as they work in browsers and can fallback gracefully if the app isn't installed.

## Setup

### 1. Add Dependencies

Add the `app_links` package to your `pubspec.yaml`:

```yaml
dependencies:
  app_links: ^3.5.0
```

### 2. Configure Android Deep Links

Add intent filters to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
  <application ...>
    <activity ...>
      <!-- Deep Links -->
      <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="https"
              android:host="yourdomain.com" />
        <data android:scheme="yourapp" />
      </intent-filter>
    </activity>
  </application>
</manifest>
```

### 3. Configure iOS Deep Links

Add URL schemes to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>your.bundle.id</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>yourapp</string>
      <string>https</string>
    </array>
  </dict>
</array>
<key>FlutterDeepLinkingEnabled</key>
<true/>
```

## Implementation

### AppLinksHandler Class

The implementation is available at [`lib/services/app_links_handler.dart`](../lib/services/app_links_handler.dart).

Key features:
- Handles deep links when app is running or launched from terminated state
- Supports navigation to HomePage and CartScreenByDigiaUI
- Shows user-friendly messages for unrecognized links
- Proper cleanup with dispose() method

### Initialize in main.dart

Add deep link initialization to your `main.dart`. The implementation uses the StatefulWidget's lifecycle methods:

```dart
import 'package:producthub_demo/services/app_links_handler.dart';

class ManualInitExample extends StatefulWidget {
  // ... constructor and other methods

  @override
  State<ManualInitExample> createState() => _ManualInitExampleState();
}

class _ManualInitExampleState extends State<ManualInitExample> {
  @override
  void initState() {
    super.initState();
    // Initialize deep links after the first frame when context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppLinksHandler.initialize(context);
    });
  }

  @override
  void dispose() {
    AppLinksHandler.dispose();
    super.dispose();
  }

  // ... rest of the build method
}
```

The initialization happens in `initState()` using `addPostFrameCallback` to ensure the context is available, and cleanup occurs in `dispose()`. This approach works with both Stateless and Stateful widgets that have access to the build context.

## Testing Deep Links

### Android Testing

```bash
adb shell am start -W -a android.intent.action.VIEW -d "yourapp://home" your.package.name
adb shell am start -a android.intent.action.VIEW -d "yourapp://cart"
```

### iOS Testing

```bash
xcrun simctl openurl booted "yourapp://home"
xcrun simctl openurl booted "yourapp://cart"
```

## Troubleshooting

### Deep Links Not Working

1. **Check URL Scheme:** Ensure your URL scheme is correctly registered in both Android and iOS configurations.

2. **Verify Package Name:** Make sure the package name in AndroidManifest matches your app's package name.

3. **Test with ADB:** Use ADB commands to test deep links directly.

4. **Check Logs:** Look for "Received deep link" messages in your app logs.

### App Not Launching

1. **Clear App Data:** Sometimes cached data can interfere with deep links.

2. **Reinstall App:** Uninstall and reinstall the app after configuration changes.

3. **Check Intent Filters:** Ensure intent filters are properly configured in AndroidManifest.xml.

## Advanced Usage

### Adding New Deep Link Routes

To add support for new routes, update the switch statement in `AppLinksHandler.handleDeepLink()`:

```dart
case 'profile':
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(builder: (_) => ProfileScreen()),
  );
  break;
```

### Handling Parameters

For routes with parameters, parse additional path segments:

```dart
case 'product':
  if (pathSegments.length > 1) {
    String productId = pathSegments[1];
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => ProductScreen(productId: productId)),
    );
  }
  break;
```

### Query Parameters

Access query parameters from the URI for additional data:

```dart
case 'product':
  if (pathSegments.length > 1) {
    String productId = pathSegments[1];
    // Access query parameters
    String? userId = uri.queryParameters['user_id'];
    String? token = uri.queryParameters['token'];
    String? source = uri.queryParameters['source']; // e.g., 'push', 'email', 'qr'
    
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => ProductScreen(
          productId: productId,
          userId: userId,
          token: token,
          source: source,
        ),
      ),
    );
  }
  break;
```

## Best Practices

1. **Handle Edge Cases:** Always provide fallbacks for malformed URLs.

2. **User Feedback:** Show appropriate messages for unrecognized links.

3. **Security:** Validate parameters before using them.

4. **Analytics:** Track deep link usage for analytics.

5. **Testing:** Test on both platforms and different app states (foreground/background/terminated).

## Related Documentation

- [app_links Package Documentation](https://pub.dev/packages/app_links)
- [Android Deep Links](https://developer.android.com/training/app-links/deep-linking)
- [iOS Universal Links](https://developer.apple.com/ios/universal-links/)
- [Flutter Navigation](https://docs.flutter.dev/ui/navigation)</content>