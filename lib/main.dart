//import 'package:firebase_analytics/observer.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:ihikepakistan/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}


SharedPreferences prefs;
/*
Future<int> getPrefs() async {
  await MyRemoteConfig.init();
  return 0;
  /*if(prefs == null)
    prefs = await SharedPreferences.getInstance();*/
  /*prefs.setStringList('myhiketitles', ['Hike 1', 'Hike 2', 'Hike 3', 'Hike 4', 'Hike 5']);
  prefs.setStringList('myhikelengths', ['12', '5', '6', '7', '9']);
  prefs.setStringList('myhikelengthmiles', ['9', '3', '4', '5', '6']);
  prefs.setString('statsorder', "abcdefghijklmnopqrs");*/
}
*/
class MyApp extends StatelessWidget {
  FirebaseAnalytics analytics = FirebaseAnalytics();
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
