import 'package:firebase_analytics/observer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ihikepakistan/DefaultHikes.dart';
import 'package:ihikepakistan/HomeScreen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'MapState.dart';
import 'package:ihikepakistan/purchase.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

SharedPreferences prefs;
Function() reload;
bool hasPurchased;

bool isPro() {
  return true;
  return kIsWeb || hasPurchased;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  prefs = await SharedPreferences.getInstance();
  hasPurchased = prefs.getBool('has_pro') ?? false;
  if (!kIsWeb) {
    InAppPurchaseConnection.enablePendingPurchases();
    final Stream<List<PurchaseDetails>> purchaseUpdates = InAppPurchaseConnection.instance.purchaseUpdatedStream;
    purchaseUpdates.listen((newPurchases) {
      if (justDidPurchase && newPurchases.length > 0) InAppPurchaseConnection.instance.completePurchase(newPurchases[0]);
      if (newPurchases.length > 0){
        if(hasPurchased == false){
          hasPurchased = true;
          reload();
        }
      }
    });
  }
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

class MyApp extends StatefulWidget {
  MyApp();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  _reload(){
    setState(() {});
  }

  _MyAppState(){
    reload = _reload;
  }

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
          floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Colors.orange),
        ),
        home: HomeScreen(),
      ),
    );
  }
}
