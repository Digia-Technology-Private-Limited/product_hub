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
DUIAppState.of(context).setState('user', {
  'id': 'user_123',
  'name': 'John Doe',
  'email': 'john@example.com',
});

DUIAppState.of(context).setState('cartItemCount', 5);
DUIAppState.of(context).setState('isLoggedIn', true);
```

### Getting Global State

```dart
// From native code
final user = DUIAppState.of(context).getState('user');
final cartCount = DUIAppState.of(context).getState('cartItemCount') ?? 0;
final isLoggedIn = DUIAppState.of(context).getState('isLoggedIn') ?? false;

print('User: ${user['name']}, Cart: $cartCount');
```

### Listening to State Changes

```dart
DUIAppState.of(context).addListener('user', (value) {
  print('User changed: $value');
  // Update native UI
});

DUIAppState.of(context).addListener('cartItemCount', (value) {
  // Update cart badge
  setState(() {
    _cartBadgeCount = value;
  });
});
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
final pageState = DUIAppState.of(context).getPageState('catalog_page');
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
// In message bus handler
messageBus.on('add_to_cart', (params) async {
  final productId = params['productId'];
  
  // Update global cart count
  final currentCount = DUIAppState.of(context).getState('cartItemCount') ?? 0;
  DUIAppState.of(context).setState('cartItemCount', currentCount + 1);
  
  // Trigger page refresh
  DUIAppState.of(context).refreshPage('catalog_page');
});
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
// Create component with initial state
final productCard = DUIFactory().createComponent(
  'product_card',
  parameters: {
    'productId': 'prod_123',
  },
  initialState: {
    'isFavorite': false,
    'quantity': 1,
  },
);

// Listen to component state changes
productCard.addStateListener((state) {
  print('Component state: $state');
});
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
  DUIAppState.of(context).setState('user', user);
  DUIAppState.of(context).setState('isLoggedIn', true);
  
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
  DUIAppState.of(context).setState('user', null);
  DUIAppState.of(context).setState('isLoggedIn', false);
}
```

---

### Example: Cart Count Sync

**1. Add to cart from Digia page:**

Message bus handler updates global state:

```dart
// In message_bus_adapter.dart
messageBus.on('add_to_cart', (params) async {
  final productId = params['productId'];
  
  // Call API
  await apiService.addToCart(productId: productId, quantity: 1);
  
  // Update DUIAppState (accessible by native + Digia)
  final currentCount = DUIAppState.of(context).getState('cartItemCount') ?? 0;
  DUIAppState.of(context).setState('cartItemCount', currentCount + 1);
  
  // Log analytics
  analytics.logEvent(name: 'add_to_cart', parameters: {'product_id': productId});
});
```

**2. Native cart badge updates automatically:**

```dart
// In native AppBar
class _HomeState extends State<Home> {
  int _cartCount = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Listen to cart count changes
    DUIAppState.of(context).addListener('cartItemCount', (value) {
      setState(() {
        _cartCount = value ?? 0;
      });
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
            onPressed: () => Navigator.pushNamed(context, '/cart'),
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
DUIAppState.of(context).setState('user', userData);
DUIAppState.of(context).setState('isLoggedIn', true);
DUIAppState.of(context).setState('authToken', token);

// When user logs out
DUIAppState.of(context).setState('user', null);
DUIAppState.of(context).setState('isLoggedIn', false);
DUIAppState.of(context).setState('authToken', null);
```

### Pattern 2: API Data

```dart
// Before API call
DUIAppState.of(context).setState('products', []);
DUIAppState.of(context).setState('productsLoading', true);

// After API call
final products = await apiService.getProducts();
DUIAppState.of(context).setState('products', products);
DUIAppState.of(context).setState('productsLoading', false);
```

### Pattern 3: Feature Flags

```dart
// Set feature flags
DUIAppState.of(context).setState('features', {
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
DUIAppState.of(context).setState('theme', 'dark');

// Language
DUIAppState.of(context).setState('language', 'en');

// Notifications
DUIAppState.of(context).setState('notificationsEnabled', true);
```

---

## State Persistence

### Saving State to Storage

```dart
// When state changes, save to storage
DUIAppState.of(context).addListener('user', (user) async {
  if (user != null) {
    await storageService.saveUser(user);
  } else {
    await storageService.clearUser();
  }
});

DUIAppState.of(context).addListener('theme', (theme) async {
  await storageService.setThemeMode(theme);
});
```

### Restoring State on App Launch

```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storage = StorageService();
  
  runApp(MyApp(
    onDigiaReady: (context) {
      // Restore user
      final user = storage.getUser();
      if (user != null) {
        DUIAppState.of(context).setState('user', user);
        DUIAppState.of(context).setState('isLoggedIn', true);
      }
      
      // Restore theme
      final theme = storage.getThemeMode();
      DUIAppState.of(context).setState('theme', theme);
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

Use `ValueNotifier` or `StreamBuilder` for native screens:

```dart
class CartBadge extends StatefulWidget {
  @override
  _CartBadgeState createState() => _CartBadgeState();
}

class _CartBadgeState extends State<CartBadge> {
  late final ValueNotifier<int> _cartCount;
  
  @override
  void initState() {
    super.initState();
    
    final initialCount = DUIAppState.of(context).getState('cartItemCount') ?? 0;
    _cartCount = ValueNotifier(initialCount);
    
    DUIAppState.of(context).addListener('cartItemCount', (value) {
      _cartCount.value = value ?? 0;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _cartCount,
      builder: (context, count, _) {
        return Badge(
          label: Text('$count'),
          child: Icon(Icons.shopping_cart),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _cartCount.dispose();
    super.dispose();
  }
}
```

---

## Debugging State

### Print Current State

```dart
// Print all global state
print(DUIAppState.of(context).getAllState());

// Print specific state
print('User: ${DUIAppState.of(context).getState('user')}');
print('Cart: ${DUIAppState.of(context).getState('cartItemCount')}');
```

### State Logging

```dart
// In app initialization
DUIAppState.of(context).enableLogging();

// Now all state changes are logged:
// [DUIAppState] setState: user = {id: user_123, name: John}
// [DUIAppState] setState: cartItemCount = 5
```

---

## Best Practices

### 1. Use DUIAppState for Shared Data

✅ **Good:** User, cart, auth token, feature flags
❌ **Bad:** Component-specific UI state

### 2. Keep State Flat

✅ **Good:**
```dart
DUIAppState.setState('userId', 'user_123');
DUIAppState.setState('userName', 'John Doe');
```

❌ **Bad:**
```dart
DUIAppState.setState('user.profile.details.name', 'John Doe');
```

### 3. Sync State Immediately

✅ **Good:**
```dart
await signIn(email, password);
DUIAppState.setState('user', user); // Right after login
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
DUIAppState.setState('user', null);
DUIAppState.setState('authToken', null);
DUIAppState.setState('cartItemCount', 0);
```

---

## Next Steps

- See [Getting Started](getting-started.md) for running the app
- See [Third-Party SDKs](third-party-sdks.md) for Firebase/Gokwik integration
- See [Flavors Guide](flavors-guide.md) for environment configuration
