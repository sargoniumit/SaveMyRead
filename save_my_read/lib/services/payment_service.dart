import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PaymentService {
  static const String _productId = 'savemyread_full_unlock';
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  ProductDetails? _productDetails;

  Future<void> initialize() async {
    // Check if in-app purchases are available
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      debugPrint('In-app purchases not available');
      return;
    }

    // Listen to purchase updates
    final purchaseStream = _inAppPurchase.purchaseStream;
    _subscription = purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );

    // Load products
    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    final Set<String> productIds = {_productId};
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Product not found: ${response.notFoundIDs}');
    }

    if (response.productDetails.isNotEmpty) {
      _productDetails = response.productDetails.first;
      debugPrint('Product loaded: ${_productDetails?.title}');
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored) {

      // Verify purchase and update premium status
      await _verifyAndActivatePremium(purchaseDetails);

      // Complete the purchase
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    } else if (purchaseDetails.status == PurchaseStatus.error) {
      debugPrint('Purchase error: ${purchaseDetails.error}');
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _verifyAndActivatePremium(PurchaseDetails purchaseDetails) async {
    // In production, you should verify the purchase with your server
    // For now, we'll trust the local purchase

    final settingsBox = Hive.box('settings');
    await settingsBox.put('isPremium', true);
    await settingsBox.put('purchaseDate', DateTime.now().toIso8601String());

    debugPrint('Premium activated');
  }

  void _updateStreamOnDone() {
    _subscription?.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    debugPrint('Purchase stream error: $error');
  }

  Future<bool> buyPremium() async {
    if (_productDetails == null) {
      debugPrint('Product not loaded');
      return false;
    }

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: _productDetails!);
    try {
      final bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      return success;
    } catch (e) {
      debugPrint('Purchase error: $e');
      return false;
    }
  }

  String? get productPrice => _productDetails?.price;
  String? get productTitle => _productDetails?.title;
  String? get productDescription => _productDetails?.description;

  void dispose() {
    _subscription?.cancel();
  }

  static Future<bool> isPremium() async {
    final settingsBox = Hive.box('settings');
    return settingsBox.get('isPremium', defaultValue: false);
  }
}
