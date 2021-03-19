
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

void purchase() async {
  if(kIsWeb) return;
  const Set<String> _kIds = {'ihikepro'};
  final ProductDetailsResponse response = await InAppPurchaseConnection.instance.queryProductDetails(_kIds);
  print(response.productDetails);
  if (response.notFoundIDs.isNotEmpty) {
    return;
  }
  List<ProductDetails> products = response.productDetails;
  final PurchaseParam purchaseParam = PurchaseParam(productDetails: products[0]);
  InAppPurchaseConnection.instance.buyNonConsumable(purchaseParam: purchaseParam);
}


