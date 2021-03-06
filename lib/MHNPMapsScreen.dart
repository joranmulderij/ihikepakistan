import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ZoomPhotoScreen.dart';

// ignore: must_be_immutable
class MHNPMapsScreen extends StatelessWidget {
  CarouselController controller = CarouselController();
  int realIndex = 0;

  final List<String> photos = [
    'http://iwmb.org.pk/wp-content/uploads/2018/06/3Trails-2-4-and-6.jpg',
    'http://iwmb.org.pk/wp-content/uploads/2018/06/4Trail-3-5-2017.jpg',
    'http://iwmb.org.pk/wp-content/uploads/2018/06/5Trail-4-2017.jpg',
    'http://iwmb.org.pk/wp-content/uploads/2018/06/6Trail-3-5-Rata-Hottar-2017-1.jpg',
    'http://iwmb.org.pk/wp-content/uploads/2018/06/7Trails-6-and-Western-Trails-.jpg',
    'http://iwmb.org.pk/wp-content/uploads/2018/06/8Kalinjer-and-Western-Trails-2017.jpg',
    'http://iwmb.org.pk/wp-content/uploads/2018/06/9MHNP-Trails-Map-2017.jpg'
  ];

  final List<String> titles = [
    'Trails 2, 4 & 6',
    'Trails 3 & 5',
    'Trail 4',
    'Trails 3, 5 & Ratta Hotar',
    'Trails 6 & Western Trails',
    'Kalinjar & Western Trails',
    'MHNP Trails Map'
  ];

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
        return true;
      },
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          if (orientation == Orientation.landscape) {
            SystemChrome.setEnabledSystemUIOverlays([]);
          } else {
            SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
          }
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: (orientation == Orientation.portrait)
                ? AppBar(
                    title: Text('Offical MHNP Maps'),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.zoom_in),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ZoomPhotoScreen(
                                photo: photos[realIndex],
                                title: titles[realIndex],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  )
                : null,
            body: Center(
              child: CarouselSlider.builder(
                options: CarouselOptions(
                  height: 1000,
                  enlargeCenterPage: false,
                  viewportFraction: 1,
                  enableInfiniteScroll: false,
                  onPageChanged: (int index, reason) {
                    realIndex = index;
                  },
                ),
                carouselController: controller,
                itemCount: photos.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    child: CachedNetworkImage(
                      fadeInDuration: Duration(seconds: 0),
                      fadeOutDuration: Duration(seconds: 0),
                      imageUrl: photos[index],
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (BuildContext context, _, __) =>
                          Icon(Icons.broken_image),
                    ),
                    onDoubleTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ZoomPhotoScreen(
                            photo: photos[realIndex],
                            title: titles[realIndex],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            floatingActionButton: Text(
              'Double tap to Zoom.',
              style: TextStyle(
                fontSize: 24,
                color: (orientation == Orientation.portrait)
                    ? Colors.white
                    : Colors.transparent,
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        },
      ),
    );
  }
}
