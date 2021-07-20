import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import '../pref_provider.dart';

final List<String> _kProductIds = ['get_premium'];

class PremiumModal extends StatefulWidget {
  @override
  _PremiumModalState createState() => _PremiumModalState();
}

class _PremiumModalState extends State<PremiumModal> {
  final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;
  StreamSubscription<List<PurchaseDetails>> _subscription;

  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;

  @override
  void initState() {
    Stream purchaseUpdated =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    initStoreInfo();
    super.initState();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _connection.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = [];
        _purchases = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    ProductDetailsResponse productDetailResponse =
        await _connection.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];

        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];

        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    final QueryPurchaseDetailsResponse purchaseResponse =
        await _connection.queryPastPurchases();
    if (purchaseResponse.error != null) {
      // handle query past purchase error..
    }
    final List<PurchaseDetails> verifiedPurchases = [];
    for (PurchaseDetails purchase in purchaseResponse.pastPurchases) {
      if (await _verifyPurchase(purchase)) {
        verifiedPurchases.add(purchase);
      }
    }
    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _purchases = verifiedPurchases;
      _purchasePending = false;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.all(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(height: 100),
              Text(
                'Buy premium\nand unlock\nfeatures',
                style: TextStyle(
                  color: Colors.black,
                  height: 1.3,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  fontSize: 46,
                ),
              ),
              SizedBox(height: 60),
              Stack(
                children: [
                  _purchasePending
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xffFfe6746),
                            ),
                          ),
                        )
                      : Container(),
                  Align(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              '40+ themes',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Up to 5 reminders',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    Map<String, PurchaseDetails> purchases =
        Map.fromEntries(_purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        InAppPurchaseConnection.instance.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));

    var alertText = TextStyle(
      color: Colors.black,
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w400,
      fontSize: 14,
    );

    if (_loading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Color(0xffFfe6746),
          ),
        ),
      );
    }

    List<Widget> productList = <Widget>[
      Text(
        _products[0].price,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w500,
        ),
      ),
      SizedBox(height: 10),
      Text(
        '(One time payment)',
        style: TextStyle(
          color: Color.fromRGBO(0, 0, 0, 0.6),
          fontSize: 12,
          fontFamily: 'Roboto',
        ),
      ),
      SizedBox(height: 20),
    ];

    productList.addAll(_products.map(
      (ProductDetails productDetails) {
        PurchaseDetails previousPurchase = purchases[productDetails.id];
        return SizedBox(
          width: double.infinity,
          height: 60,
          child: FlatButton(
            color: Color(0xffFFE6746),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onPressed: () async {
              if (previousPurchase != null) {
                var provider =
                    Provider.of<PrefProvider>(context, listen: false);
                provider.doPurchase();
                Navigator.pop(context);
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Platform.isAndroid
                        ? AlertDialog(
                            content: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                'Purchase Restored.',
                                textAlign: TextAlign.center,
                                style: alertText,
                              ),
                            ),
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  Navigator.pop(context, "Ok");
                                },
                                child: Text(
                                  'Ok',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : CupertinoAlertDialog(
                            content: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                'Purchase Restored.',
                                textAlign: TextAlign.center,
                                style: alertText,
                              ),
                            ),
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  Navigator.pop(context, "Ok");
                                },
                                child: Text(
                                  'Ok',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          );
                  },
                );
              } else {
                PurchaseParam purchaseParam = PurchaseParam(
                  productDetails: productDetails,
                  sandboxTesting: false,
                );

                _connection.buyNonConsumable(
                  purchaseParam: purchaseParam,
                );
              }
            },
            child: Text(
              previousPurchase != null ? 'Restore Purchase' : 'Continue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    ));

    return Center(
      child: Column(children: productList),
    );
  }

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    var provider = Provider.of<PrefProvider>(context, listen: false);
    await provider.doPurchase();
    Navigator.pop(context);
    setState(() {
      _purchasePending = false;
    });
    if (purchaseDetails.productID != _kProductIds[0]) {
      setState(() {
        _purchases.add(purchaseDetails);
      });
    }
  }

  void handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) async {
    var alertText = TextStyle(
      color: Colors.black,
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w400,
      fontSize: 14,
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Platform.isAndroid
            ? AlertDialog(
                content: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'In App Purchase unavailable',
                    textAlign: TextAlign.center,
                    style: alertText,
                  ),
                ),
                actions: [
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context, "Ok");
                    },
                    child: Text(
                      'Ok',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              )
            : CupertinoAlertDialog(
                content: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'In App Purchase unavailable',
                    textAlign: TextAlign.center,
                    style: alertText,
                  ),
                ),
                actions: [
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context, "Ok");
                    },
                    child: Text(
                      'Ok',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              );
      },
    );
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchaseConnection.instance
              .completePurchase(purchaseDetails);
        }
      }
    });
  }
}
