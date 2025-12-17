import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:producthub_demo/screens/home_page.dart';
import 'package:producthub_demo/screens/cart_screen.dart';

class AppLinksHandler {
  static final _appLinks = AppLinks();
  static StreamSubscription<Uri>? _linkSubscription;

  static void initialize(BuildContext context) {
    // Handle deep link when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        if (context.mounted) handleDeepLink(context, uri);
      },
      onError: (err) {
        print('Deep link error: $err');
      },
    );

    // Handle deep link when app is launched from terminated state
    _getInitialLink(context);
  }

  static Future<void> _getInitialLink(BuildContext context) async {
    try {
      final Uri? uri = await _appLinks.getInitialAppLink();
      if (uri != null && context.mounted) {
        handleDeepLink(context, uri);
      }
    } catch (e) {
      print('Failed to get initial link: $e');
    }
  }

  static void handleDeepLink(BuildContext context, Uri uri) {
    print('Received deep link: ${uri.toString()}');

    // Split the path into segments for path parameters
    List<String> pathSegments = uri.pathSegments;
    print('Path segments: $pathSegments');

    if (pathSegments.isEmpty) {
      _gotoHome(context);
      return;
    }

    // Parse the deep link and navigate accordingly
    switch (pathSegments[0]) {
      case 'home':
        // Navigate to home page
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => const HomePage(),
          ),
        );
        break;
      case 'cart':
        // Navigate to cart screen
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => const CartScreenByDigiaUI(),
          ),
        );
        break;
      default:
        // Show snackbar for unrecognized deep links
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deep link not recognized: ${uri.path}'),
            duration: const Duration(seconds: 3),
          ),
        );
        _gotoHome(context);
    }
  }

  static _gotoHome(BuildContext context) {
    Navigator.of(context, rootNavigator: true)
        .popUntil((route) => route.isFirst);
  }

  static void dispose() {
    _linkSubscription?.cancel();
  }
}
