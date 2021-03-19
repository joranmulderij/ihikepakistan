import 'package:firebase_analytics/observer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ihikepakistan/DefaultHikes.dart';
import 'package:ihikepakistan/HomeScreen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:ihikepakistan/MapState.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

SharedPreferences prefs;
List<PurchaseDetails> purchases = [];

bool isPro(){
  return kIsWeb || purchases.isNotEmpty;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(!kIsWeb){
    InAppPurchaseConnection.enablePendingPurchases();
    final QueryPurchaseDetailsResponse response = await InAppPurchaseConnection.instance.queryPastPurchases();
    if (response.error != null) {
      // Handle the error.
    }
    print(response.pastPurchases);
    purchases = response.pastPurchases;
    final Stream purchaseUpdates =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    purchaseUpdates.listen((newPurchases) {
      purchases = newPurchases;
    });
  }
  prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('hikes'))
    await http.get('https://repo.ihikepakistan.com/hikes.json').then((res) {
      prefs.setString('hikes', res.body);
    }).catchError((error) {
      if (!prefs.containsKey('hikes')) prefs.setString('hikes', defaultHikes);
    });
  else
    http.get('https://repo.ihikepakistan.com/hikes.json').then((res) {
      prefs.setString('hikes', res.body);
    }).catchError((error) {
      if (!prefs.containsKey('hikes')) prefs.setString('hikes', defaultHikes);
    });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
//  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FirebaseAnalytics analytics = FirebaseAnalytics();
  MyApp();

  @override
  Widget build(BuildContext context) {
    return ListenableProvider(
      create: (_) => MapState(),
      child: MaterialApp(
        title: 'Ihike Pakistan',
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        theme: ThemeData(
          primarySwatch: Colors.amber,
          primaryColor: Color(0xff006600),
          accentColor: Color(0xff478e00),
          floatingActionButtonTheme:
              FloatingActionButtonThemeData(backgroundColor: Colors.orange),
        ),
        home: HomeScreen(),
      ),
    );
  }
}
