import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/network_caller/endpoints.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:http/http.dart' as http;

const String productID = 'full_access';

class PurchasePage extends StatefulWidget {
  final String userToken;

  const PurchasePage({super.key, required this.userToken});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  bool _available = false;
  List<ProductDetails> _products = [];
  bool _isPurchasing = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _initStoreInfo();

    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        if (kDebugMode) {
          print('Purchase stream error: $error');
        }
        setState(() {
          _statusMessage = 'Purchase stream error: $error';
          _isPurchasing = false;
        });
      },
    );
  }

  Future<void> _initStoreInfo() async {
    try {
      // Check if in-app purchases are available
      _available = await _iap.isAvailable();
      if (!_available) {
        setState(() {
          _statusMessage = 'iap_not_available'.tr;
        });
        if (kDebugMode) {
          print(
            'In-app purchases not available. Ensure device has Google Play Services or valid App Store account.',
          );
        }
        return;
      }

      // Query product details
      final response = await _iap.queryProductDetails({productID}.toSet());
      if (response.error != null) {
        setState(() {
          _statusMessage = 'error_fetching_products'
              .trParams({'error': response.error!.message});
        });
        if (kDebugMode) {
          print('Error fetching products: ${response.error!.message}');
        }
        return;
      }

      if (response.productDetails.isEmpty) {
        setState(() {
          _statusMessage =
              'product_not_found'.trParams({'productId': productID});
        });
        if (kDebugMode) {
          print('No products found for ID: $productID');
        }
        return;
      }

      setState(() {
        _products = response.productDetails;
        _statusMessage = '';
      });
      if (kDebugMode) {
        print(
          'Products loaded: ${response.productDetails.map((p) => p.id).join(", ")}',
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'initialization_error'.trParams({'error': e.toString()});
      });
      if (kDebugMode) {
        print('Initialization error: $e');
      }
    }
  }

  void _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        setState(() {
          _statusMessage = 'purchase_pending'.tr;
          _isPurchasing = true;
        });
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        setState(() {
          _statusMessage = 'purchase_error'.trParams({
            'error': purchaseDetails.error?.message ?? 'unknown_error'.tr
          });
          _isPurchasing = false;
        });
        if (kDebugMode) {
          print('Purchase error: ${purchaseDetails.error?.message}');
        }
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        bool validPurchase = await _verifyPurchase(purchaseDetails);
        if (validPurchase) {
          // Call backend to unlock content
          bool unlockSuccess = await _callUnlockApi(widget.userToken);
          if (unlockSuccess) {
            setState(() {
              _statusMessage = 'purchase_successful'.tr;
              _isPurchasing = false;
            });
            // Complete purchase to prevent recharging
            await _iap.completePurchase(purchaseDetails);
            if (kDebugMode) {
              print('Purchase completed: ${purchaseDetails.purchaseID}');
            }
          } else {
            setState(() {
              _statusMessage = 'failed_to_unlock_chapters'.tr;
              _isPurchasing = false;
            });
          }
        } else {
          setState(() {
            _statusMessage = 'purchase_verification_failed'.tr;
            _isPurchasing = false;
          });
          if (kDebugMode) {
            print(
              'Purchase verification failed for: ${purchaseDetails.purchaseID}',
            );
          }
        }
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // Placeholder for server-side verification
    // In production, send purchaseDetails to your backend for validation
    try {
      final url = Uri.parse('${Urls.baseUrl}/verify-purchase');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': widget.userToken,
      };
      final body = jsonEncode({
        'purchaseId': purchaseDetails.purchaseID,
        'verificationData':
            purchaseDetails.verificationData.serverVerificationData,
        'platform':
            defaultTargetPlatform == TargetPlatform.android ? 'android' : 'ios',
      });

      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        return true;
      } else {
        if (kDebugMode) {
          print(
            'Verification failed: ${response.statusCode} - ${response.body}',
          );
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Verification error: $e');
      }
      return false;
    }
  }

  Future<bool> _callUnlockApi(String userToken) async {
    final url = Uri.parse('${Urls.baseUrl}/users/payment');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': userToken,
    };

    try {
      final response = await http
          .post(url, headers: headers)
          .timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Unlock API success');
        }
        return true;
      } else {
        setState(() {
          _statusMessage = 'server_error'
              .trParams({'code': response.statusCode.toString()});
        });
        if (kDebugMode) {
          print('Unlock API error: ${response.statusCode} - ${response.body}');
        }
        return false;
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'network_error'.trParams({'error': e.toString()});
      });
      if (kDebugMode) {
        print('Exception calling unlock API: $e');
      }
      return false;
    }
  }

  void _buyProduct() async {
    if (_products.isEmpty) {
      setState(() {
        _statusMessage = 'no_products_available'.tr;
      });
      if (kDebugMode) {
        print('No products available to purchase.');
      }
      return;
    }

    final productDetails = _products.first;

    setState(() {
      _isPurchasing = true;
      _statusMessage = 'starting_purchase'.tr;
    });

    try {
      final purchaseParam = PurchaseParam(productDetails: productDetails);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      setState(() {
        _statusMessage =
            'purchase_initiation_failed'.trParams({'error': e.toString()});
        _isPurchasing = false;
      });
      if (kDebugMode) {
        print('Purchase initiation error: $e');
      }
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF5EAEB5);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor.withValues(alpha: 0.1), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                      ),
                      Container(
                        height: 120,
                        width: 120,
                        margin: EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_open,
                          size: 60,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 50, width: 50),
                    ],
                  ),

                  Text(
                    'unlock_all_chapters'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    'get_lifetime_access'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),

                  SizedBox(height: 15),

                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.lock,
                                color: Colors.orange,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'current_access'.tr,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'first_4_chapters_only'.tr,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10),

                        Container(height: 1, color: Colors.grey.shade300),

                        SizedBox(height: 10),

                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.lock_open,
                                color: primaryColor,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'full_access'.tr,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'all_chapters_future_updates'.tr,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14),

                  _buildBenefitItem('✨', 'unlock_all_remaining_chapters'.tr),
                  _buildBenefitItem('🔄', 'lifetime_access_pay_once'.tr),
                  _buildBenefitItem('📚', 'access_to_future_updates'.tr),
                  _buildBenefitItem('🚀', 'complete_learning_journey'.tr),

                  SizedBox(height: 24),

                  // Status message
                  if (_statusMessage.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color:
                            _statusMessage.contains('error') ||
                                    _statusMessage.contains('failed')
                                ? Colors.red.withValues(alpha: 0.1)
                                : primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              _statusMessage.contains('error') ||
                                      _statusMessage.contains('failed')
                                  ? Colors.red
                                  : primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  // Purchase button
                  ElevatedButton(
                    onPressed:
                        _isPurchasing || _products.isEmpty ? null : _buyProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child:
                        _isPurchasing
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'processing'.tr,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                            : Text(
                              _products.isNotEmpty
                                  ? '${'unlock_all_chapters'.tr} - ${_products.first.price}'
                                  : 'unlock_all_chapters'.tr,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),

                  SizedBox(height: 16),

                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '💡 ${'one_time_purchase_info'.tr}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 20)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
