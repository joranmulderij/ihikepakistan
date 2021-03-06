import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
// import 'package:ihikepakistan/MapBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ihikepakistan/MapState.dart';
import 'package:ihikepakistan/mapboxToken.dart';
import 'package:provider/provider.dart';
import 'Hike.dart';
import 'package:mapbox_gl/mapbox_gl.dart' as mapbox;

BuildContext cardContext;

class MapScreen extends StatelessWidget {
  final Hike hike;
  BannerAd myBanner;

  MapScreen({this.hike}) {
    if (kIsWeb) return;
    myBanner = BannerAd(
      //adUnitId: 'ca-app-pub-8065750617902524/9195577946', // Real ad.
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test ad.
      size: AdSize.banner,
      request: AdRequest(
          nonPersonalizedAds: false,
          keywords: [hike.title, 'Hiking', 'Map', 'Pakistan', 'Islamabad', 'Trail']),
      listener: AdListener(),
    );
    myBanner.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Column(
        children: [
          Expanded(
            child: Map(
              hike: hike,
              mapStyle: context.watch<MapState>().mapStyle,
            ),
          ),
          if (!kIsWeb)
            Container(
              height: 50,
              child: AdWidget(
                ad: myBanner,
              ),
            )
        ],
      ),
    );
  }
}

class Map extends StatefulWidget {
  final Hike hike;
  final mapbox.CameraPosition cameraPosition;
  final String mapStyle;
  Map({this.hike, this.cameraPosition, @required this.mapStyle}) {
    print(hike);
  }
  @override
  MapboxState createState() => MapboxState(
      hike: hike, lastCameraPosition: cameraPosition, oldMapStyle: mapStyle);
}

class MapboxState extends State<Map> {
  double height = 100;
  bool showLoader = true;
  final Hike hike;
  mapbox.MapboxMapController mapboxMapController;
  MapboxState({this.hike, this.lastCameraPosition, this.oldMapStyle});
  List<List<mapbox.LatLng>> tracks = [];
  String oldMapStyle;
  mapbox.Line line;
  mapbox.CameraPosition lastCameraPosition;

  @override
  void initState() {
    super.initState();

    hike.multiData.forEach((element) {
      List<mapbox.LatLng> data = [];
      for (var i = 0; i < element.length - 1; i += 2) {
        data.add(mapbox.LatLng(element[i], element[i + 1]));
      }
      tracks.add(data);
    });
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
            initialCameraPosition: lastCameraPosition ??
                mapbox.CameraPosition(
                    target: (hike.multiData?.length ?? 0) == 0
                        ? mapbox.LatLng(33.693056, 73.063889)
                        : mapbox.LatLng(
                            hike.multiData[0][0], hike.multiData[0][1]),
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
            onCameraIdle: () {
              if (mapboxMapController.cameraPosition != null)
                lastCameraPosition = mapboxMapController.cameraPosition;
            },
            onMapCreated: (mapbox.MapboxMapController controller) async {
              for (var i = 0; i < 10; i++) {
                await Future.delayed(Duration(seconds: 1));
                tryAddTracks(controller);
              }
              mapboxMapController = controller;
              tracks.forEach((track) {
                controller.addLine(mapbox.LineOptions(
                    geometry: track, lineColor: 'red', lineWidth: 2));
              });
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

  void tryAddTracks(mapbox.MapboxMapController controller) {
    controller.clearLines();
    tracks.forEach((track) {
      controller.addLine(
          mapbox.LineOptions(geometry: track, lineColor: 'red', lineWidth: 2));
    });
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
