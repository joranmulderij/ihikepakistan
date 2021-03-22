import 'package:flutter/foundation.dart';
import 'package:ihikepakistan/main.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

bool justDidPurchase = false;

void purchase() async {
  if (kIsWeb) return;
  const Set<String> _kIds = {'ihikepro'};
  final ProductDetailsResponse response =
      await InAppPurchaseConnection.instance.queryProductDetails(_kIds);
  print(response.productDetails);
  if (response.notFoundIDs.isNotEmpty) {
    return;
  }
  List<ProductDetails> products = response.productDetails;
  final PurchaseParam purchaseParam =
      PurchaseParam(productDetails: products[0]);
  if (await InAppPurchaseConnection.instance
      .buyNonConsumable(purchaseParam: purchaseParam)) {
    justDidPurchase = true;
    prefs.setBool('has_pro', true);
    reload();
  }
}
