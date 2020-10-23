import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ihikepakistan/Hike.dart';
import 'package:ihikepakistan/MHNPMapsScreen.dart';
import 'package:ihikepakistan/MapScreen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'Hikes.dart';
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

  @override
  void initState() {
    super.initState();
  }

  void getBreakpoints() {
    if (breakPoints != null) {
      breakPoints = List.from(convert.json
          .decode(MyRemoteConfig.getRemoteConfigValue('category_breakpoints')));
      categories = List.from(convert.json
          .decode(MyRemoteConfig.getRemoteConfigValue('categories')));
    }
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: MyRemoteConfig.init(),
      builder: (BuildContext context, AsyncSnapshot<RemoteConfig> snapshot) {
        breakPoints = List.from(convert.json
            .decode(MyRemoteConfig.getRemoteConfigValue('category_breakpoints')));
        categories = List.from(convert.json
            .decode(MyRemoteConfig.getRemoteConfigValue('categories')));
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
                  data: MyRemoteConfig.getRemoteConfigValue(
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
                    builder: (context) => MapScreen(
                      hike: Hike(
                        data: [],
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
