import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ihikepakistan/Hike.dart';
import 'package:ihikepakistan/InfoScreen.dart';
import 'package:ihikepakistan/MHNPMapsScreen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:search_page/search_page.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'Hikes.dart';
import 'MapScreen.dart' as mapScreen;
import 'HikeTiles.dart';
import 'dart:convert' as convert;
import 'remoteConfig.dart';

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
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  Future<RemoteConfig> myRemoteConfigFuture;

  HomeState(){
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        setState(() {
          testText = message['data']['home_screen_text'];
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        setState(() {
          testText = message['data']['home_screen_text'];
        });
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        setState(() {
          testText = message['data']['home_screen_text'];
        });
      },
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
        breakPoints = List.from(convert.json
            .decode(MyRemoteConfig.getRemoteConfigValue('category_breakpoints')));
        categories = List.from(convert.json
            .decode(MyRemoteConfig.getRemoteConfigValue('categories')));
        print(categories);
        return Scaffold(
          backgroundColor: Color(0xfffff3d6),
          appBar: AppBar(
            title: Text('Ihike'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () => showSearch(
                  context: context,
                  delegate: SearchPage<Hike>(
                    builder: (hike) => ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        child: Image.asset(
                          'maps/' + hike.photo,
                          fit: BoxFit.cover,
                          height: 60,
                          width: 80,
                          errorBuilder: (BuildContext context, Object object, StackTrace stackTrace){
                            return Image.network(
                              hike.photos[0],
                              fit: BoxFit.cover,
                              height: 60,
                              width: 80,
                            );
                          },
                        ),
                      ),
                      title: Text(hike.title),
                      subtitle: Text(hike.difficulty),
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InfoScreen(hike: hike,),
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
                    suggestion: ListTile(title: Text('Start Typing...'),),
                    failure: ListTile(title: Text('Could not find any Hikes...'),),
                  ),
                )
              ),
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
                    case '3dmap':
                      url_launcher.launch(
                          'https://joranmulderij.github.io/ihikeres/trail3',
                          forceWebView: true,
                          enableJavaScript: true);
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => GlobeScreen(),),);
                      break;
                    case 'addhike':
                      url_launcher
                          .launch('https://forms.gle/CU2bSZ6DQ2BAZhs17');
                      break;
                    case 'rate':
                      url_launcher.launch('https://youtube.com/');
                      break;
                    case 'about':
                      showAboutDialog(
                        context: context,
                        applicationName: 'Ihike Pakistan',
                        applicationVersion: '0.3.4',
                        applicationLegalese: 'Hiking in Pakistan made easy.',
                        applicationIcon: Image.asset('assets/logo_small.png'),
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
                      child: Text('3D Map (beta)'),
                      value: '3dmap',
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
          body: Column(
            children: <Widget>[
              Container(
                height: 400,
                child: CarouselSlider.builder(
                  //scrollDirection: Axis.horizontal,
                  itemCount: Hikes.all.length,
                  carouselController: controller,
                  itemBuilder: (BuildContext context, int index) =>
                      HikeTile(
                        hike: Hikes.all[index],
                      ),
                  options: CarouselOptions(
                    //carouselController: controller,
                    scrollDirection: Axis.horizontal,
                    enableInfiniteScroll: false,
                    initialPage: 0,
                    height: 400,
                    //onScrolled: (double value){ print(value); },
                    onPageChanged:
                        (int value, CarouselPageChangedReason reason) {
                      if (reason != CarouselPageChangedReason.manual)
                        return;
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
              ),
              MarkdownBody(
                  data: testText ?? MyRemoteConfig.getRemoteConfigValue(
                      'homescreen_text')),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: Colors.amber,
            type: BottomNavigationBarType.shifting,
            showUnselectedLabels: true,
            currentIndex: tabIndex,
            unselectedFontSize: 12,
            onTap: (int index) {
              if (index == categories.length) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => mapScreen.MapScreen(
                      hike: Hike(
                        data: [],
                        title: 'Blank Map',
                      ),
                    ),
                  ),
                );
                return;
              }
              setState(() {
                tabIndex = index;
              });
              controller.animateToPage(breakPoints[tabIndex],
                  curve: Curves.easeInOut);
            },
            unselectedItemColor: Colors.grey,
            selectedFontSize: 16,
            items: categories
                .map((e) => BottomNavigationBarItem(
              icon: Icon(Icons.location_pin),
              label: e,
            ))
                .toList()
              ..add(BottomNavigationBarItem(
                  icon: Icon(Icons.map), label: "Blank Map")),
          ),
        );
      }
    );
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
