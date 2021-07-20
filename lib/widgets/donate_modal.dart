// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:provider/provider.dart';

// import '../pref_provider.dart';

// final List<String> _kProductIds = [
//   'donation_01',
//   'donation_02',
//   'donation_03',
//   'donation_04',
//   'donation_05',
// ];

// class DonateModal extends StatefulWidget {
//   @override
//   _DonateModalState createState() => _DonateModalState();
// }

// class _DonateModalState extends State<DonateModal> {
//   final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;
//   StreamSubscription<List<PurchaseDetails>> _subscription;

//   List<ProductDetails> _products = [];
//   List<PurchaseDetails> _purchases = [];
//   bool _isAvailable = false;
//   bool _purchasePending = false;
//   bool _loading = true;

//   @override
//   void initState() {
//     Stream purchaseUpdated =
//         InAppPurchaseConnection.instance.purchaseUpdatedStream;
//     _subscription = purchaseUpdated.listen((purchaseDetailsList) {
//       _listenToPurchaseUpdated(purchaseDetailsList);
//     }, onDone: () {
//       _subscription.cancel();
//     }, onError: (error) {
//       // handle error here.
//     });
//     initStoreInfo();
//     super.initState();
//   }

//   Future<void> initStoreInfo() async {
//     final bool isAvailable = await _connection.isAvailable();
//     if (!isAvailable) {
//       setState(() {
//         _isAvailable = isAvailable;
//         _products = [];
//         _purchases = [];
//         _purchasePending = false;
//         _loading = false;
//       });
//       return;
//     }

//     ProductDetailsResponse productDetailResponse =
//         await _connection.queryProductDetails(_kProductIds.toSet());
//     if (productDetailResponse.error != null) {
//       setState(() {
//         _isAvailable = isAvailable;
//         _products = productDetailResponse.productDetails;
//         _purchases = [];

//         _purchasePending = false;
//         _loading = false;
//       });
//       return;
//     }

//     if (productDetailResponse.productDetails.isEmpty) {
//       setState(() {
//         _isAvailable = isAvailable;
//         _products = productDetailResponse.productDetails;
//         _purchases = [];

//         _purchasePending = false;
//         _loading = false;
//       });
//       return;
//     }

//     final QueryPurchaseDetailsResponse purchaseResponse =
//         await _connection.queryPastPurchases();
//     if (purchaseResponse.error != null) {
//       // handle query past purchase error..
//     }
//     final List<PurchaseDetails> verifiedPurchases = [];
//     for (PurchaseDetails purchase in purchaseResponse.pastPurchases) {
//       if (await _verifyPurchase(purchase)) {
//         verifiedPurchases.add(purchase);
//       }
//     }
//     setState(() {
//       _isAvailable = isAvailable;
//       _products = productDetailResponse.productDetails;
//       _purchases = verifiedPurchases;
//       _purchasePending = false;
//       _loading = false;
//     });
//   }

//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height,
//       padding: EdgeInsets.all(50),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           InkWell(
//             child: Text(
//               'Cancel',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 18,
//                 fontFamily: 'Roboto',
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//             onTap: () {
//               Navigator.of(context).pop();
//             },
//           ),
//           Text(
//             'aidobsuiofbioubqioufbiubqaioebifbiabewioubfiebwibfibaweiubfiubiuwaebfiobwaeiobfiobwaiebfiubweibfiuabwiebfiuwbofbuibaiwbuobfuiabwiubfiuewagbigifegowi',
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: 18,
//               fontWeight: FontWeight.w400,
//               fontFamily: 'Roboto',
//             ),
//           ),
//           Stack(
//             children: [
//               _purchasePending
//                   ? Center(
//                       child: CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           Color(0xffFfe6746),
//                         ),
//                       ),
//                     )
//                   : Container(),
//               _buildButtons(),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildButtons() {
//     Map<String, PurchaseDetails> purchases =
//         Map.fromEntries(_purchases.map((PurchaseDetails purchase) {
//       if (purchase.pendingCompletePurchase) {
//         InAppPurchaseConnection.instance.completePurchase(purchase);
//       }
//       return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
//     }));

//     if (_loading) {
//       return Center(
//         child: CircularProgressIndicator(
//           valueColor: AlwaysStoppedAnimation<Color>(
//             Color(0xffFfe6746),
//           ),
//         ),
//       );
//     }

//     List<Widget> productList = <Widget>[];
//     productList.addAll(
//       _products.map(
//         (ProductDetails productDetails) {
//           PurchaseDetails previousPurchase = purchases[productDetails.id];
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: SizedBox(
//               width: double.infinity,
//               height: 60,
//               child: FlatButton(
//                 color: previousPurchase != null
//                     ? Colors.grey[200]
//                     : Color(0xffFFE6746),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 onPressed: previousPurchase != null
//                     ? () {}
//                     : () async {
//                         PurchaseParam purchaseParam = PurchaseParam(
//                           productDetails: productDetails,
//                           sandboxTesting: false,
//                         );

//                         _connection.buyNonConsumable(
//                           purchaseParam: purchaseParam,
//                         );
//                       },
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       previousPurchase != null
//                           ? 'Already donated. Thank you.'
//                           : 'Donate ${productDetails.price}',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontFamily: 'Roboto',
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     SizedBox(
//                       width: 3,
//                     ),
//                     Text(
//                       '(one-time)',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontFamily: 'Roboto',
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );

//     return Center(
//       child: Column(children: productList),
//     );
//   }

//   void showPendingUI() {
//     setState(() {
//       _purchasePending = true;
//     });
//   }

//   void deliverProduct(PurchaseDetails purchaseDetails) async {
//     Navigator.pop(context);
//     var alertText = TextStyle(
//       color: Colors.black,
//       fontFamily: 'Roboto',
//       fontWeight: FontWeight.w400,
//       fontSize: 14,
//     );
//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Platform.isAndroid
//             ? AlertDialog(
//                 content: Padding(
//                   padding: const EdgeInsets.only(top: 10),
//                   child: Text(
//                     'Thank you for your donation. It helps a lot.',
//                     textAlign: TextAlign.center,
//                     style: alertText,
//                   ),
//                 ),
//                 actions: [
//                   FlatButton(
//                     onPressed: () {
//                       Navigator.pop(context, "Ok");
//                     },
//                     child: Text(
//                       'Ok',
//                       style: TextStyle(
//                         fontFamily: 'Roboto',
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ),
//                 ],
//               )
//             : CupertinoAlertDialog(
//                 content: Padding(
//                   padding: const EdgeInsets.only(top: 10),
//                   child: Text(
//                     'Thank you for your donation. It helps a lot.',
//                     textAlign: TextAlign.center,
//                     style: alertText,
//                   ),
//                 ),
//                 actions: [
//                   FlatButton(
//                     onPressed: () {
//                       Navigator.pop(context, "Ok");
//                     },
//                     child: Text(
//                       'Ok',
//                       style: TextStyle(
//                         fontFamily: 'Roboto',
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//       },
//     );
//     setState(() {
//       _purchasePending = false;
//       _purchases.add(purchaseDetails);
//     });
//   }

//   void handleError(IAPError error) {
//     setState(() {
//       _purchasePending = false;
//     });
//   }

//   Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
//     // IMPORTANT!! Always verify a purchase before delivering the product.
//     // For the purpose of an example, we directly return true.
//     return Future<bool>.value(true);
//   }

//   void _handleInvalidPurchase(PurchaseDetails purchaseDetails) async {
//     var alertText = TextStyle(
//       color: Colors.black,
//       fontFamily: 'Roboto',
//       fontWeight: FontWeight.w400,
//       fontSize: 14,
//     );

//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Platform.isAndroid
//             ? AlertDialog(
//                 content: Padding(
//                   padding: const EdgeInsets.only(top: 10),
//                   child: Text(
//                     'In App Purchase unavailable',
//                     textAlign: TextAlign.center,
//                     style: alertText,
//                   ),
//                 ),
//                 actions: [
//                   FlatButton(
//                     onPressed: () {
//                       Navigator.pop(context, "Ok");
//                     },
//                     child: Text(
//                       'Ok',
//                       style: TextStyle(
//                         fontFamily: 'Roboto',
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ),
//                 ],
//               )
//             : CupertinoAlertDialog(
//                 content: Padding(
//                   padding: const EdgeInsets.only(top: 10),
//                   child: Text(
//                     'In App Purchase unavailable',
//                     textAlign: TextAlign.center,
//                     style: alertText,
//                   ),
//                 ),
//                 actions: [
//                   FlatButton(
//                     onPressed: () {
//                       Navigator.pop(context, "Ok");
//                     },
//                     child: Text(
//                       'Ok',
//                       style: TextStyle(
//                         fontFamily: 'Roboto',
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//       },
//     );
//   }

//   void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
//     purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
//       if (purchaseDetails.status == PurchaseStatus.pending) {
//         showPendingUI();
//       } else {
//         if (purchaseDetails.status == PurchaseStatus.error) {
//           handleError(purchaseDetails.error);
//         } else if (purchaseDetails.status == PurchaseStatus.purchased) {
//           bool valid = await _verifyPurchase(purchaseDetails);
//           if (valid) {
//             deliverProduct(purchaseDetails);
//           } else {
//             _handleInvalidPurchase(purchaseDetails);
//             return;
//           }
//         }
//         if (purchaseDetails.pendingCompletePurchase) {
//           await InAppPurchaseConnection.instance
//               .completePurchase(purchaseDetails);
//         }
//       }
//     });
//   }
// }
