import 'package:flutter/material.dart';
import 'package:gokwik/checkout/kp_checkout.dart';
import 'package:gokwik/config/types.dart';
import 'package:url_launcher/url_launcher.dart';

class KPCheckoutScreen extends StatefulWidget {
  final String? cartId;
  final String storefrontToken;
  final String? storeId;
  final String? sessionId;
  final String? fpixel;
  final String? gaTrackingID;
  final String? webEngageID;
  final String? moEngageID;
  final String? checkoutUrl; // Shopify checkout URL
  final Map<String, String>? utmParams;

  const KPCheckoutScreen({
    super.key,
    required this.cartId,
    required this.storefrontToken,
    this.storeId,
    this.sessionId,
    this.fpixel,
    this.gaTrackingID,
    this.webEngageID,
    this.moEngageID,
    this.checkoutUrl,
    this.utmParams,
  });

  @override
  State<KPCheckoutScreen> createState() => _KPCheckoutScreenState();
}

class _KPCheckoutScreenState extends State<KPCheckoutScreen> {
  void _handleEvent(dynamic message) {
    // Handle both Map and other types
    Map<String, dynamic>? messageMap;
    if (message is Map<String, dynamic>) {
      messageMap = message;
    } else if (message is Map) {
      messageMap = Map<String, dynamic>.from(message);
    } else {
      debugPrint('⚠️ Unexpected message type: ${message.runtimeType}');
      return;
    }
    
    debugPrint('📨 Received event from WebView: ${messageMap['eventname']}');
    debugPrint('📨 Event data: ${messageMap['data']}');

    final eventName = messageMap['eventname'] as String?;
    final eventData = messageMap['data'] as Map<String, dynamic>?;

    switch (eventName) {
      case 'modal_closed':
        // Handle closing of the GoKwik checkout modal
        debugPrint('✅ GoKwik Checkout Modal Closed: $eventData');
        if (mounted) {
          Navigator.pop(context);
        }
        break;

      case 'orderSuccess':
        // Handle successful order completion
        debugPrint('✅ GoKwik Order Success: $eventData');
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Order placed successfully!'),
              backgroundColor: Color(0xFF27916D),
              duration: Duration(seconds: 3),
            ),
          );
        }
        break;

      case 'openInBrowserTab':
        // Handle requests to open URL in browser
        debugPrint('🌐 GoKwik Open In Browser Tab request: $eventData');
        if (eventData != null && eventData['url'] != null) {
          final url = eventData['url'].toString();
          if (url.startsWith('http://') || url.startsWith('https://')) {
            // Handle opening the URL
            debugPrint('🌐 Attempting to open URL: $url');
            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          }
        }
        break;

      case 'gk-checkout-disable':
        // Handle when GoKwik checkout is disabled
        debugPrint('⚠️ GoKwik Checkout Disabled: $eventData');
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Checkout is currently unavailable. Please try again later.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        break;

      default:
        // Handle any other events
        debugPrint('ℹ️ Unhandled WebView event: $eventName - $eventData');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔧 Building KPCheckout with:');
    debugPrint('   cartId: ${widget.cartId}');
    debugPrint('   storefrontToken: ${widget.storefrontToken.substring(0, 10)}...');
    debugPrint('   storeId: ${widget.storeId}');
    debugPrint('   checkoutUrl: ${widget.checkoutUrl}');
    
    // Build MerchantParams from widget properties
    // Extract merchantCheckoutId from checkoutUrl if available
    String? merchantCheckoutId;
    if (widget.checkoutUrl != null && widget.checkoutUrl!.isNotEmpty) {
      // Extract checkout ID from URL like: https://eyejack.in/cart/c/{checkoutId}?key=...
      final match = RegExp(r'/c/([^/?]+)').firstMatch(widget.checkoutUrl!);
      if (match != null) {
        merchantCheckoutId = match.group(1);
        debugPrint('✅ Extracted merchantCheckoutId: $merchantCheckoutId');
      }
    }
    
    final merchantParams = MerchantParams(
      merchantCheckoutId: merchantCheckoutId,
      cartId: widget.cartId ?? '',
      storefrontToken: widget.storefrontToken,
      storeId: widget.storeId ?? '19g6iluwldmy4',
      sessionId: widget.sessionId,
      fbPixel: widget.fpixel, // Note: SDK uses fbPixel, not fpixel
      gaTrackingID: widget.gaTrackingID,
      webEngageID: widget.webEngageID,
      moEngageID: widget.moEngageID,
      utmParams: widget.utmParams,
    );

    // Build CheckoutData with MerchantParams
    final checkoutData = CheckoutData(
      merchantParams: merchantParams,
    );

    // Build KPCheckoutProps
    final kpCheckoutProps = KPCheckoutProps(
      checkoutData: checkoutData,
      onEvent: _handleEvent,
      onError: (error) {
        debugPrint('❌ KPCheckout error: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Checkout error: $error'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: KPCheckout(
        checkoutData: kpCheckoutProps,
      ),
    );
  }
}

