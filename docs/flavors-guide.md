# Flavors and Init Strategies Guide

Complete guide to Digia flavors, environments, and initialization strategies.

## Overview

ProductHub demo supports:
- **4 Flavors:** debug, staging, versioned, release
- **3 Environments:** development, staging, production
- **2 Init Methods:** DigiaUIAppBuilder, Manual + DigiaUIApp

## Flavors

### Debug Flavor

**Purpose:** Local development with debugging features

**Features:**
- Development environment with full debugging
- Branch and environment tracking
- Development overlays and tools

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
  branchName: AppConfig.branch,
  environment: AppConfig.environment,
);
```

---

### Staging Flavor

**Purpose:** Pre-production testing environment

**Features:**
- Production-like behavior
- Limited debugging features
- Used for QA and integration testing

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
  branchName: AppConfig.branch,
  environment: AppConfig.environment,
);
```

---

### Versioned Flavor

**Purpose:** Version-controlled releases

**Features:**
- Specific version pinning
- Reproducible builds
- Enterprise deployments

**When to use:**
- Beta testing specific versions
- Rollback testing
- Version comparison

**Usage:**
```bash
flutter run --dart-define=ENV=staging --dart-define=VERSION=1.2.3
```

**Configuration:**
```dart
Flavor.versioned(
  environment: AppConfig.environment,
  version: '1.2.3',
);
```

---

### Release Flavor

**Purpose:** Production deployment

**Features:**
- Optimized for performance
- Minimal debugging overhead
- Secure configuration

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
  branchName: AppConfig.branch,
  environment: AppConfig.environment,
);
```

---

## Initialization Methods

### DigiaUIAppBuilder (Recommended)

**How it works:**
1. Automatic SDK initialization
2. Built-in loading and error states
3. Builder pattern for custom UI
4. Handles all lifecycle management

**When to use:**
- New Digia-first apps
- Simple initialization
- Built-in loading/error handling

**Pros:**
- Automatic initialization
- Built-in loading states
- Simple to use
- Handles errors gracefully

**Cons:**
- Less control over initialization
- Fixed loading/error UI

**Configuration:**
```dart
DigiaUIAppBuilder(
  options: DigiaUIOptions(
    accessKey: AppConfig.getAccessKey(),
    flavor: DigiaConfig.getFlavor(),
  ),
  analytics: analytics,
  builder: (context, status) {
    if (status.isLoading) {
      return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
    }
    if (status.hasError) {
      return MaterialApp(home: Scaffold(body: Center(child: Text('Error: ${status.error}'))));
    }
    // SDK ready - register widgets and return app
    registerDeliveryTypeStatusCustomWidgets();
    return MaterialApp(home: HomePage());
  },
);
```

---

### Manual + DigiaUIApp

**How it works:**
1. Manual SDK initialization with DigiaUI.initialize()
2. Custom loading/error handling
3. Full control over initialization process
4. Wrap with DigiaUIApp for context

**When to use:**
- Existing Flutter apps
- Hybrid native + Digia integration
- Custom loading/error UI
- Gradual migration

**Pros:**
- Full control over initialization
- Custom loading/error UI
- Lazy loading possible
- Hybrid app support

**Cons:**
- More complex setup
- Manual error handling
- More boilerplate code

**Configuration:**
```dart
// Initialize manually
final digiaUI = await DigiaUI.initialize(
  DigiaUIOptions(
    accessKey: AppConfig.getAccessKey(),
    flavor: DigiaConfig.getFlavor(),
  ),
);

// Wrap with DigiaUIApp
DigiaUIApp(
  digiaUI: digiaUI,
  builder: (context) {
    registerDeliveryTypeStatusCustomWidgets();
    return MaterialApp(home: HomePage());
  },
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
- DigiaUIAppBuilder or Manual initialization
- Verbose logging

---

### Staging Environment

```bash
flutter run --dart-define=ENV=staging --dart-define=INTEGRATION_MODE=hybrid
```

**Uses:**
- Staging flavor
- Staging API: `https://api-staging.producthub.com`
- DigiaUIAppBuilder (recommended)
- Info-level logging

---

### Production Environment

```bash
flutter build apk --dart-define=ENV=prod --dart-define=INTEGRATION_MODE=fullDigia
```

**Uses:**
- Release flavor
- Production API: `https://api.producthub.com`
- DigiaUIAppBuilder (recommended)
- Error-only logging

---

## Choosing the Right Setup

### For Daily Development
```bash
ENV=dev + Debug Flavor + DigiaUIAppBuilder
```

Fast iteration, automatic initialization, development tools.

---

### For QA Testing
```bash
ENV=staging + Staging Flavor + DigiaUIAppBuilder
```

Production-like behavior, built-in error handling.

---

### For Beta Testing
```bash
ENV=staging + Versioned Flavor + DigiaUIAppBuilder
```

Version-pinned releases, reproducible builds.

---

### For Production
```bash
ENV=prod + Release Flavor + DigiaUIAppBuilder
```

Optimized performance, automatic initialization.

---

### For Hybrid Apps
```bash
ENV=dev + Debug Flavor + Manual + DigiaUIApp
```

Full control, custom loading UI, gradual migration.

---

## Advanced Configuration

### Custom Flavor Selection

```dart
// In digia_config.dart
Flavor getFlavor() {
  switch (AppConfig.environment) {
    case 'dev':
      return Flavor.debug(
        branchName: AppConfig.branch,
        environment: AppConfig.environment,
      );
    
    case 'staging':
      return Flavor.staging(
        branchName: AppConfig.branch,
        environment: AppConfig.environment,
      );
    
    case 'prod':
      return Flavor.release(
        branchName: AppConfig.branch,
        environment: AppConfig.environment,
      );
    
    default:
      return Flavor.debug(
        branchName: 'main',
        environment: 'dev',
      );
  }
}
```

---

### Custom DigiaUIOptions

```dart
DigiaUIOptions(
  accessKey: AppConfig.getAccessKey(),
  flavor: DigiaConfig.getFlavor(),
  // Optional: Add network configuration
  // networkConfiguration: NetworkConfiguration(
  //   timeout: Duration(seconds: 15),
  //   retryCount: 2,
  // ),
);
```

---

## Testing Different Configurations

### Test DigiaUIAppBuilder

```bash
flutter run --dart-define=ENV=dev
```

Expected: Automatic initialization, built-in loading states.

---

### Test Manual Initialization

```bash
flutter run --dart-define=ENV=dev
```

Expected: Custom loading UI, full initialization control.

---

### Test Offline Mode

```bash
# Turn off internet, then run:
flutter run --dart-define=ENV=dev
```

Expected: Graceful error handling, fallback behavior.

---

## Quick Reference

| Flavor | Environment | Init Method | Use Case |
|--------|-------------|-------------|----------|
| Debug | Development | DigiaUIAppBuilder | Daily dev |
| Debug | Development | Manual + DigiaUIApp | Hybrid dev |
| Staging | Staging | DigiaUIAppBuilder | QA testing |
| Versioned | Staging | DigiaUIAppBuilder | Beta testing |
| Release | Production | DigiaUIAppBuilder | Production |

---

## Next Steps

- See [State Management](state-management.md) for DUIAppState patterns
- See [Third-Party SDKs](third-party-sdks.md) for Firebase/Gokwik setup
- See [Getting Started](getting-started.md) for running the app
