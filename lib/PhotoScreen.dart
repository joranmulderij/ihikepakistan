import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Hike.dart';

class PhotoScreen extends StatelessWidget {
  final Hike hike;
  final int index;

  PhotoScreen({this.hike, this.index});

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
                    title: Text(hike.title + ' Photos'),
                  )
                : null,
            body: Center(
              child: CarouselSlider.builder(
                itemCount: hike.photos.length,
                itemBuilder: (BuildContext context, int index) {
                  return hike.photos[index].contains('data:image/png;base64,')
                      ? Image.memory(
                          base64Decode(hike.photos[index]
                              .replaceFirst('data:image/png;base64,', '')),
                        )
                      : Image.network(hike.photos[index]);
                },
                options: CarouselOptions(
                  viewportFraction: 1,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: true,
                  initialPage: index,
                  height: 1000,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
