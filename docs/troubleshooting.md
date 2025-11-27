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

1. **Ensure DigiaUIAppBuilder is used in main.dart:**

```dart
// In main.dart
return DigiaUIAppBuilder(
  options: DigiaUIOptions(
    accessKey: AppConfig.getAccessKey(),
    flavor: DigiaConfig.getFlavor(),
  ),
  builder: (context, status) {
    if (status.isLoading) {
      return LoadingScreen();
    }
    
    if (status.hasError) {
      return ErrorScreen(error: status.error);
    }
    
    return MaterialApp(home: DUIFactory().createInitialPage());
  },
);
```

2. **For demo mode (without real SDK):**

Uncomment the Digia initialization in `digia_config.dart` and provide mock access keys.

---

### Error: "Access key required"

**Symptoms:**
```
Error: Access key is required for Digia SDK initialization
```

**Cause:** No access key provided.

**Solution:**

**Option 1: Set via dart-define (recommended)**

```bash
flutter run --dart-define=DIGIA_ACCESS_KEY_DEBUG=your_debug_key
```

**Option 2: Set in code (not recommended for production)**

```dart
// In app_config.dart
static String getAccessKey() {
  return 'your_debug_key'; // Hardcoded (demo only)
}
```

---

### Error: "Failed to fetch config from Studio"

**Symptoms:**
```
Error: Network error: Failed to connect to Studio
```

**Cause:** Network issue or invalid Studio URL.

**Solution:**

1. **Check internet connection**

2. **Verify Studio URL in flavor config:**

```dart
// In digia_config.dart
Flavor.debug(
  studioUrl: 'https://studio.digia.io/api', // Check this URL
);
```

3. **Use LocalFirst init strategy for offline development:**

```dart
initStrategy: InitStrategy.localFirst();
```

4. **Check firewall/proxy settings**

---

## Page Loading Issues

### Error: "Page not found"

**Symptoms:**
```
Error: Page with ID 'catalog' not found
```

**Cause:** Page doesn't exist in Digia Studio or not downloaded.

**Solution:**

1. **Check page ID in Studio**

2. **Download latest assets:**

```bash
# In production, download assets from Studio
curl -o assets/digia.zip "https://studio.digia.io/api/assets/download?key=YOUR_KEY"
unzip assets/digia.zip -d assets/
```

3. **Use correct init strategy:**

For development, use `NetworkFirst` to always fetch latest:

```dart
initStrategy: InitStrategy.networkFirst();
```

---

### Blank Screen After Navigation

**Symptoms:**
App navigates but shows blank screen.

**Cause:** Page not loaded or navigation error.

**Solution:**

1. **Check console for errors:**

```
flutter run --verbose
```

2. **Verify navigation in Studio:**

```json
{
  "action": "navigate",
  "page": "catalog"  // Must match page ID in Studio
}
```

3. **Check DUIAppState:**

```dart
print(DUIAppState.of(context).getAllState());
```

---

## State Management Issues

### State Not Updating in Digia Pages

**Symptoms:**
Native code updates state, but Digia pages don't reflect changes.

**Cause:** State not set correctly or page not reactive.

**Solution:**

1. **Use DUIAppState.setState():**

```dart
// ✅ Correct
DUIAppState.of(context).setState('cartItemCount', 5);

// ❌ Wrong
someOtherStateManager.set('cartItemCount', 5);
```

2. **Verify page uses reactive bindings in Studio:**

```json
{
  "widget": "Text",
  "props": {
    "text": "Cart: {{state.cartItemCount}}"  // Double curly braces
  }
}
```

3. **Check state key matches:**

```dart
// Native code
DUIAppState.setState('cartItemCount', 5);

// Studio
{{state.cartItemCount}}  // Must match key exactly
```

---

### Native Screen Not Reflecting State Changes

**Symptoms:**
Digia pages update state, but native screens don't update.

**Cause:** Native screen not listening to state changes.

**Solution:**

**Add listener in native screen:**

```dart
@override
void initState() {
  super.initState();
  
  // Listen to state changes
  DUIAppState.of(context).addListener('cartItemCount', (value) {
    setState(() {
      _cartCount = value ?? 0;
    });
  });
}
```

---

## Message Bus Issues

### Message Bus Handler Not Called

**Symptoms:**
Digia page sends message, but handler doesn't execute.

**Cause:** Channel name mismatch or handler not registered.

**Solution:**

1. **Check channel name matches:**

```dart
// In message_bus_adapter.dart
messageBus.on('start_payment', (params) { ... });

// In Digia Studio
{
  "action": "messageBus",
  "channel": "start_payment"  // Must match exactly
}
```

2. **Verify message bus is initialized:**

```dart
// In main.dart
final messageBus = AppMessageBus(analytics: analytics);

await DigiaConfig.initialize(
  messageBus: messageBus,  // Pass to Digia
);
```

3. **Check handler is registered before page loads:**

```dart
void main() async {
  final messageBus = AppMessageBus();
  messageBus.registerHandlers(); // Register before Digia init
  
  await DigiaConfig.initialize(messageBus: messageBus);
}
```

---

### Error: "Unknown message bus channel"

**Symptoms:**
```
Error: Unknown channel: custom_action
```

**Cause:** Channel not handled in message bus adapter.

**Solution:**

**Add handler in message_bus_adapter.dart:**

```dart
void on(String channel, Map<String, dynamic> params) {
  switch (channel) {
    case 'start_payment':
      _handlePayment(params);
      break;
    
    case 'custom_action':  // Add your channel
      _handleCustomAction(params);
      break;
    
    default:
      print('[MessageBus] Unknown channel: $channel');
  }
}
```

---

## Payment Integration Issues

### Payment Always Failing

**Symptoms:**
All payment attempts fail.

**Cause:** Mock payment adapter has random failures, or real payment SDK not configured.

**Solution:**

1. **For demo mode (mock adapter):**

The mock adapter has 90% success rate. Try multiple times.

```dart
// In payment_adapter.dart (demo)
final success = DateTime.now().second % 10 != 0; // 90% success
```

2. **For production:**

Configure real Gokwik API keys:

```dart
// In payment_adapter.dart
final response = await http.post(
  Uri.parse('https://api.gokwik.co/payment/initiate'),
  headers: {
    'Authorization': 'Bearer YOUR_GOKWIK_API_KEY',
  },
);
```

---

### Payment Screen Not Showing

**Symptoms:**
Payment initiation doesn't show payment UI.

**Cause:** Payment URL not opened.

**Solution:**

**Open payment URL in webview:**

```dart
final result = await paymentAdapter.startPayment(...);

if (result['success']) {
  final paymentUrl = result['paymentUrl'];
  
  // Open in webview or browser
  await launchUrl(Uri.parse(paymentUrl));
}
```

---

## Asset Loading Issues

### Images Not Loading

**Symptoms:**
Image widgets show placeholder or broken image icon.

**Cause:** Image URL invalid or network issue.

**Solution:**

1. **Check image URL:**

```dart
Image.network(
  'https://example.com/image.jpg',
  errorBuilder: (context, error, stackTrace) {
    print('Image load error: $error');
    return Icon(Icons.error);
  },
);
```

2. **Use cached network image:**

```yaml
dependencies:
  cached_network_image: ^3.3.0
```

```dart
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
);
```

---

### Fonts Not Loading

**Symptoms:**
Custom fonts not displaying.

**Cause:** Font files not included in pubspec.yaml.

**Solution:**

1. **Add fonts to pubspec.yaml:**

```yaml
flutter:
  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/CustomFont-Regular.ttf
        - asset: assets/fonts/CustomFont-Bold.ttf
          weight: 700
```

2. **Use in code:**

```dart
TextStyle(fontFamily: 'CustomFont')
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

1. **Clean and get dependencies:**

```bash
flutter clean
flutter pub get
```

2. **Update packages:**

```bash
flutter pub upgrade
```

3. **Check pubspec.yaml for conflicts:**

Remove version constraints or use compatible versions.

---

### Build Failed: "Missing AndroidManifest permissions"

**Symptoms:**
```
Error: INTERNET permission not found
```

**Cause:** Required permissions missing from AndroidManifest.xml.

**Solution:**

**Add permissions to android/app/src/main/AndroidManifest.xml:**

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

---

## Runtime Issues

### App Crashes on Startup

**Symptoms:**
App crashes immediately after launch.

**Cause:** Initialization error or missing dependency.

**Solution:**

1. **Check logs:**

```bash
flutter run --verbose
```

2. **Verify Firebase initialization:**

```dart
// In main.dart
await Firebase.initializeApp(); // Must be before runApp()
```

3. **Check for null safety issues:**

```dart
final user = DUIAppState.of(context).getState('user');
print(user?['name']); // Use null-aware operators
```

---

### Hot Reload Not Working

**Symptoms:**
Changes not reflected after hot reload.

**Cause:** State persisted or hot reload limitation.

**Solution:**

1. **Use hot restart instead:**

Press `Shift + R` in terminal or click hot restart button.

2. **For state issues, clear state:**

```dart
DUIAppState.of(context).clearAllState();
```

---

## Performance Issues

### Slow App Startup

**Symptoms:**
App takes long to start.

**Cause:** NetworkFirst strategy or heavy initialization.

**Solution:**

1. **Use CacheFirst strategy:**

```dart
initStrategy: InitStrategy.cacheFirst(
  backgroundRefresh: true,
);
```

2. **Lazy load heavy dependencies:**

```dart
// Load Firebase messaging after app starts
Future.delayed(Duration(seconds: 2), () {
  FirebaseMessaging.instance.requestPermission();
});
```

---

### Memory Leaks

**Symptoms:**
App memory usage keeps increasing.

**Cause:** Listeners not disposed.

**Solution:**

1. **Dispose listeners:**

```dart
@override
void dispose() {
  DUIAppState.of(context).removeListener('cartItemCount');
  _controller.dispose();
  super.dispose();
}
```

2. **Use weak references for long-lived objects**

---

## Getting Help

### Enable Verbose Logging

```bash
flutter run --verbose
```

### Check Digia SDK Logs

```dart
// In app_config.dart
AppConfig.enableDebugLogs = true;

// In digia_config.dart
Flavor.debug(
  logLevel: LogLevel.verbose,
);
```

### Print State for Debugging

```dart
print('All state: ${DUIAppState.of(context).getAllState()}');
print('User: ${DUIAppState.of(context).getState('user')}');
```

---

## Support Resources

- **Main README:** [../README.md](../README.md)
- **Getting Started:** [getting-started.md](getting-started.md)
- **State Management:** [state-management.md](state-management.md)
- **Third-Party SDKs:** [third-party-sdks.md](third-party-sdks.md)
- **Digia Docs:** https://docs.digia.io
- **Digia Support:** support@digia.io
