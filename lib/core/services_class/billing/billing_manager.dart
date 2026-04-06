import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:goatlearning/core/const/billing_config.dart';
import 'package:goatlearning/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:goatlearning/core/services_class/user_bootstrap_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class BillingManager {
  BillingManager._internal();
  static final BillingManager instance = BillingManager._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final ValueNotifier<bool> isPremium = ValueNotifier<bool>(false);

  static String premiumProductId = kPremiumProductId;

  ProductDetails? _premiumProduct;
  bool _storeAvailable = false;
  bool _loadingProducts = false;

  Future<void> init({bool attemptRestore = true}) async {
    _storeAvailable = await _iap.isAvailable();

    await _loadSavedPremium();

    if (!_storeAvailable) {
      return;
    }

    await _ensureProductLoaded();

    _subscription ??= _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (_) {},
      onDone: () {},
      cancelOnError: false,
    );

    if (attemptRestore) {
      // iOS triggers restored events; Android may rely on persisted flag.
      await restorePurchases();
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  /// Run a basic diagnostic of the billing setup and product lookup.
  /// Returns a multi-line string with findings for UI display/logging.
  Future<String> diagnoseBilling() async {
    final buffer = StringBuffer();
    try {
      buffer.writeln('Billing diagnose:');
      buffer.writeln('- productId: $premiumProductId');
      final available = await _iap.isAvailable();
      buffer.writeln('- isAvailable: $available');
      if (!available) {
        buffer.writeln('  Hint: Use a Play-enabled device/emulator.');
        return buffer.toString();
      }

      final result = await _iap.queryProductDetails({premiumProductId});
      buffer.writeln('- notFoundIDs: ${result.notFoundIDs}');
      buffer.writeln('- productDetailsCount: ${result.productDetails.length}');
      if (result.productDetails.isNotEmpty) {
        final p = result.productDetails.first;
        buffer.writeln('- title: ${p.title}');
        buffer.writeln('- price: ${p.price}');
        buffer.writeln('- currency: ${p.currencyCode}');
      } else {
        buffer.writeln(
          '  Hint: Ensure Play app package and productId match, product is Active, and account is tester.',
        );
      }
    } catch (e) {
      buffer.writeln('Error: $e');
    }
    return buffer.toString();
  }

  Future<void> buyPremium() async {
    if (!_storeAvailable) {
      EasyLoading.showInfo('Store unavailable. Use a Play-enabled device.');
      return;
    }

    if (_premiumProduct == null) {
      final loaded = await _ensureProductLoaded();
      if (!loaded) {
        EasyLoading.showInfo(
          'Premium product not found. Check product ID: $premiumProductId',
        );
        return;
      }
    }

    try {
      EasyLoading.show(status: 'Starting purchase...');
      final purchaseParam = PurchaseParam(productDetails: _premiumProduct!);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      if (kDebugMode) {
        print('buyPremium error: $e');
      }
      EasyLoading.showError('Could not start purchase');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> restorePurchases() async {
    if (!_storeAvailable) {
      await _loadSavedPremium();
      // Avoid using EasyLoading if overlay may not be ready; rely on logs.
      if (kDebugMode) print('Store unavailable. Restored local state.');
      return;
    }
    try {
      EasyLoading.show(status: 'Restoring purchases...');
      await _iap.restorePurchases();
      EasyLoading.dismiss();
    } catch (e) {
      if (kDebugMode) print('restore error: $e');
      EasyLoading.showError('Failed to restore purchases');
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _grantPremium();
          EasyLoading.showSuccess('Premium unlocked');
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.pending:
          EasyLoading.show(status: 'Waiting for purchase...');
          break;
        case PurchaseStatus.error:
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          EasyLoading.showError('Purchase failed');
          break;
        case PurchaseStatus.canceled:
          EasyLoading.showInfo('Purchase canceled');
          break;
      }
    }
    EasyLoading.dismiss();
  }

  Future<void> _grantPremium() async {
    isPremium.value = true;
    await SharePref.saveSubcription(true);
    // Also sync payment status to backend using the generated userId
    await UserBootstrapService.instance.syncPaymentStatus();
  }

  Future<void> _loadSavedPremium() async {
    final saved = await SharePref.getSavedSubcription();
    if (saved == true) {
      isPremium.value = true;
    } else {
      isPremium.value = false;
    }
  }

  Future<bool> _ensureProductLoaded() async {
    if (_premiumProduct != null || _loadingProducts == true) {
      return _premiumProduct != null;
    }
    try {
      _loadingProducts = true;
      final response = await _iap.queryProductDetails({premiumProductId});
      if (kDebugMode) {
        print('IAP isAvailable: $_storeAvailable');
        print('Query notFoundIDs: ${response.notFoundIDs}');
        print('Query productDetails count: ${response.productDetails.length}');
      }
      if (response.notFoundIDs.isEmpty && response.productDetails.isNotEmpty) {
        _premiumProduct = response.productDetails.first;
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('queryProductDetails error: $e');
    } finally {
      _loadingProducts = false;
    }
    return false;
  }
}
