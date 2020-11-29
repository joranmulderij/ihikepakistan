import 'package:flutter/material.dart';


class PurchaseDialog extends StatefulWidget {
  @override
  _PurchaseDialogState createState() => _PurchaseDialogState();
}

class _PurchaseDialogState extends State<PurchaseDialog> {
  @override
  void initState() {
    super.initState();
    //setup();
  }

  /*Future<void> setup() async {
    final bool available = await InAppPurchaseConnection.instance.isAvailable();
    if(available){
      const Set<String> _kIds = {'ihike_premium'};
      final ProductDetailsResponse response = await InAppPurchaseConnection.instance.queryProductDetails(_kIds);
      if (response.notFoundIDs.isNotEmpty) {
        print('error!');
        return;
      }
      List<ProductDetails> products = response.productDetails;
      print(products);

      //final PurchaseParam purchaseParam = PurchaseParam(productDetails: products[0]);
      //InAppPurchaseConnection.instance.buyNonConsumable(purchaseParam: purchaseParam);
    }
    else{
      print('not available!!!!!!!!!!!');
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
