import 'package:digia_ui/digia_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:producthub_demo/services/api_service.dart';

/// Cart Screen with Digia UI Integration - Comprehensive Demo
///
/// This screen demonstrates the complete integration of Digia UI components
/// with native Flutter code. It showcases all major integration touchpoints
/// including component creation, state management, message handling, and
/// bidirectional communication.
///
/// Key Features Demonstrated:
/// 1. Component Creation - DUIFactory().createComponent()
/// 2. Custom Widget Registration - AddToCartButtonCustomWidget
/// 3. State Management - DUIAppState for global state
/// 4. Message Handling - DigiaMessageHandlerMixin
/// 5. API Integration - Shopify Storefront API
/// 6. Loading States - Native and Digia loading components
/// 7. Error Handling - Graceful error states
/// 8. Navigation - Seamless Digia-native transitions
///
/// Architecture:
/// - CartScreenByDigiaUI: Wrapper that fetches cart data and renders Digia components
/// - CartScreen: Main cart display with Digia UI integration
/// - Message handling via DigiaMessageHandlerMixin
/// - State synchronization between native and Digia components
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (context) => const CartScreenByDigiaUI()),
/// );
/// ```
///
/// Data Flow:
/// 1. Fetch cart data from Shopify API
/// 2. Render Digia UI components with cart data
/// 3. Handle user interactions via message bus
/// 4. Update cart state in real-time
/// 5. Navigate to checkout when ready
class CartScreenByDigiaUI extends StatefulWidget {
  /// Constructor for the Digia UI cart screen
  const CartScreenByDigiaUI({super.key});

  @override
  State<CartScreenByDigiaUI> createState() => _CartScreenByDigiaUIState();
}

/// State class for CartScreenByDigiaUI
///
/// Handles the initial cart data fetching and provides the main scaffold
/// for the Digia UI cart experience. This wrapper ensures proper system
/// UI overlay configuration and provides error/loading states.
class _CartScreenByDigiaUIState extends State<CartScreenByDigiaUI> {
  /// Build the cart screen with Digia UI integration
  ///
  /// Sets up system UI overlays and renders the cart content using
  /// FutureBuilder to handle async cart data loading.
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light
          .copyWith(statusBarBrightness: Brightness.dark),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: FutureBuilder(
              future:
                  ApiService.instance.getCart(DUIAppState().getValue('cartId')),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: DUIFactory().createComponent('loading_state', {}));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final cartData = snapshot.data!['data']?['cart'] ?? {};

                  return CartScreen(
                    cartItems: cartData['lines']?['edges'] ?? [],
                    totalAmount: cartData['cost']?['subtotalAmount']?['amount'],
                    checkoutUrl: cartData['checkoutUrl'],
                    onCheckout: () {
                      setState(() {});
                    },
                  );
                } else {
                  return const Center(child: Text('No data available'));
                }
              }),
        ),
      ),
    );
  }
}

/// Main Cart Screen Widget - Digia UI Component Integration
///
/// Displays cart items using a combination of Digia UI components and
/// native Flutter widgets. Demonstrates seamless integration between
/// Digia Studio components and custom native implementations.
///
/// Props:
/// - cartItems: List of cart line items from Shopify
/// - totalAmount: Total cart amount as string
/// - checkoutUrl: Shopify checkout URL
/// - onCheckout: Callback when checkout is initiated
class CartScreen extends StatefulWidget {
  /// Cart items data from Shopify API
  final List cartItems;

  /// Total amount for display
  final String? totalAmount;

  /// Shopify checkout URL
  final String? checkoutUrl;

  /// Callback for checkout actions
  final VoidCallback? onCheckout;

  /// Constructor with required cart data
  const CartScreen(
      {super.key,
      required this.cartItems,
      this.totalAmount,
      this.checkoutUrl,
      this.onCheckout});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

/// State class with Digia Message Handler Mixin
///
/// Extends DigiaMessageHandlerMixin to receive messages from Digia UI components.
/// Handles real-time updates, loading states, and user interactions from
/// Digia components via the message bus system.
class _CartScreenState extends State<CartScreen> with DigiaMessageHandlerMixin {
  /// Computed getter for cart items list
  List get cartItemsList => widget.cartItems;

  /// Loading state for checkout operations
  bool isLoading = false;

  /// Initialize message handlers for Digia UI communication
  ///
  /// Registers handlers for specific message channels from Digia components:
  /// - rebuild_screen: General screen refresh
  /// - rebuild_isLoading_true: Show loading state
  /// - rebuild_isLoading_false: Hide loading state
  @override
  void initState() {
    super.initState();
    addMessageHandler('rebuild_screen', (message) {
      // Trigger screen rebuild via callback
      widget.onCheckout?.call();
    });
    addMessageHandler('rebuild_isLoading_true', (message) {
      // Show loading overlay
      setState(() {
        isLoading = true;
      });
      widget.onCheckout?.call();
    });
    addMessageHandler('rebuild_isLoading_false', (message) {
      // Hide loading overlay
      setState(() {
        isLoading = false;
      });
      widget.onCheckout?.call();
    });
  }

  /// Build the main cart UI with Digia components
  ///
  /// Renders cart items using Digia UI components, handles empty states,
  /// and provides checkout functionality with loading states.
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (cartItemsList.isNotEmpty) ...[
          Column(
            children: [
              const Text('Checkout',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  )),
              DUIFactory().createComponent(
                'divider_page',
                {},
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cartItemsList.length,
                        itemBuilder: (context, index) {
                          final item = cartItemsList[index]['node'];
                          final imageUrl =
                              item['merchandise']?['image']?['url'] ?? '';
                          final productName =
                              item['merchandise']?['product']?['title'] ?? '';
                          final discountedPrice =
                              item['merchandise']?['price']?['amount'] ?? '';
                          final quantity = item['quantity'] ?? 0;
                          final cartLineItemId = item['id'] ?? '';
                          return DUIFactory().createComponent('checkout_card', {
                            "imgUrl": imageUrl,
                            "productName": productName,
                            "discountedprice": '₹$discountedPrice',
                            "quantity": quantity,
                            "cartLineItemId": cartLineItemId,
                            "productObj": cartItemsList[index]
                          });
                        },
                      ),
                      DUIFactory().createComponent(
                        'deliverybox-OPoqGv',
                        {},
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    bottom: 22, top: 2, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'EST. TOTAL',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$${widget.totalAmount ?? '0.00'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Handle checkout action
                  if (widget.checkoutUrl != null) {
                    // Open checkout URL in browser or WebView
                    print('Navigating to checkout: ${widget.checkoutUrl}');
                  }
                },
                child: const ColoredBox(
                  color: Colors.black,
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: 13, top: 17, left: 16, right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Checkout',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            )),
                      ],
                    ),
                  ),
                ),
              )
            ],
          )
        ] else ...[
          const Center(
            child: Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        if (isLoading) ...[
          Center(
            child: DUIFactory().createComponent('loading_state', {}),
          ),
        ],
      ],
    );
  }
}
