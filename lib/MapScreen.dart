import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
// import 'package:ihikepakistan/MapBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:ihikepakistan/MapState.dart';
import 'package:ihikepakistan/mapboxToken.dart';
import 'package:provider/provider.dart';
import 'Hike.dart';
import 'package:mapbox_gl/mapbox_gl.dart' as mapbox;

BuildContext cardContext;

class MapScreen extends StatelessWidget {
  final Hike hike;

  MapScreen({this.hike});

  @override
  Widget build(BuildContext context) {
    return ListenableProvider(
      create: (_) => MapState(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(hike.title),
          actions: [
            if (!kIsWeb)
              Builder(
                builder: (context) => PopupMenuButton<String>(
                  icon: Icon(Icons.my_location),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'none',
                      child: Text('None'),
                    ),
                    PopupMenuItem(
                      value: 'centered',
                      child: Text('Centered'),
                    ),
                    PopupMenuItem(
                      value: 'compass',
                      child: Text('Compass'),
                    ),
                    PopupMenuItem(
                      value: 'gps',
                      child: Text('Movement'),
                    ),
                  ],
                  onSelected: (value) {
                    MapState mapState = context.read<MapState>();
                    mapState.changeCenterState(value);
                  },
                ),
              ),
            Builder(
              builder: (context) => PopupMenuButton<String>(
                icon: Icon(Icons.map),
                onSelected: (value) {
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
            )
          ],
        ),
        body: Map(
          hike: hike,
        ),
      ),
    );
  }
}

class Map extends StatefulWidget {
  final Hike hike;
  Map({this.hike});
  @override
  MapboxState createState() => MapboxState(hike: hike);
}

class MapboxState extends State<Map> {
  double height = 100;
  bool showLoader = true;
  final Hike hike;
  mapbox.MapboxMapController mapboxMapController;
  MapboxState({this.hike});
  List<mapbox.LatLng> track = [];
  String oldMapStyle = mapbox.MapboxStyles.MAPBOX_STREETS;
  mapbox.Line line;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < hike.data.length - 1; i += 2) {
      track.add(mapbox.LatLng(hike.data[i], hike.data[i + 1]));
    }
  }

  @override
  void dispose() {
    super.dispose();

    MapState mapState = context.read<MapState>();
    mapState.locationStreamSub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Consumer(
            builder: (BuildContext context, MapState mapState, Widget widget) {
          if (mapboxMapController != null && (!showLoader)) {
            mapboxMapController.updateMyLocationTrackingMode({
              MapCenterState.none: mapbox.MyLocationTrackingMode.None,
              MapCenterState.centered: mapbox.MyLocationTrackingMode.Tracking,
              MapCenterState.gps: mapbox.MyLocationTrackingMode.TrackingGPS,
              MapCenterState.compass:
                  mapbox.MyLocationTrackingMode.TrackingCompass,
            }[mapState.mapCenterState]);
            if (line != null)
              mapboxMapController.updateLine(
                  line,
                  mapbox.LineOptions(
                      geometry: mapState.track
                          .map((e) => mapbox.LatLng(e.lat, e.lng))
                          .toList()));
          }
          if (oldMapStyle != mapState.mapStyle && (!showLoader)) {
            oldMapStyle = mapState.mapStyle;
            Future.delayed(Duration(milliseconds: 100)).then((value) {
              setState(() {
                showLoader = true;
              });
            });
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return mapbox.MapboxMap(
            initialCameraPosition: mapboxMapController?.cameraPosition ??
                mapbox.CameraPosition(
                    target: (hike.data == null || hike.data.length == 0)
                        ? mapbox.LatLng(33.693056, 73.063889)
                        : mapbox.LatLng(hike.data[0], hike.data[1]),
                    zoom: 13),
            accessToken: mapboxToken,
            styleString: oldMapStyle,
            myLocationEnabled: true,
            myLocationTrackingMode: mapbox.MyLocationTrackingMode.None,
            myLocationRenderMode: {
              MapCenterState.none: mapbox.MyLocationRenderMode.NORMAL,
              MapCenterState.centered: mapbox.MyLocationRenderMode.NORMAL,
              MapCenterState.gps: mapbox.MyLocationRenderMode.GPS,
              MapCenterState.compass: mapbox.MyLocationRenderMode.COMPASS,
            }[mapState.mapCenterState],
            onMapCreated: (mapbox.MapboxMapController controller) async {
              await Future.delayed(Duration(seconds: 9));
              mapboxMapController = controller;
              controller.addLine(mapbox.LineOptions(
                  geometry: track, lineColor: 'red', lineWidth: 2));
              line = await controller.addLine(mapbox.LineOptions(
                  geometry: mapState.track
                      .map((e) => mapbox.LatLng(e.lat, e.lng))
                      .toList(),
                  lineColor: 'blue',
                  lineWidth: 2));
              setState(() {
                showLoader = false;
              });
            },
          );
        }),
        if (showLoader)
          Center(
            child: CircularProgressIndicator(),
          )
      ],
    );
  }
}

/*
Widget getMap(Hike hike) {
  String htmlId = "7";

  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(htmlId, (int viewId) {
    final mapOptions = map.MapOptions()
      ..zoom = 12
      ..center = map.LatLng(33.738, 73.05);

    final elem = DivElement()
      ..id = htmlId
      ..style.width = "100%"
      ..style.height = "100%"
      ..style.border = 'none';

    final mymap = map.GMap(elem, mapOptions);

    final triangleCoords = <map.LatLng>[];

    //final data = polylinedecoder.Polyline.Decode(precision: 5, encodedString: hike.dataString).decodedCoords;
    if(hike.data != null){
      for(int i = 0; i < hike.data.length-1; i += 2){
        triangleCoords.add(map.LatLng(hike.data[i], hike.data[i+1]));
      }
    }


    map.Polyline(
      map.PolylineOptions()
          ..map = mymap
          ..path = triangleCoords
          ..strokeColor = 'red'
          ..strokeWeight = 5
    );

    return elem;
  });

  return HtmlElementView(viewType: htmlId);
}
*/
/*
    h = roads only
    m = standard roadmap
    p = terrain
    r = somehow altered roadmap
    s = satellite only
    t = terrain only
    y = hybrid
     */
