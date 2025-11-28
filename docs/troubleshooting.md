# Troubleshooting Guide

Common issues and solutions when working with ProductHub demo.

---

## SDK Initialization Issues

### Error: "Digia SDK not initialized"

**Symptoms:**
```
Error: DUIAppState is not available. Make sure DigiaUIApp is initialized.
```

**Cause:** Digia SDK not initialized before accessing DUIAppState.

**Solution:**

ProductHub uses two initialization methods. Make sure you're using one correctly:

**Method 1: DigiaUIAppBuilder (Used in main.dart)**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.loadConfig();

  final analytics = DummyAnalyticsAdapter();
  final messageHandler = CustomMessageHandler(analytics: analytics);
  ApiService.initialize(analytics: analytics);

  runApp(DigiaUIAppBuilder(
    options: DigiaUIOptions(
      accessKey: AppConfig.getAccessKey(),
      flavor: DigiaConfig.getFlavor(),
    ),
    analytics: analytics,
    builder: (context, status) {
      if (status.isLoading) {
        return MaterialApp(
          home: Scaffold(
            backgroundColor: Color(0xFF673AB7),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 24),
                  Text('Loading...', style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
          ),
        );
      }
      if (status.hasError) {
        return MaterialApp(
          home: Scaffold(body: Center(child: Text('Error: ${status.error}'))),
        );
      }

      DUIFactory().setEnvironmentVariables({
        'accessToken': AppConfig.shopifyAccessToken,
        'storeName': AppConfig.shopifyStoreName,
      });
      registerDeliveryTypeStatusCustomWidgets();

      return MaterialApp(
        title: 'ProductHub - Digia UI Demo',
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        home: MessageHandlerWrapper(
          messageHandler: messageHandler,
          child: const HomePage(),
        ),
      );
    },
  ));
}
```

**Method 2: Manual + DigiaUIApp (Alternative in main.dart)**
```dart
class ManualInitExample extends StatefulWidget {
  @override
  State<ManualInitExample> createState() => _ManualInitExampleState();
}

class _ManualInitExampleState extends State<ManualInitExample> {
  late Future<DigiaUI> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = DigiaConfig.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DigiaUI>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
        }
        if (snapshot.hasError) {
          return MaterialApp(home: Scaffold(body: Center(child: Text('Error: ${snapshot.error}'))));
        }

        return DigiaUIApp(
          digiaUI: snapshot.data!,
          builder: (context) {
            registerDeliveryTypeStatusCustomWidgets();
            DUIFactory().setEnvironmentVariables({
              'accessToken': AppConfig.shopifyAccessToken,
              'storeName': AppConfig.shopifyStoreName,
            });
            return MaterialApp(home: HomePage());
          },
        );
      },
    );
  }
}
```

---

### Error: "Access key required"

**Symptoms:**
```
Error: Access key is required for Digia SDK initialization
```

**Cause:** No access key provided in configuration.

**Solution:**

**Option 1: Environment variable (recommended)**
```bash
flutter run --dart-define=DIGIA_ACCESS_KEY_DEBUG=your_key_here
```

**Option 2: app_config.json file**
```json
{
  "digiaAccessKey": "your_key_here",
  "shopifyAccessToken": "your_shopify_token",
  "shopifyStoreName": "your_store_name"
}
```

**Check AppConfig.getAccessKey() implementation:**
The app tries multiple sources in order:
1. `DIGIA_ACCESS_KEY_DEBUG` environment variable
2. `app_config.json` file
3. Demo fallback key

---

### Error: "Failed to fetch config from Studio"

**Symptoms:**
```
Error: Network error: Failed to connect to Studio
```

**Cause:** Network issue or invalid access key.

**Solution:**

1. **Check internet connection**

2. **Verify access key is valid**

3. **Ensure AppConfig.loadConfig() is called:**
```dart
// Must be called before DigiaConfig.initialize()
await AppConfig.loadConfig();
```

4. **Check DigiaConfig.initialize() parameters:**
```dart
// From digia_config.dart
return await DigiaUI.initialize(
  DigiaUIOptions(
    accessKey: AppConfig.getAccessKey(),
    flavor: DigiaConfig.getFlavor(),
  ),
);
```

---

## Page Loading Issues

### Error: "Page not found"

**Symptoms:**
```
Error: Page with ID 'catalog' not found
```

**Cause:** Page doesn't exist in Digia Studio or incorrect initialization.

**Solution:**

1. **Check Digia Studio project has the required pages**

2. **Verify Digia UI initialization completed:**
Ensure `DigiaUIAppBuilder` or `DigiaUIApp` completed successfully.

3. **Check component creation methods:**
The demo uses:
- `DUIFactory().createInitialPage()`
- `DUIFactory().createComponent()`

4. **Verify access permissions:**
Make sure your access key has permission to access the pages.

---

### Blank Screen After Navigation

**Symptoms:**
App navigates but shows blank screen.

**Cause:** Navigation state not set or Digia UI context missing.

**Solution:**

1. **Check console logs:**
```bash
flutter run --verbose
```

2. **Verify DUIAppState navigation:**
```dart
print('Navigation state: ${DUIAppState().getValue('currentPage')}');
```

3. **Ensure navigation happens within Digia UI context:**
Navigation only works inside `DigiaUIAppBuilder` or `DigiaUIApp`.

4. **Check MessageHandlerWrapper:**
The demo uses `MessageHandlerWrapper` with `DigiaMessageHandlerMixin` for navigation messages.

---

## State Management Issues

### State Not Updating in Digia Pages

**Symptoms:**
Native code updates state, but Digia pages don't reflect changes.

**Cause:** Incorrect state key or page not reactive.

**Solution:**

1. **Use DUIAppState.update() correctly:**
```dart
// ✅ Correct - used throughout the demo
DUIAppState().update('cartItemCount', 5);
DUIAppState().update('user', {'name': 'John', 'id': '123'});
```

2. **Verify Digia Studio page bindings:**
```json
{
  "widget": "Text",
  "props": {
    "text": "Cart: {{state.cartItemCount}}"
  }
}
```

3. **Check state key matches exactly:**
Native: `DUIAppState().update('cartItemCount', 5)`
Studio: `{{state.cartItemCount}}`

---

### Native Screen Not Reflecting State Changes

**Symptoms:**
Digia pages update state, but native screens don't update.

**Cause:** Native screen not listening to state changes.

**Solution:**

**Use DUIAppState.listen() for reactive updates:**

```dart
class _MyWidgetState extends State<MyWidget> {
  late StreamSubscription _subscription;
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    _subscription = DUIAppState().listen('cartItemCount', (value) {
      setState(() => _cartCount = value ?? 0);
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Badge(label: Text('$_cartCount'), child: Icon(Icons.shopping_cart));
  }
}
```

**Alternative: Use message handlers (as implemented in demo):**

```dart
class _MyWidgetState extends State<MyWidget> with DigiaMessageHandlerMixin {
  @override
  void initState() {
    super.initState();
    addMessageHandler('cart_updated', (message) {
      setState(() {
        // Update based on message
      });
    });
  }
}
```

---

## Message Bus Issues

### Message Handler Not Called

**Symptoms:**
Digia page sends message, but handler doesn't execute.

**Cause:** Channel name mismatch or handler not registered.

**Solution:**

1. **Check channel names match:**

The demo uses `DigiaMessageHandlerMixin` in `MessageHandlerWrapper`:

```dart
// From lib/main.dart
addMessageHandler('start_payment', (message) {
  widget.messageHandler.send(message, context);
});

addMessageHandler('update_cart', (message) {
  widget.messageHandler.send(message, context);
});
```

2. **Verify Digia Studio action:**
```json
{
  "action": "callExternalMethod",
  "channel": "start_payment",
  "data": {"amount": "{{totalPrice}}"}
}
```

3. **Ensure MessageHandlerWrapper is in widget tree:**
The demo wraps `HomePage` with `MessageHandlerWrapper`.

---

### Error: "Unknown message channel"

**Symptoms:**
```
Error: Unknown channel: custom_action
```

**Cause:** Channel not handled in message handler.

**Solution:**

**Add handler to MessageHandlerWrapper:**

```dart
class _MessageHandlerWrapperState extends State<MessageHandlerWrapper>
    with DigiaMessageHandlerMixin {
  @override
  void initState() {
    super.initState();

    // Existing handlers...
    addMessageHandler('start_payment', (message) {
      widget.messageHandler.send(message, context);
    });

    // Add your custom handler
    addMessageHandler('custom_action', (message) {
      print('[MessageHandler] Custom action: $message');
      _handleCustomAction(message);
    });
  }

  void _handleCustomAction(dynamic message) {
    // Your custom logic here
  }
}
```
---

## Build Issues

### Build Failed: "Dependency conflict"

**Symptoms:**
```
Error: Version solving failed.
```

**Cause:** Incompatible package versions.

**Solution:**

1. **Clean and reinstall:**
```bash
flutter clean
flutter pub get
```

2. **Update packages:**
```bash
flutter pub upgrade
```

3. **Check pubspec.yaml conflicts**

---

### Build Failed: "Missing AndroidManifest permissions"

**Symptoms:**
```
Error: INTERNET permission not found
```

**Cause:** Required permissions missing.

**Solution:**

**Add to android/app/src/main/AndroidManifest.xml:**
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

---

## Runtime Issues

### App Crashes on Startup

**Symptoms:**
App crashes immediately after launch.

**Cause:** Initialization failure or missing configuration.

**Solution:**

1. **Check logs:**
```bash
flutter run --verbose
```

2. **Verify AppConfig.loadConfig():**
```dart
// Must be called first in main()
await AppConfig.loadConfig();
```

3. **Check assets/app_config.json exists**

4. **Verify DigiaConfig.initialize() succeeds**

---

### Hot Reload Not Working

**Symptoms:**
Changes not reflected after hot reload.

**Cause:** State persistence or hot reload limitations.

**Solution:**

1. **Use hot restart instead:**
Press `Shift + R` in terminal.

2. **Clear problematic state:**
```dart
DUIAppState().update('user', null);
DUIAppState().update('cartItemCount', 0);
```

---

## Performance Issues

### Slow App Startup

**Symptoms:**
App takes long to start.

**Cause:** Digia UI initialization or heavy setup.

**Solution:**

1. **Check DigiaConfig.initialize() timing**

2. **Move heavy initialization after app start:**
```dart
Future.delayed(Duration(seconds: 2), () {
  // Initialize heavy services
});
```

3. **Ensure no blocking operations in init**

---

### Memory Leaks

**Symptoms:**
Memory usage keeps increasing.

**Cause:** Undisposed listeners or subscriptions.

**Solution:**

**Always dispose DUIAppState listeners:**

```dart
class _MyWidgetState extends State<MyWidget> {
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = DUIAppState().listen('cartItemCount', (value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _subscription.cancel(); // ✅ Essential
    super.dispose();
  }
}
```

---

## Getting Help

### Enable Verbose Logging

```bash
flutter run --verbose
```

### Check Demo-Specific Logs

Look for these debug messages:
- `[ProductHub] Starting Digia UI Demo`
- `[ProductHub] Environment: dev`
- `[DummyAnalyticsAdapter]` messages
- `[MessageHandler]` messages

### Debug State Values

```dart
print('User: ${DUIAppState().getValue('user')}');
print('Cart: ${DUIAppState().getValue('cartItemCount')}');
print('Logged in: ${DUIAppState().getValue('isLoggedIn')}');
```

---

## Support Resources

- **Main README:** [../README.md](../README.md)
- **Getting Started:** [getting-started.md](getting-started.md)
- **Third-Party SDKs:** [third-party-sdks.md](third-party-sdks.md)
- **Digia Docs:** https://docs.digia.io
- **Digia Support:** support@digia.io
