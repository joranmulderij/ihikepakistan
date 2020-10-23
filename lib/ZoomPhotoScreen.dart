import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';

class ZoomPhotoScreen extends StatelessWidget {
  final String photo;
  final String title;

  ZoomPhotoScreen({this.photo, this.title});

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
                    title: Text(title),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.zoom_out),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  )
                : null,
            body: Center(
              child: PhotoView(
                imageProvider: NetworkImage(
                  photo,
                ),
                initialScale: 1.0,
                maxScale: 5.0,
                minScale: 0.45,
                //enableRotation: true,
              ),
            ),
          );
        },
      ),
    );
  }
}
