import 'package:flutter/material.dart';
import 'package:gokwik/config/types.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class KPCheckoutScreen extends StatefulWidget {
  final String? cartId;
  final String storefrontToken;
  final String? storeId;
  final String? sessionId;
  final String? fpixel;
  final String? gaTrackingID;
  final String? webEngageID;
  final String? moEngageID;
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
    this.utmParams,
  });

  @override
  State<KPCheckoutScreen> createState() => _KPCheckoutScreenState();
}

class _KPCheckoutScreenState extends State<KPCheckoutScreen> {
  void _handleEvent(Map<String, dynamic> message) {
    debugPrint('📨 Received event from WebView: ${message['eventname']}');
    debugPrint('📨 Event data: ${message['data']}');

    final eventName = message['eventname'] as String?;
    final eventData = message['data'] as Map<String, dynamic>?;

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

  String _buildCheckoutUrl() {
    // Build checkout URL with parameters
    final baseUrl = 'https://checkout.gokwik.co/init';
    final params = <String, String>{};
    
    if (widget.cartId != null && widget.cartId!.isNotEmpty) {
      params['cartId'] = widget.cartId!;
    }
    if (widget.storefrontToken.isNotEmpty) {
      params['storefrontToken'] = widget.storefrontToken;
    }
    if (widget.storeId != null && widget.storeId!.isNotEmpty) {
      params['storeId'] = widget.storeId!;
    }
    if (widget.sessionId != null && widget.sessionId!.isNotEmpty) {
      params['sessionId'] = widget.sessionId!;
    }
    
    final uri = Uri.parse(baseUrl).replace(queryParameters: params);
    return uri.toString();
  }

  @override
  Widget build(BuildContext context) {
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
      body: KPCheckoutWidget(
        checkoutData: CheckoutShopifyProps(
          cartId: widget.cartId,
          storefrontToken: widget.storefrontToken,
          storeId: widget.storeId,
          sessionId: widget.sessionId,
          fpixel: widget.fpixel,
          utmParams: widget.utmParams != null 
              ? UTMParams(
                  utmSource: widget.utmParams!['utm_source'],
                  utmMedium: widget.utmParams!['utm_medium'],
                  utmCampaign: widget.utmParams!['utm_campaign'],
                  utmTerm: widget.utmParams!['utm_term'],
                  utmContent: widget.utmParams!['utm_content'],
                  landingPage: widget.utmParams!['landing_page'],
                  origReferrer: widget.utmParams!['orig_referrer'],
                )
              : null,
        ),
        onEvent: _handleEvent,
      ),
    );
  }
}

// KPCheckout Widget implementation as per documentation
class KPCheckoutWidget extends StatelessWidget {
  final CheckoutShopifyProps checkoutData;
  final void Function(Map<String, dynamic>) onEvent;

  const KPCheckoutWidget({
    super.key,
    required this.checkoutData,
    required this.onEvent,
  });

  String _buildCheckoutUrl() {
    final baseUrl = 'https://checkout.gokwik.co/init';
    final params = <String, String>{};
    
    if (checkoutData.cartId != null && checkoutData.cartId!.isNotEmpty) {
      params['cartId'] = checkoutData.cartId!;
    }
    if (checkoutData.storefrontToken != null && checkoutData.storefrontToken!.isNotEmpty) {
      params['storefrontToken'] = checkoutData.storefrontToken!;
    }
    if (checkoutData.storeId != null && checkoutData.storeId!.isNotEmpty) {
      params['storeId'] = checkoutData.storeId!;
    }
    if (checkoutData.sessionId != null && checkoutData.sessionId!.isNotEmpty) {
      params['sessionId'] = checkoutData.sessionId!;
    }
    
    // Add UTM parameters if available
    if (checkoutData.utmParams != null) {
      params.addAll(checkoutData.utmParams!.toQueryMap());
    }
    
    final uri = Uri.parse(baseUrl).replace(queryParameters: params);
    return uri.toString();
  }

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'KwikPassEventChannel',
        onMessageReceived: (JavaScriptMessage msg) {
          try {
            final parsed = json.decode(msg.message) as Map<String, dynamic>;
            onEvent(parsed);
          } catch (e) {
            debugPrint('❌ Error parsing WebView message: $e');
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('🌐 WebView page started: $url');
          },
          onPageFinished: (String url) {
            debugPrint('✅ WebView page finished: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('❌ WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(_buildCheckoutUrl()));

    return WebViewWidget(controller: controller);
  }
}

// CheckoutShopifyProps class as per documentation
class CheckoutShopifyProps {
  final String? cartId;
  final String? storefrontToken;
  final String? storeId;
  final String? sessionId;
  final String? fpixel;
  final UTMParams? utmParams;

  CheckoutShopifyProps({
    this.cartId,
    this.storefrontToken,
    this.storeId,
    this.sessionId,
    this.fpixel,
    this.utmParams,
  });
}

// UTMParams class as per documentation
class UTMParams {
  final String? utmSource;
  final String? utmMedium;
  final String? utmCampaign;
  final String? utmTerm;
  final String? utmContent;
  final String? landingPage;
  final String? origReferrer;

  UTMParams({
    this.utmSource,
    this.utmMedium,
    this.utmCampaign,
    this.utmTerm,
    this.utmContent,
    this.landingPage,
    this.origReferrer,
  });

  Map<String, String> toQueryMap() {
    return {
      if (utmSource != null) 'utm_source': utmSource!,
      if (utmMedium != null) 'utm_medium': utmMedium!,
      if (utmCampaign != null) 'utm_campaign': utmCampaign!,
      if (utmTerm != null) 'utm_term': utmTerm!,
      if (utmContent != null) 'utm_content': utmContent!,
      if (landingPage != null) 'landing_page': landingPage!,
      if (origReferrer != null) 'orig_referrer': origReferrer!,
    };
  }
}

