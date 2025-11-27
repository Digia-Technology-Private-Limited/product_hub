# Flavors and Init Strategies Guide

Complete guide to Digia flavors, environments, and initialization strategies.

## Overview

ProductHub demo supports:
- **4 Flavors:** debug, staging, versioned, release
- **3 Environments:** development, staging, production
- **3 Init Strategies:** NetworkFirst, CacheFirst, LocalFirst

## Flavors

### Debug Flavor

**Purpose:** Local development with hot reload

**Features:**
- Loads config from local dev server
- Hot reload enabled
- Debug logging verbose
- No asset caching
- Local backend API

**When to use:**
- Daily development
- Testing new features
- Debugging issues

**Usage:**
```bash
flutter run --dart-define=ENV=dev
```

**Configuration:**
```dart
// In digia_config.dart
Flavor.debug(
  studioUrl: 'http://localhost:3000/api',
  enableHotReload: true,
  logLevel: LogLevel.verbose,
  cachingEnabled: false,
);
```

---

### Staging Flavor

**Purpose:** QA testing before production

**Features:**
- Loads config from staging Studio
- Caching enabled
- Standard logging
- Staging backend API
- Mimics production behavior

**When to use:**
- QA testing
- Pre-release validation
- Client demos

**Usage:**
```bash
flutter run --dart-define=ENV=staging
```

**Configuration:**
```dart
Flavor.staging(
  studioUrl: 'https://staging.studio.digia.io/api',
  cachingEnabled: true,
  cacheExpiry: Duration(minutes: 30),
  logLevel: LogLevel.info,
);
```

---

### Versioned Flavor

**Purpose:** Beta testing with version pinning

**Features:**
- Loads specific version from Studio
- Falls back to local assets if network fails
- Version-pinned config
- Production-like caching
- Useful for A/B testing

**When to use:**
- Beta testing specific versions
- Rollback testing
- Version comparison
- Gradual rollouts

**Usage:**
```bash
flutter run --dart-define=ENV=staging --dart-define=VERSION=1.2.3
```

**Configuration:**
```dart
Flavor.versioned(
  version: '1.2.3',
  studioUrl: 'https://studio.digia.io/api',
  cachingEnabled: true,
  fallbackToLocal: true,
);
```

---

### Release Flavor

**Purpose:** Production apps

**Features:**
- Loads from production Studio
- Aggressive caching
- Minimal logging
- Production backend API
- OTA updates enabled

**When to use:**
- Production builds
- App Store releases

**Usage:**
```bash
flutter build apk --dart-define=ENV=prod
```

**Configuration:**
```dart
Flavor.release(
  studioUrl: 'https://studio.digia.io/api',
  cachingEnabled: true,
  cacheExpiry: Duration(hours: 24),
  logLevel: LogLevel.error,
  enableOTAUpdates: true,
);
```

---

## Init Strategies

### NetworkFirst Strategy

**How it works:**
1. Fetch latest config from Studio
2. Update local cache
3. Use fetched config
4. If network fails, fallback to cache

**When to use:**
- You need latest updates immediately
- Network is generally reliable
- OTA updates are critical

**Pros:**
- Always up-to-date
- Users see latest changes immediately

**Cons:**
- Slower startup if network is slow
- Requires internet connection for first launch

**Configuration:**
```dart
initStrategy: InitStrategy.networkFirst(
  timeout: Duration(seconds: 10),
  fallbackToCache: true,
);
```

**Example:**
```dart
DigiaUIApp(
  flavor: Flavor.release(),
  initStrategy: InitStrategy.networkFirst(
    timeout: Duration(seconds: 10),
  ),
);
```

---

### CacheFirst Strategy (Recommended)

**How it works:**
1. Load config from cache (if available)
2. Show UI immediately
3. Fetch latest config in background
4. Update UI when new config arrives

**When to use:**
- Fast startup is priority
- Users don't need instant updates
- Best for most production apps

**Pros:**
- Instant startup
- Good offline experience
- Background updates

**Cons:**
- Users may see old UI briefly
- Updates delayed slightly

**Configuration:**
```dart
initStrategy: InitStrategy.cacheFirst(
  backgroundRefresh: true,
  refreshInterval: Duration(hours: 6),
);
```

**Example:**
```dart
DigiaUIApp(
  flavor: Flavor.release(),
  initStrategy: InitStrategy.cacheFirst(
    backgroundRefresh: true,
  ),
);
```

---

### LocalFirst Strategy

**How it works:**
1. Always use bundled local assets
2. Never fetch from network
3. No OTA updates

**When to use:**
- Offline-first apps
- No OTA updates needed
- Fully static UI
- Maximum performance

**Pros:**
- Fastest startup
- Works completely offline
- No network dependency

**Cons:**
- No OTA updates
- Requires app update for UI changes

**Configuration:**
```dart
initStrategy: InitStrategy.localFirst(
  assetsPath: 'assets/digia/',
);
```

**Example:**
```dart
DigiaUIApp(
  flavor: Flavor.debug(),
  initStrategy: InitStrategy.localFirst(),
);
```

---

## Environment Configuration

### Development Environment

```bash
flutter run --dart-define=ENV=dev --dart-define=INTEGRATION_MODE=hybrid
```

**Uses:**
- Debug flavor
- Local API: `http://localhost:8000/api`
- NetworkFirst or LocalFirst strategy
- Verbose logging

---

### Staging Environment

```bash
flutter run --dart-define=ENV=staging --dart-define=INTEGRATION_MODE=hybrid
```

**Uses:**
- Staging flavor
- Staging API: `https://api-staging.producthub.com`
- CacheFirst strategy (recommended)
- Info-level logging

---

### Production Environment

```bash
flutter build apk --dart-define=ENV=prod --dart-define=INTEGRATION_MODE=fullDigia
```

**Uses:**
- Release flavor
- Production API: `https://api.producthub.com`
- CacheFirst strategy (recommended)
- Error-only logging

---

## Choosing the Right Setup

### For Daily Development
```bash
ENV=dev + Debug Flavor + NetworkFirst Strategy
```

Fast iteration, hot reload, latest Studio changes.

---

### For QA Testing
```bash
ENV=staging + Staging Flavor + CacheFirst Strategy
```

Production-like behavior, stable testing.

---

### For Beta Testing
```bash
ENV=staging + Versioned Flavor + CacheFirst Strategy
```

Version-pinned releases, easy rollbacks.

---

### For Production
```bash
ENV=prod + Release Flavor + CacheFirst Strategy
```

Fast startup, background updates, stable.

---

## Advanced Configuration

### Custom Init Strategy Selection

```dart
// In digia_config.dart
InitStrategy _getInitStrategy() {
  // Use NetworkFirst for debug (always fresh)
  if (AppConfig.environment == 'dev') {
    return InitStrategy.networkFirst(timeout: Duration(seconds: 10));
  }
  
  // Use CacheFirst for staging and production (fast startup)
  return InitStrategy.cacheFirst(
    backgroundRefresh: true,
    refreshInterval: Duration(hours: 6),
  );
}
```

---

### Environment-Specific Flavors

```dart
Flavor _getFlavor() {
  switch (AppConfig.environment) {
    case 'dev':
      return _getDebugFlavor();
    
    case 'staging':
      return _getStagingFlavor();
    
    case 'prod':
      return _getReleaseFlavor();
    
    default:
      return _getDebugFlavor();
  }
}
```

---

## Testing Different Configurations

### Test NetworkFirst with Debug

```bash
flutter run --dart-define=ENV=dev
```

Expected: App fetches latest from Studio, fast iterations.

---

### Test CacheFirst with Staging

```bash
flutter run --dart-define=ENV=staging
```

Expected: App loads from cache instantly, updates in background.

---

### Test LocalFirst (Offline)

```bash
# Turn off internet, then run:
flutter run --dart-define=ENV=dev
```

Expected: App works completely offline using bundled assets.

---

## Quick Reference

| Flavor | Environment | Init Strategy | Use Case |
|--------|-------------|---------------|----------|
| Debug | Development | NetworkFirst | Daily dev |
| Debug | Development | LocalFirst | Offline dev |
| Staging | Staging | CacheFirst | QA testing |
| Versioned | Staging | CacheFirst | Beta testing |
| Release | Production | CacheFirst | Production |

---

## Next Steps

- See [State Management](state-management.md) for DUIAppState patterns
- See [Third-Party SDKs](third-party-sdks.md) for Firebase/Gokwik setup
- See [Getting Started](getting-started.md) for running the app
