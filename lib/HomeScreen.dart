import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ihikepakistan/Hike.dart';
import 'package:ihikepakistan/MHNPMapsScreen.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
                    )
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
                        data: [
                          33.74255,
                          73.08216,
                          33.74274,
                          73.08204,
                          33.74279,
                          73.08194,
                          33.74284,
                          73.08193,
                          33.74293,
                          73.08232,
                          33.74309,
                          73.08218,
                          33.74319,
                          73.08218,
                          33.74329,
                          73.08187,
                          33.74355,
                          73.08164,
                          33.7436,
                          73.08229,
                          33.74375,
                          73.08264,
                          33.74372,
                          73.08206,
                          33.74372,
                          73.08134,
                          33.74382,
                          73.08166,
                          33.74391,
                          73.08099,
                          33.74425,
                          73.08191,
                          33.74488,
                          73.08183,
                          33.74502,
                          73.08199,
                          33.74507,
                          73.08177,
                          33.74512,
                          73.08186,
                          33.74581,
                          73.0825,
                          33.74599,
                          73.08241,
                          33.74593,
                          73.08214,
                          33.74617,
                          73.08198,
                          33.74583,
                          73.08167,
                          33.74617,
                          73.08156,
                          33.74605,
                          73.08094,
                          33.74666,
                          73.0815,
                          33.74703,
                          73.08163,
                          33.74759,
                          73.08165,
                          33.74776,
                          73.08152,
                          33.74753,
                          73.0813,
                          33.74819,
                          73.08128,
                          33.74764,
                          73.08085,
                          33.74826,
                          73.08071,
                          33.74837,
                          73.08063,
                          33.74827,
                          73.08049,
                          33.7484,
                          73.0804,
                          33.74867,
                          73.08034,
                          33.74892,
                          73.07967,
                          33.74906,
                          73.07827,
                          33.74936,
                          73.07856,
                          33.7495,
                          73.0792,
                          33.74973,
                          73.07949,
                          33.74976,
                          73.07929,
                          33.75003,
                          73.07948,
                          33.75027,
                          73.07921,
                          33.75038,
                          73.07884,
                          33.75059,
                          73.07847,
                          33.75092,
                          73.07852,
                          33.75105,
                          73.07728,
                          33.75083,
                          73.07664,
                          33.75113,
                          73.07608,
                          33.75183,
                          73.07634,
                          33.75202,
                          73.07612,
                          33.75213,
                          73.07641,
                          33.75275,
                          73.07646,
                          33.75312,
                          73.07691,
                          33.75327,
                          73.0776,
                          33.75417,
                          73.07855,
                          33.75455,
                          73.07859,
                          33.75468,
                          73.07808,
                          33.75414,
                          73.07596,
                          33.75436,
                          73.07565,
                          33.75432,
                          73.0754,
                          33.75456,
                          73.07537,
                          33.7547,
                          73.07515,
                          33.75439,
                          73.07477,
                          33.75437,
                          73.0743,
                          33.75483,
                          73.07444,
                          33.75533,
                          73.07409,
                          33.7556,
                          73.0742,
                          33.75564,
                          73.07443,
                          33.75599,
                          73.07365,
                          33.75625,
                          73.07353,
                          33.75647,
                          73.07308,
                          33.75705,
                          73.07325,
                          33.75735,
                          73.07308,
                          33.75752,
                          73.07266,
                          33.75742,
                          73.07155,
                          33.75752,
                          73.07124,
                          33.7575,
                          73.07089,
                          33.75771,
                          73.07109,
                          33.75811,
                          73.07213,
                          33.75846,
                          73.07251,
                          33.75871,
                          73.07268,
                          33.75896,
                          73.07253,
                          33.75966,
                          73.07259,
                          33.75935,
                          73.07224,
                          33.75903,
                          73.07175,
                          33.759,
                          73.07151,
                          33.75905,
                          73.07137,
                          33.75919,
                          73.07153,
                          33.7593,
                          73.07089,
                          33.75941,
                          73.07026,
                          33.75938,
                          73.06971,
                          33.75973,
                          73.06956,
                          33.75999,
                          73.06945,
                          33.7603,
                          73.06944,
                          33.76069,
                          73.06879,
                          33.76075,
                          73.06862,
                          33.76075,
                          73.06842,
                          33.76061,
                          73.0681,
                          33.76069,
                          73.06806,
                          33.76087,
                          73.06818,
                          33.76088,
                          73.06785,
                          33.76077,
                          73.06757,
                          33.76064,
                          73.06699
                        ],
                        id: 'blank',
                        title: 'Blank Map',
                        height: 0,
                        heightFeet: 0,
                        length: 0,
                        lengthMiles: 0,
                        time: 0,
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
