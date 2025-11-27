import 'package:digia_ui/digia_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:producthub_demo/services/api_service.dart';

/// COMPREHENSIVE CART SCREEN - Demonstrates ALL Digia UI Integration Touchpoints
///
/// This screen showcases:
/// 1. Component Creation (DUIFactory().createComponent())
/// 2. Custom Widget Registration (AddToCartButtonCustomWidget)
class CartScreenByDigiaUI extends StatefulWidget {
  const CartScreenByDigiaUI({super.key});

  @override
  State<CartScreenByDigiaUI> createState() => _CartScreenByDigiaUIState();
}

class _CartScreenByDigiaUIState extends State<CartScreenByDigiaUI> {
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

class CartScreen extends StatefulWidget {
  final List cartItems;
  final String? totalAmount;
  final String? checkoutUrl;
  final VoidCallback? onCheckout;

  const CartScreen(
      {super.key,
      required this.cartItems,
      this.totalAmount,
      this.checkoutUrl,
      this.onCheckout});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with DigiaMessageHandlerMixin {
  List get cartItemsList => widget.cartItems;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    addMessageHandler('rebuild_screen', (message) {
      // setState(() {});
      widget.onCheckout?.call();
    });
    addMessageHandler('rebuild_isLoading_true', (message) {
      // setState(() {
      isLoading = true;
      // });
      widget.onCheckout?.call();
    });
    addMessageHandler('rebuild_isLoading_false', (message) {
      // setState(() {
      isLoading = false;
      // });
      widget.onCheckout?.call();
    });
  }

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
