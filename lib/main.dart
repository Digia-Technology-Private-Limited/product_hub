import 'package:digia_ui/digia_ui.dart';
import 'package:flutter/material.dart';
import 'package:producthub_demo/screens/home_page.dart';
import 'package:producthub_demo/widgets/delivery_type_status.dart';
import 'package:producthub_demo/services/api_service.dart';

import 'config/app_config.dart';
import 'config/digia_config.dart';
import 'dummy_adapters/analytics_adapter.dart';
import 'dummy_adapters/message_handler.dart';
import 'services/app_links_handler.dart';

// ====================================================================================
// PRODUCT HUB - DIGIA UI SDK INTEGRATION DEMO
// ====================================================================================
///
/// Comprehensive demo of Digia UI integration patterns using a single Cart Screen
///
/// DIGIA UI TOUCHPOINTS DEMONSTRATED:
/// See individual documentation files for detailed guides:
/// - [Component Creation](docs/component-creation.md) - DUIFactory().createComponent() and createInitialPage()
/// - [Custom Widget Registration](docs/custom-widget-registration.md) - Extend Digia with Flutter widgets
/// - [Event Handling](docs/event-handling.md) - onTap, onChange, form submissions
/// - [PostMessage Communication](docs/postmessage-communication.md) - Native Digia communication & DigiaMessageHandlerMixin
/// - [State Management](docs/state-management.md) - DUIAppState for shared state
/// - [Analytics Integration](docs/analytics-integration.md) - fire Event tracking integration
/// - [Environment Variables](docs/design-system-access.md) - access or set environment variables
///
/// INTEGRATION METHODS:
/// - Method 1: DigiaUIAppBuilder (automatic init, simpler)
/// - Method 2: Manual init + DigiaUIScope (more control, recommended)
///
/// ====================================================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppConfig.loadConfig();

  print('[ProductHub] Starting Digia UI Demo');
  print('[ProductHub] Environment: ${AppConfig.environment}');

  final analytics = DummyAnalyticsAdapter();
  final messageHandler = CustomMessageHandler(analytics: analytics);
  ApiService.initialize(analytics: analytics);

  // Choose integration method:
  // Method 1: Automatic initialization with DigiaUIAppBuilder
  // Method 2: Manual initialization with DigiaUIScope (used below)
  runApp(ManualInitExample(
    analytics: analytics,
    messageHandler: messageHandler,
  ));
}

// ====================================================================================
// METHOD 1: Automatic Initialization with DigiaUIAppBuilder
// ====================================================================================
///
/// Use this for apps that are 100% Digia UI
/// - Automatic SDK initialization
/// - Built-in loading/error states
/// - Simpler integration
///
/// To use: Change runApp() above to use AutomaticInitExample
///
class AutomaticInitExample extends StatelessWidget {
  final DummyAnalyticsAdapter analytics;
  final CustomMessageHandler messageHandler;

  const AutomaticInitExample({
    super.key,
    required this.analytics,
    required this.messageHandler,
  });

  @override
  Widget build(BuildContext context) {
    return DigiaUIAppBuilder(
      options: DigiaUIOptions(
        accessKey: AppConfig.getAccessKey(),
        flavor: DigiaConfig.getFlavor(),
      ),
      analytics: analytics,
      builder: (context, status) {
        if (status.isLoading) {
          return const MaterialApp(
            home: Scaffold(
              backgroundColor: Color(0xFF673AB7),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 24),
                    Text(
                      'Loading...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (status.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error: ${status.error}'),
              ),
            ),
          );
        }

        DUIFactory().setEnvironmentVariables({
          'accessToken': AppConfig.shopifyAccessToken,
          'storeName': AppConfig.shopifyStoreName,
        });
        registerDeliveryTypeStatusCustomWidgets();
        // SDK initialized - can use DUIFactory and DUIAppState
        return MaterialApp(
          title: 'ProductHub - Digia UI Demo',
          theme: ThemeData(primarySwatch: Colors.deepPurple),
          home: MessageHandlerWrapper(
            messageHandler: messageHandler,
            child: const HomePage(),
          ),
        );
      },
    );
  }
}

// ====================================================================================
// METHOD 2: Manual Initialization with DigiaUIScope
// ====================================================================================
///
/// Use this for hybrid apps (native + Digia UI)
/// - Manual SDK initialization control
/// - Custom loading/error handling
/// - Requires DigiaUIScope wrapper
/// - Perfect for gradual migration
///
class ManualInitExample extends StatefulWidget {
  final DummyAnalyticsAdapter analytics;
  final CustomMessageHandler messageHandler;

  const ManualInitExample({
    super.key,
    required this.analytics,
    required this.messageHandler,
  });

  @override
  State<ManualInitExample> createState() => _ManualInitExampleState();
}

class _ManualInitExampleState extends State<ManualInitExample> {
  late Future<DigiaUI> _initFuture;

  @override
  void initState() {
    super.initState();
    // Manually initialize Digia UI SDK
    _initFuture = DigiaConfig.initialize();
    // Initialize deep links here - context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppLinksHandler.initialize(context);
    });
  }

  @override
  void dispose() {
    AppLinksHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DigiaUI>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              backgroundColor: Color(0xFF673AB7),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 24),
                    Text(
                      'Initializing Digia UI...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _initFuture = DigiaConfig.initialize();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Success - Wrap with DigiaUIScope to provide Digia context
        return DigiaUIApp(
            digiaUI: snapshot.data!,
            builder: (context) {
              registerDeliveryTypeStatusCustomWidgets();
              DUIFactory().setEnvironmentVariables({
                'accessToken': AppConfig.shopifyAccessToken,
                'storeName': AppConfig.shopifyStoreName,
              });
              return MaterialApp(
                title: 'ProductHub - Digia UI Demo',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  primarySwatch: Colors.deepPurple,
                  useMaterial3: true,
                ),
                home: MessageHandlerWrapper(
                  messageHandler: widget.messageHandler,
                  child: const HomePage(),
                ),
              );
            });
      },
    );
  }
}

// ====================================================================================
// DigiaMessageHandlerMixin Usage Example
// ====================================================================================
///
/// Demonstrates how to use DigiaMessageHandlerMixin to receive messages
/// from Digia UI components.
///
/// IMPORTANT: This mixin must be used on widgets that are descendants
/// of DigiaUIScope or within DigiaUIAppBuilder context.
///
class MessageHandlerWrapper extends StatefulWidget {
  final CustomMessageHandler messageHandler;
  final Widget child;

  const MessageHandlerWrapper({
    super.key,
    required this.messageHandler,
    required this.child,
  });

  @override
  State<MessageHandlerWrapper> createState() => _MessageHandlerWrapperState();
}

/// Apply DigiaMessageHandlerMixin to receive messages from Digia components
class _MessageHandlerWrapperState extends State<MessageHandlerWrapper>
    with DigiaMessageHandlerMixin {
  @override
  void initState() {
    super.initState();

    // Register handlers for specific message channels
    // These will receive postMessage calls from Digia UI components

    addMessageHandler('start_payment', (message) {
      print('[MessageHandler] Payment initiated: $message');
      widget.messageHandler.send(message, context);
    });

    addMessageHandler('update_cart', (message) {
      print('[MessageHandler] Cart update: $message');
      widget.messageHandler.send(message, context);
    });

    addMessageHandler('open_cart', (message) {
      print('[MessageHandler] Cart: $message');
      widget.messageHandler.send(message, context);
    });

    addMessageHandler('analytics_event', (message) {
      print('[MessageHandler] Analytics event: $message');
      widget.messageHandler.send(message, context);
    });

    addMessageHandler('navigation', (message) {
      print('[MessageHandler] Navigation request: $message');
      // Handle navigation based on message payload
    });
  }

  @override
  Widget build(BuildContext context) {
    // This wrapper just passes through the child
    // but provides message handling capability
    return widget.child;
  }
}

// ====================================================================================
// INTEGRATION METHOD COMPARISON
// ====================================================================================
/// 
/// ┌──────────────────────────────────────────────────────────────────────┐
/// │ Feature              │ DigiaUIAppBuilder │ Manual + DigiaUIScope     │
/// ├──────────────────────┼───────────────────┼───────────────────────────┤
/// │ Initialization       │ Automatic         │ Manual                    │
/// │ Loading States       │ Built-in          │ Custom                    │
/// │ Error Handling       │ Built-in          │ Custom                    │
/// │ Complexity           │ Low               │ Medium                    │
/// │ Control              │ Limited           │ Full                      │
/// │ Best For             │ 100% Digia apps   │ Hybrid apps               │
/// │ Lazy Loading         │ No                │ Yes                       │
/// └──────────────────────────────────────────────────────────────────────┘
/// 
/// RECOMMENDATION:
/// - Use DigiaUIAppBuilder (Method 1) for new Digia-first apps
/// - Use Manual + DigiaUIScope (Method 2) for existing Flutter apps
///
/// ====================================================================================
