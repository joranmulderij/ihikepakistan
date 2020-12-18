import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:ihikepakistan/HomeScreen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() {
  //InAppPurchaseConnection.enablePendingPurchases();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
//  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FirebaseAnalytics analytics = FirebaseAnalytics();
  MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //debugShowMaterialGrid: true,
      //debugShowCheckedModeBanner: false,
      title: 'Ihike Pakistan',
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics),],
      theme: ThemeData(
        primarySwatch: Colors.amber,
        primaryColor: Color(0xff006600),
        accentColor: Color(0xff478e00),
        floatingActionButtonTheme:
            FloatingActionButtonThemeData(backgroundColor: Colors.orange),
      ),
      home: HomeScreen(),
    );
  }
}
