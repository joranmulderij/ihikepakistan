/*@js.JS()
library get_standalone;*/

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ihikepakistan/Hike.dart';
import 'package:ihikepakistan/InfoScreen.dart';
import 'package:ihikepakistan/MHNPMapsScreen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ihikepakistan/MapState.dart';
import 'package:ihikepakistan/ShareTile.dart';
import 'package:provider/provider.dart';
import 'package:search_page/search_page.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'Hikes.dart';
import 'MapScreen.dart' as mapScreen;
import 'HikeTiles.dart';
import 'dart:convert' as convert;
import 'remoteConfig.dart';
import 'package:mapbox_gl/mapbox_gl.dart' as mapbox;
//import 'package:js/js.dart' as js;

/*@js.JS('getStandalone')
external bool getStandalone();
@js.JS('isIos')
external bool isIos();
@js.JS('isAndroid')
external bool isAndroid();*/

class HomeScreen extends StatefulWidget {
  HomeState createState() => HomeState();
}

class HomeState extends State<HomeScreen> {
  int tabIndex = 0;
  CarouselController controller = CarouselController();
  List<int> breakPoints;
  List<String> categories;
  String testText;
  final FirebaseAnalytics analytics = FirebaseAnalytics();
  final FirebaseMessaging _firebaseMessaging =
      kIsWeb ? null : FirebaseMessaging();
  Future<RemoteConfig> myRemoteConfigFuture;

  Future<dynamic> onPushMessage(Map<String, dynamic> message) async {
    print(message);
  }

  HomeState() {
    if (!kIsWeb)
      _firebaseMessaging.configure(
        onMessage: onPushMessage,
        onLaunch: onPushMessage,
        onResume: onPushMessage,
        onBackgroundMessage: null,
      );
  }

  @override
  void initState() {
    super.initState();
    analytics.setCurrentScreen(screenName: '/home');
    myRemoteConfigFuture = MyRemoteConfig.init();
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
        future: myRemoteConfigFuture,
        builder: (BuildContext context, AsyncSnapshot<RemoteConfig> snapshot) {
          breakPoints = List.from(convert.json.decode(
              MyRemoteConfig.getRemoteConfigValue('category_breakpoints')));
          categories = List.from(convert.json
              .decode(MyRemoteConfig.getRemoteConfigValue('categories')));
          return Scaffold(
            //backgroundColor: Color(0xfffff3d6),
            appBar: AppBar(
              title: Text('Ihike Pakistan'),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () => showSearch(
                          context: context,
                          delegate: SearchPage<Hike>(
                            builder: (hike) => ListTile(
                              leading: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                child: Image.asset(
                                  'maps/' + hike.photo,
                                  fit: BoxFit.cover,
                                  height: 60,
                                  width: 80,
                                  errorBuilder: (BuildContext context,
                                      Object object, StackTrace stackTrace) {
                                    return CachedNetworkImage(
                                      imageUrl: hike.photos[0],
                                      fit: BoxFit.cover,
                                      height: 60,
                                      width: 80,
                                    );
                                  },
                                ),
                              ),
                              title: Text(
                                hike.title,
                                style: TextStyle(color: Colors.black),
                              ),
                              subtitle: Text(
                                hike.difficulty,
                                style: TextStyle(color: Colors.grey),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InfoScreen(
                                      hike: hike,
                                    ),
                                  ),
                                );
                              },
                            ),
                            filter: (hike) => [
                              hike.title,
                              hike.tags,
                              hike.difficulty,
                            ],
                            showItemsOnEmpty: true,
                            items: Hikes.all,
                            searchLabel: 'Search Hikes',
                            failure: ListTile(
                              title: Text('Could not find any Hikes...'),
                            ),
                          ),
                        )),
                PopupMenuButton<String>(
                  onSelected: (String item) async {
                    switch (item) {
                      case 'officialMaps':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MHNPMapsScreen(),
                          ),
                        );
                        break;
                      case 'addhike':
                        url_launcher
                            .launch('https://forms.gle/CU2bSZ6DQ2BAZhs17');
                        break;
                      case 'rate':
                        if (await url_launcher.canLaunch(
                            'https://play.google.com/store/apps/details?id=com.ihikepakistan')) {
                          url_launcher.launch(
                              'https://play.google.com/store/apps/details?id=com.ihikepakistan');
                        }
                        break;
                      case 'about':
                        showAboutDialog(
                          context: context,
                          applicationName: 'Ihike Pakistan',
                          applicationVersion: '0.4.4',
                          applicationIcon: Image.asset(
                            'assets/icon_small.png',
                            height: 70,
                            width: 70,
                          ),
                          children: [
                            ListTile(
                              title: Text('About'),
                              subtitle: Text(
                                  'Ihike Pakistan is a hiking app to help you find your next Hike, and Navigate you over that Hike.'),
                            ),
                            ListTile(
                              title: Text('Website'),
                              subtitle: Text('ihikepakistan.com'),
                              trailing: Icon(Icons.launch),
                              onTap: () async {
                                if (await url_launcher.canLaunch(
                                    'https://www.ihikepakistan.com/')) {
                                  await url_launcher
                                      .launch('https://www.ihikepakistan.com/');
                                }
                              },
                            ),
                            ListTile(
                              title: Text('Developer'),
                              subtitle: Text('Joran Mulderij'),
                              trailing: Icon(Icons.launch),
                              onTap: () async {
                                if (await url_launcher.canLaunch(
                                    'https://play.google.com/store/apps/dev?id=6998590952049518161')) {
                                  await url_launcher.launch(
                                      'https://play.google.com/store/apps/dev?id=6998590952049518161');
                                }
                              },
                            ),
                            ShareTile(
                              msg:
                                  'Ihike Pakistan is a hiking app to help you find your next Hike, and Navigate you over that Hike.\nhttps://www.ihikepakistan.com/',
                            ),
                          ],
                        );
                        break;
                    }
                  },
                  icon: Icon(Icons.more_vert),
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        child: Text('Official MHNP Maps'),
                        value: 'officialMaps',
                      ),
                      PopupMenuItem(
                        child: Text('Add a Hike'),
                        value: 'addhike',
                      ),
                      PopupMenuItem(
                        child: Text('Rate this app!'),
                        value: 'rate',
                      ),
                      PopupMenuItem(
                        child: Text('About Ihike Pakistan'),
                        value: 'about',
                      ),
                    ];
                  },
                ),
              ],
            ),
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ListenableProvider(
                  create: (_) => MapState(),
                  child: mapScreen.Map(
                    hike: Hike(
                        multiData: () {
                          List<List<double>> data = [];
                          Hikes.all.forEach((hike) {
                            hike.multiData.forEach((track) {
                              data.add(track);
                            });
                          });
                          return data;
                        }()
                    ),
                  ),
                ),
                CarouselSlider.builder(
                  itemCount: Hikes.all.length,
                  carouselController: controller,
                  itemBuilder: (BuildContext context, int index) => HikeTile(
                    hike: Hikes.all[index],
                  ),
                  options: CarouselOptions(
                    scrollDirection: Axis.horizontal,
                    enableInfiniteScroll: false,
                    initialPage: 0,
                    height: 180,
                    aspectRatio: 2.23,
                    onPageChanged:
                        (int value, CarouselPageChangedReason reason) {
                      if (reason != CarouselPageChangedReason.manual) return;
                      int index;
                      for (int i = breakPoints.length - 1; i >= 0; i--) {
                        if (value >= breakPoints[i]) {
                          index = i;
                          break;
                        }
                      }
                      index = (index ?? 2);
                      setState(() {
                        tabIndex = index;
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }
}
/*
class MyHikesTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final void Function() onPressed;

  MyHikesTile({this.title, this.subTitle, this.onPressed});

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
      child: GestureDetector(
        onTap: onPressed,
        child: Card(
          elevation: 5,
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text('My Hikes'),
                subtitle: Text('${prefs.getStringList('myhiketitles').length} Hikes'),
              ),
              Container(
                height: 260,
                child: ListView.separated(
                  itemBuilder: (BuildContext context, int index){
                    return ListTile(
                      leading: Icon(Icons.person_pin),
                      title: Text(prefs.getStringList('myhiketitles')[index]),
                      subtitle: Text('${prefs.getStringList('myhikelengths')[index]}km (${prefs.getStringList('myhikelengthmiles')[index]}mi)'),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index){
                    return Divider();
                  },
                  itemCount: prefs.getStringList('myhiketitles').length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
