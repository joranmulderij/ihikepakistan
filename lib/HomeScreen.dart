import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ihikepakistan/Hike.dart';
import 'package:ihikepakistan/MHNPMapsScreen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'MapState.dart';
import 'package:ihikepakistan/ShareTile.dart';
import 'package:ihikepakistan/main.dart';
import 'package:ihikepakistan/purchase.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'Hikes.dart';
import 'MapScreen.dart' as mapScreen;
import 'HikeTiles.dart';
import 'package:mapbox_gl/mapbox_gl.dart' as mapbox;
import 'package:ihikepakistan/showUpgradeSnackbar.dart';
import 'StatsBottomSheet.dart';

class HomeScreen extends StatefulWidget {
  HomeState createState() => HomeState();
}

class HomeState extends State<HomeScreen> {
  CarouselController controller = CarouselController();
  String testText;
  final FirebaseAnalytics analytics = FirebaseAnalytics();
  final FirebaseMessaging _firebaseMessaging =
      kIsWeb ? null : FirebaseMessaging();
  Future<RemoteConfig> myRemoteConfigFuture;
  bool expanded = true;

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
  void didChangeDependencies() {
    super.didChangeDependencies();

    context.read<MapState>().multiData = () {
      List<List<double>> data = [];
      Hikes.all.forEach((hike) {
        hike.multiData.forEach((track) {
          data.add(track);
        });
      });
      return data;
    }();
  }

  @override
  void initState() {
    super.initState();
    analytics.setCurrentScreen(screenName: '/home');
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
        future: myRemoteConfigFuture,
        builder: (BuildContext context, AsyncSnapshot<RemoteConfig> snapshot) {
          return Scaffold(
            //backgroundColor: Color(0xfffff3d6),
            appBar: AppBar(
              title:
                  Text('Ihike Pakistan' + (isPro() && !kIsWeb ? ' Pro' : '')),
              actions: <Widget>[
                // IconButton(
                //   icon: Icon(Icons.search),
                //   onPressed: () => showSearch(
                //     context: context,
                //     delegate: SearchPage<Hike>(
                //       builder: (hike) => ListTile(
                //         leading: ClipRRect(
                //           borderRadius: BorderRadius.all(Radius.circular(5)),
                //           child: MyImageView(hike.photo),
                //         ),
                //         title: Text(
                //           hike.title,
                //           style: TextStyle(color: Colors.black),
                //         ),
                //         subtitle: Text(
                //           hike.difficulty,
                //           style: TextStyle(color: Colors.grey),
                //         ),
                //         onTap: () {
                //           Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //               builder: (context) => InfoScreen(
                //                 hike: hike,
                //               ),
                //             ),
                //           );
                //         },
                //       ),
                //       filter: (hike) => [
                //         hike.title,
                //         hike.tags,
                //         hike.difficulty,
                //       ],
                //       showItemsOnEmpty: true,
                //       items: Hikes.allListed,
                //       searchLabel: 'Search Hikes',
                //       failure: ListTile(
                //         title: Text('We could not find any Hikes...'),
                //       ),
                //     ),
                //   ),
                // ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.map),
                  onSelected: (value) {
                    if (value ==
                            'mapbox://styles/joran-mulderij/ckf52g8c627vf19o1yn0j72al' &&
                        !isPro()) {
                      showUpgradeSnackbar(context,
                          'Satellite Contours is only available in Ihike Pakistan Pro.');
                      return;
                    }
                    MapState mapState = context.read<MapState>();
                    mapState.changeMapStyle(value);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: mapbox.MapboxStyles.MAPBOX_STREETS,
                      child: Text('Normal'),
                    ),
                    PopupMenuItem(
                      value: mapbox.MapboxStyles.OUTDOORS,
                      child: Text('Terrain'),
                    ),
                    PopupMenuItem(
                      value: mapbox.MapboxStyles.SATELLITE,
                      child: Text('Satellite'),
                    ),
                    PopupMenuItem(
                      value: mapbox.MapboxStyles.SATELLITE_STREETS,
                      child: Text('Hybrid'),
                    ),
                    PopupMenuItem(
                      value: mapbox.MapboxStyles.DARK,
                      child: Text('Dark'),
                    ),
                    PopupMenuItem(
                      value:
                          'mapbox://styles/joran-mulderij/ckf52g8c627vf19o1yn0j72al',
                      child: Text('Satellite Contours'),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  onSelected: (String item) async {
                    switch (item) {
                      case 'buy':
                        purchase();
                        break;
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
                          applicationVersion: '1.2.3',
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
                                    'https://github.com/joranmulderij')) {
                                  await url_launcher.launch(
                                      'https://github.com/joranmulderij');
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
                        child: Text('Upgrade to Pro'),
                        value: 'buy',
                      ),
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
                mapScreen.MyMap(
                  mapStyle: mapbox.MapboxStyles.OUTDOORS,
                  cameraPosition: mapbox.CameraPosition(
                    target: mapbox.LatLng(33.693056, 73.063889),
                    zoom: 10,
                  ),
                  hike: Hike(multiData: () {
                    List<List<double>> data = [];
                    Hikes.all.forEach((hike) {
                      hike.multiData.forEach((track) {
                        data.add(track);
                      });
                    });
                    return data;
                  }()),
                ),
                if (expanded)
                  Consumer<MapState>(
                    builder: (context, mapState, _) => Positioned(
                      left: 10,
                      right: 10,
                      top: 10,
                      child: Card(
                        color: mapState.onTrack ? Colors.green : Colors.red,
                        elevation: 5,
                        child: ListTile(
                          title: Text(mapState.onTrack
                              ? 'You\'re on track!'
                              : 'You left the path!'),
                          subtitle: mapState.notificationsAreOn
                              ? Text('Notifications are on')
                              : null,
                          trailing: kIsWeb
                              ? null
                              : IconButton(
                                  icon: mapState.notificationsAreOn
                                      ? Icon(Icons.notifications_active)
                                      : Icon(Icons.notifications_outlined),
                                  onPressed: () {
                                    if (isPro())
                                      mapState.toggleNotifications();
                                    else {
                                      showUpgradeSnackbar(context,
                                          'Notifications are only available in Ihike Pakistan Pro.');
                                    }
                                  },
                                ),
                        ),
                      ),
                    ),
                  ),
                if (expanded && !context.watch<MapState>().hasRun)
                  CarouselSlider.builder(
                    itemCount: Hikes.allListed.length,
                    carouselController: controller,
                    itemBuilder: (BuildContext context, int index) => HikeTile(
                      hike: Hikes.allListed[index],
                    ),
                    options: CarouselOptions(
                        scrollDirection: Axis.horizontal,
                        enableInfiniteScroll: false,
                        autoPlayInterval: Duration(seconds: 10),
                        initialPage: 0,
                        viewportFraction: 0.9,
                        height: 180,
                        autoPlay: true),
                  ),
              ],
            ),
            floatingActionButton: Builder(
              builder: (context) => Padding(
                padding: EdgeInsets.only(
                    bottom: (context.watch<MapState>().hasRun || !expanded)
                        ? 0.0
                        : 115.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      heroTag: null,
                      mini: true,
                      backgroundColor: context.watch<MapState>().running
                          ? Colors.red
                          : (context.watch<MapState>().hasRun
                              ? Colors.grey
                              : Colors.green),
                      child: Icon(context.watch<MapState>().running
                          ? Icons.stop
                          : Icons.play_arrow),
                      onPressed: (context.watch<MapState>().hasRun &&
                              !context.watch<MapState>().running)
                          ? null
                          : () {
                              context.read<MapState>().togglePlay(context);
                            },
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    FloatingActionButton(
                      heroTag: null,
                      mini: true,
                      child: Icon(expanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up),
                      onPressed: () {
                        setState(() {
                          expanded = !expanded;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            bottomSheet: (context.watch<MapState>().hasRun && expanded)
                ? StatsBottomSheet()
                : null,
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
