import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

/// Signature for purchase status callbacks.
typedef PurchaseCallback = void Function(String productId, bool success);

/// Abstract base so we can mock in tests.
abstract class IAPServiceBase {
  Future<void> initialize();
  Future<bool> purchase(String productId);
  Future<void> restorePurchases();
  bool isPurchased(String productId);
  void addListener(PurchaseCallback callback);
  void dispose();
}

class IAPService implements IAPServiceBase {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final Set<String> _purchasedIds = {};
  final List<PurchaseCallback> _listeners = [];
  Map<String, ProductDetails> _products = {};

  @override
  Future<void> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) return;

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: () => _subscription?.cancel(),
      onError: (_) {},
    );

    const ids = <String>{
      'pinball_bounce_remove_ads',
      'pinball_bounce_extra_lives',
    };
    final response = await _iap.queryProductDetails(ids);
    _products = {
      for (final p in response.productDetails) p.id: p,
    };

    await restorePurchases();
  }

  @override
  Future<bool> purchase(String productId) async {
    final product = _products[productId];
    if (product == null) return false;

    final purchaseParam = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  @override
  bool isPurchased(String productId) => _purchasedIds.contains(productId);

  @override
  void addListener(PurchaseCallback callback) {
    _listeners.add(callback);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _listeners.clear();
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final details in purchaseDetailsList) {
      switch (details.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _purchasedIds.add(details.productID);
          _notifyListeners(details.productID, true);
          if (details.pendingCompletePurchase) {
            _iap.completePurchase(details);
          }
          break;
        case PurchaseStatus.error:
          _notifyListeners(details.productID, false);
          break;
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.canceled:
          _notifyListeners(details.productID, false);
          break;
      }
    }
  }

  void _notifyListeners(String productId, bool success) {
    for (final listener in _listeners) {
      listener(productId, success);
    }
  }
}
