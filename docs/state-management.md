# State Management Guide

Complete guide to managing state in ProductHub demo with Digia.

## Overview

ProductHub demonstrates 4 state management patterns:

1. **Global App State** - DUIAppState for app-wide data
2. **Page State** - Page-level state from Digia Studio
3. **Component State** - Component-level state within pages
4. **Native-to-Digia Sync** - Bridging native and Digia state

---

## 1. Global App State (DUIAppState)

### What is DUIAppState?

`DUIAppState` is Digia's global state container accessible from:
- Digia pages and widgets
- Native Flutter code
- Message bus handlers

### Setting Global State

```dart
// From native code
DUIAppState().update('user', {
  'id': 'user_123',
  'name': 'John Doe',
  'email': 'john@example.com',
});

DUIAppState().update('cartItemCount', 5);
DUIAppState().update('isLoggedIn', true);
```

### Getting Global State

```dart
// From native code
final user = DUIAppState().getValue('user');
final cartCount = DUIAppState().getValue('cartItemCount') ?? 0;
final isLoggedIn = DUIAppState().getValue('isLoggedIn') ?? false;

print('User: ${user['name']}, Cart: $cartCount');
```

### Listening to State Changes

```dart
// Note: Listener API may vary by Digia UI version
// Check Digia UI documentation for current listener patterns

// Example pattern (may not be accurate):
// DUIAppState().addListener('user', (value) {
//   print('User changed: $value');
//   // Update native UI
// });

// For reactive updates, consider using StreamBuilder or ValueNotifier
// with periodic state checks
```

---

## 2. Page State (Studio-Defined)

### How Page State Works

Pages in Digia Studio have their own state defined in the Studio UI:

```json
{
  "pageState": {
    "products": [],
    "loading": true,
    "selectedFilter": "all",
    "searchQuery": ""
  }
}
```

### Accessing Page State from Native

```dart
// Get page state from Digia page
// Note: API may vary - check Digia UI documentation
final pageState = DUIAppState().getValue('page.catalog_page');
// or
final pageState = DUIAppState().getValue('catalog_page_state');

final products = pageState?['products'] ?? [];
final isLoading = pageState?['loading'] ?? false;
```

### Updating Page State

Page state is typically updated by:
- User interactions in Digia pages (handled by Studio)
- API responses (configured in Studio)
- Message bus events

**Example:** Product added to cart triggers state update:

```dart
// In a widget with DigiaMessageHandlerMixin
class _CartHandlerState extends State<CartHandler> with DigiaMessageHandlerMixin {
  @override
  void initState() {
    super.initState();
    
    // Register message handler for add_to_cart events from Digia components
    addMessageHandler('add_to_cart', (message) async {
      final productId = message['productId'];
      
      // Update global cart count
      final currentCount = DUIAppState().getValue('cartItemCount') ?? 0;
      DUIAppState().update('cartItemCount', currentCount + 1);
      
      // Call API to add to cart
      await apiService.addToCart(productId: productId, quantity: 1);
      
      // Log analytics
      analytics.logEvent(name: 'add_to_cart', parameters: {'product_id': productId});
    });
  }
}
```

---

## 3. Component State

### Local Component State

Components in Digia pages have local state (like Flutter's StatefulWidget):

**Studio Configuration:**
```json
{
  "widget": "ProductCard",
  "state": {
    "isFavorite": false,
    "quantity": 1
  },
  "events": {
    "onFavoriteToggle": {
      "action": "setState",
      "params": {
        "isFavorite": "!state.isFavorite"
      }
    }
  }
}
```

### Component State from Native

When embedding Digia components in native screens:

```dart
// Create component with parameters
final productCard = DUIFactory().createComponent(
  'product_card',
  {
    'productId': 'prod_123',
  },
);

// Note: initialState cannot be set during component creation
// State should be managed through DUIAppState or message handlers
```

---

## 4. Native-to-Digia State Sync

### Problem

Native code and Digia pages need to share state (e.g., user login, cart count).

### Solution

Use `DUIAppState` as the single source of truth.

### Example: User Login Flow

**1. User logs in via native screen:**

```dart
// In auth_service.dart
Future<void> signIn(String email, String password) async {
  final user = await _authAdapter.signIn(email, password);
  
  // Sync to DUIAppState
  DUIAppState().update('user', user);
  DUIAppState().update('isLoggedIn', true);
  
  _analytics.setUserId(userId: user['id']);
}
```

**2. Digia pages access user state:**

In Studio, pages can access `state.user`:

```json
{
  "widget": "Text",
  "props": {
    "text": "Welcome, {{state.user.name}}!"
  }
}
```

**3. User logs out:**

```dart
// In auth_service.dart
Future<void> signOut() async {
  await _authAdapter.signOut();
  
  // Clear from DUIAppState
  DUIAppState().update('user', null);
  DUIAppState().update('isLoggedIn', false);
}
```

---

### Example: Cart Count Sync

**1. Add to cart from Digia page:**

Message handler in native code receives events from Digia components:

```dart
// In a widget with DigiaMessageHandlerMixin
class _CartManagerState extends State<CartManager> with DigiaMessageHandlerMixin {
  @override
  void initState() {
    super.initState();
    
    addMessageHandler('add_to_cart', (message) async {
      final productId = message['productId'];
      
      // Call API
      await apiService.addToCart(productId: productId, quantity: 1);
      
      // Update DUIAppState (accessible by native + Digia)
      final currentCount = DUIAppState().getValue('cartItemCount') ?? 0;
      DUIAppState().update('cartItemCount', currentCount + 1);
      
      // Log analytics
      analytics.logEvent(name: 'add_to_cart', parameters: {'product_id': productId});
    });
  }
}
```

**2. Native cart badge updates automatically:**

```dart
// In native AppBar
class _HomeState extends State<Home> with DigiaMessageHandlerMixin {
  int _cartCount = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize cart count
    _updateCartCount();
    
    // Listen for cart updates via message handlers
    addMessageHandler('cart_updated', (message) {
      _updateCartCount();
    });
  }
  
  void _updateCartCount() {
    setState(() {
      _cartCount = DUIAppState().getValue('cartItemCount') ?? 0;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        Badge(
          label: Text('$_cartCount'),
          child: IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              _updateCartCount(); // Refresh before navigation
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ),
      ],
    );
  }
}
```

**3. Digia pages show updated count:**

```json
{
  "widget": "CartBadge",
  "props": {
    "count": "{{state.cartItemCount}}"
  }
}
```

---

## Common State Patterns

### Pattern 1: User Authentication

```dart
// When user logs in
DUIAppState().update('user', userData);
DUIAppState().update('isLoggedIn', true);
DUIAppState().update('authToken', token);

// When user logs out
DUIAppState().update('user', null);
DUIAppState().update('isLoggedIn', false);
DUIAppState().update('authToken', null);
```

### Pattern 2: API Data

```dart
// Before API call
DUIAppState().update('products', []);
DUIAppState().update('productsLoading', true);

// After API call
final products = await apiService.getProducts();
DUIAppState().update('products', products);
DUIAppState().update('productsLoading', false);
```

### Pattern 3: Feature Flags

```dart
// Set feature flags
DUIAppState().update('features', {
  'newCheckout': true,
  'socialLogin': false,
  'darkMode': true,
});

// Access in Digia pages
// {{state.features.newCheckout ? 'New Checkout' : 'Old Checkout'}}
```

### Pattern 4: App Settings

```dart
// Theme
DUIAppState().update('theme', 'dark');

// Language
DUIAppState().update('language', 'en');

// Notifications
DUIAppState().update('notificationsEnabled', true);
```

---

## State Persistence

### Saving State to Storage

```dart
// Use message handlers to react to state changes
class _StatePersistenceManager extends State<StatePersistenceManager> with DigiaMessageHandlerMixin {
  @override
  void initState() {
    super.initState();
    
    // Listen for user state changes via message bus
    addMessageHandler('user_state_changed', (message) async {
      final user = DUIAppState().getValue('user');
      if (user != null) {
        await storageService.saveUser(user);
      } else {
        await storageService.clearUser();
      }
    });
  }
}

// Alternative: Poll for changes periodically
// or use DUIAppState changes via message handlers from Digia components
```

### Restoring State on App Launch

```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storage = StorageService();
  
  runApp(DigiaUIAppBuilder(
    config: DigiaConfig.initialize(),
    builder: (context, digiaUI) {
      // Register message handlers after Digia UI is ready
      // (This would be in a stateful widget that handles messages)
      
      // Restore user
      final user = storage.getUser();
      if (user != null) {
        DUIAppState().update('user', user);
        DUIAppState().update('isLoggedIn', true);
      }
      
      // Restore theme
      final theme = storage.getThemeMode();
      DUIAppState().update('theme', theme);
      
      return MyApp();
    },
  ));
}
```

---

## Reactive UI Updates

### Auto-Update Pattern

Digia pages automatically re-render when state changes:

```json
{
  "widget": "Text",
  "props": {
    "text": "Cart: {{state.cartItemCount}} items"
  }
}
```

When `cartItemCount` changes, text updates automatically.

---

### Native Reactive Updates

Use `StreamSubscription` or `StreamBuilder` for native screens that react to DUIAppState changes:

```dart
class CartManager {
  static void addToCart(Product product) {
    // Update native state
    cart.add(product);
    
    // Sync with Digia UI
    DUIAppState().update('cartCount', cart.length);
    DUIAppState().update('cartTotal', cart.totalAmount);
    DUIAppState().update('cartItems', cart.items.map((e) => e.toJson()).toList());
  }
}

// Listen in Flutter
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    
    _subscription = DUIAppState().listen('cartCount', (value) {
      setState(() {
        // Update UI
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final count = DUIAppState().getValue('cartCount') ?? 0;
    return Badge(label: Text('$count'), child: Icon(Icons.shopping_cart));
  }
}
```

### StreamBuilder Pattern

For simpler reactive UI without manual state management:

```dart
StreamBuilder<dynamic>(
  stream: DUIAppState().getStream('cartItemCount'),
  initialData: 0,
  builder: (context, snapshot) {
    final count = snapshot.data as int? ?? 0;
    return Badge(
      label: Text('$count'),
      isLabelVisible: count > 0,
      child: IconButton(
        icon: Icon(Icons.shopping_cart),
        onPressed: () => Navigator.pushNamed(context, '/cart'),
      ),
    );
  },
)
```

---

## Debugging State

### Print Current State

```dart
// Print specific state values
print('User: ${DUIAppState().getValue('user')}');
print('Cart: ${DUIAppState().getValue('cartItemCount')}');
print('Theme: ${DUIAppState().getValue('theme')}');
```

### State Logging

```dart
// Note: Logging API may vary by Digia UI version
// DUIAppState().enableLogging();

// Alternative: Manual logging
print('Current state - User: ${DUIAppState().getValue('user')}, Cart: ${DUIAppState().getValue('cartItemCount')}');
```

---

## Best Practices

### 1. Use DUIAppState for Shared Data

✅ **Good:** User, cart, auth token, feature flags
❌ **Bad:** Component-specific UI state

### 2. Keep State Flat

✅ **Good:**
```dart
DUIAppState().update('userId', 'user_123');
DUIAppState().update('userName', 'John Doe');
```

❌ **Bad:**
```dart
DUIAppState().update('user.profile.details.name', 'John Doe');
```

### 3. Sync State Immediately

✅ **Good:**
```dart
await signIn(email, password);
DUIAppState().update('user', user); // Right after login
```

❌ **Bad:**
```dart
await signIn(email, password);
// User navigates, then state set later
```

### 4. Clear State on Logout

✅ **Good:**
```dart
await signOut();
DUIAppState().update('user', null);
DUIAppState().update('authToken', null);
DUIAppState().update('cartItemCount', 0);
```

---

## Next Steps

- See [Getting Started](getting-started.md) for running the app
- See [Third-Party SDKs](third-party-sdks.md) for Firebase/Gokwik integration
- See [Flavors Guide](flavors-guide.md) for environment configuration
