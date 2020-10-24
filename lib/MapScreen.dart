
import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:ihikepakistan/MapBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:ihikepakistan/MapState.dart';
import 'package:provider/provider.dart';
import 'Hike.dart';
import 'package:location/location.dart' as location;
import 'package:mapbox_gl/mapbox_gl.dart' as mapbox;



BuildContext cardContext;

class MapScreen extends StatelessWidget {
  final Hike hike;

  MapScreen({this.hike});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hike.title),
      ),
      body: ListenableProvider<MapState>(
        create: (_) => MapState(track: hike.data),
        child: Map(hike: hike,),
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
  final Hike hike;
  StreamSubscription listener;
  mapbox.MapboxMapController mapboxMapController;
  mapbox.Line myLine;
  MapboxState({this.hike});

  @override
  void initState() {
    super.initState();
    Stream.periodic(Duration(seconds: 1)).listen((event) {
      MapState mapState = context.read<MapState>();
      mapState.setHasLocation(DateTime.now().difference(mapState.lastLocationTime) < Duration(seconds: 10));
    });
    listener = location.Location.instance.onLocationChanged.listen((location.LocationData data) {
      print(data.altitude);
      setState(() {
        MapState mapState = context.read<MapState>();
        mapState.setLocation(
          data.latitude,
          data.longitude,
          data.altitude,
          data.speed*3.6,
          data.accuracy,
          data.speedAccuracy,
        );
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    listener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        /*map.GoogleMap(
          initialPosition: map.GeoCoord(33, 73),
          mapType: map.MapType.roadmap,
          mobilePreferences: map.MobileMapPreferences(
            compassEnabled: true,
            mapToolbarEnabled: true,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
          ),
          webPreferences: map.WebMapPreferences(
            zoomControl: true,
            rotateControl: true,
            dragGestures: true,
          ),
        ),*/
        //MapBottomSheet(),
        Consumer(
          builder: (BuildContext context, MapState mapState, Widget widget){
            if(mapboxMapController != null && myLine != null){
              mapboxMapController.updateLine(myLine, mapbox.LineOptions(geometry: mapState.mapboxTrack));
              mapboxMapController.updateMyLocationTrackingMode(mapState.isCentered ? mapbox.MyLocationTrackingMode.TrackingCompass : mapbox.MyLocationTrackingMode.None);
            }
            return mapbox.MapboxMap(
              initialCameraPosition: mapbox.CameraPosition(target: (hike.data == null || hike.data.length == 0) ? mapbox.LatLng(33, 73) : mapbox.LatLng(hike.data[0], hike.data[1]), zoom: 15),
              accessToken: "pk.eyJ1Ijoiam9yYW4tbXVsZGVyaWoiLCJhIjoiY2tnYXB4cGE1MDlqejJ0a3ptY202eTU4YSJ9.A1HkSrcQ7aAbZ9wfa6p_uQ",
              styleString: "mapbox://styles/mapbox/outdoors-v11",
              myLocationEnabled: true,
              logoViewMargins: Point(0, height),
              myLocationTrackingMode: mapbox.MyLocationTrackingMode.Tracking,
              compassViewPosition: mapbox.CompassViewPosition.TopLeft,
              onMapCreated: (mapbox.MapboxMapController controller) async {
                List<mapbox.LatLng> track = [];
                for(int i = 0; i < hike.data.length-1; i+=2){
                  track.add(mapbox.LatLng(hike.data[i], hike.data[i+1]));
                }
                await Future.delayed(Duration(seconds: 5));
                mapboxMapController = controller;
                controller.addLine(mapbox.LineOptions(geometry: track, lineColor: 'red', lineWidth: 2));
                myLine = await controller.addLine(mapbox.LineOptions(geometry: mapState.mapboxTrack, lineWidth: 2, lineColor: 'purple'));
              },
            );
          }
            ),
        MapBottomSheet(),
      ],
    );
  }

  void setHeight(double height){
    setState(() {
      this.height = height;
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

    print(triangleCoords);

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