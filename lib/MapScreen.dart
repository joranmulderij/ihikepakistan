import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'MapState.dart';
import 'package:ihikepakistan/main.dart';
import 'package:ihikepakistan/mapboxToken.dart';
import 'package:provider/provider.dart';
import 'Hike.dart';
import 'package:mapbox_gl/mapbox_gl.dart' as mapbox;
import 'showUpgradeSnackbar.dart';
import 'StatsBottomSheet.dart';

BuildContext cardContext;

class MapScreen extends StatefulWidget {
  final Hike hike;

  MapScreen({this.hike});

  @override
  _MapScreenState createState() => _MapScreenState(hike);
}

class _MapScreenState extends State<MapScreen> {
  bool showBottomSheet = true;
  final Hike hike;

  _MapScreenState(this.hike);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    context.read<MapState>().multiData = hike.multiData;
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
          )
        ],
      ),
      body: Stack(
        children: [
          MyMap(
            hike: hike,
            mapStyle: context.watch<MapState>().mapStyle,
          ),
          if (showBottomSheet)
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
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: null,
              mini: true,
              backgroundColor:
                  context.watch<MapState>().running ? Colors.red : Colors.green,
              child: Icon(context.watch<MapState>().running
                  ? Icons.pause
                  : Icons.play_arrow),
              onPressed: () {
                context.read<MapState>().togglePlay(context);
              },
            ),
            SizedBox(
              width: 20,
            ),
            FloatingActionButton(
              heroTag: null,
              mini: true,
              child: Icon(showBottomSheet
                  ? Icons.keyboard_arrow_down
                  : Icons.keyboard_arrow_up),
              onPressed: () {
                setState(() {
                  showBottomSheet = !showBottomSheet;
                });
              },
            ),
          ],
        ),
      ),
      bottomSheet: showBottomSheet ? StatsBottomSheet() : null,
    );
  }
}

class MyMap extends StatefulWidget {
  final Hike hike;
  final mapbox.CameraPosition cameraPosition;
  final String mapStyle;

  MyMap({this.hike, this.cameraPosition, @required this.mapStyle}) {
    print(hike);
  }

  @override
  MapboxState createState() => MapboxState(
      hike: hike, lastCameraPosition: cameraPosition, oldMapStyle: mapStyle);
}

class MapboxState extends State<MyMap> {
  double height = 100;
  bool showLoader = true;
  final Hike hike;
  mapbox.MapboxMapController mapboxMapController;

  MapboxState({this.hike, this.lastCameraPosition, this.oldMapStyle});

  List<List<mapbox.LatLng>> tracks = [];
  String oldMapStyle;
  mapbox.Line line;
  mapbox.Circle locationCircle;

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
            if (locationCircle != null)
              mapboxMapController.updateCircle(
                  locationCircle,
                  mapbox.CircleOptions(
                      geometry: mapState.track.isEmpty
                          ? mapbox.LatLng(0, 0)
                          : mapbox.LatLng(mapState.track.last.lat,
                              mapState.track.last.lng)));
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
            onStyleLoadedCallback: () {},
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
            myLocationRenderMode: kIsWeb
                ? mapbox.MyLocationRenderMode.NORMAL
                : {
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
              mapboxMapController = controller;

              int tried = 0;
              while (controller.lines.isEmpty ||
                  controller.circles.isEmpty && tried++ < 5) {
                await Future.delayed(Duration(seconds: 1));
                tryAddTracks(controller, mapState);
              }
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

  void tryAddTracks(
      mapbox.MapboxMapController controller, MapState mapState) async {
    controller.clearLines();
    controller.clearCircles();
    tracks.forEach((track) async {
      controller.addLine(
          mapbox.LineOptions(geometry: track, lineColor: 'red', lineWidth: 2));
    });
    if (isPro())
      line = await controller.addLine(mapbox.LineOptions(
          geometry:
              mapState.track.map((e) => mapbox.LatLng(e.lat, e.lng)).toList(),
          lineColor: 'blue',
          lineWidth: 2));

    if (kIsWeb)
      locationCircle = await controller.addCircle(mapbox.CircleOptions(
          circleColor: 'blue',
          geometry: mapState.track.isEmpty
              ? mapbox.LatLng(0, 0)
              : mapbox.LatLng(mapState.track.last.lat, mapState.track.last.lng),
          circleRadius: 6,
          circleStrokeColor: 'white',
          circleStrokeWidth: 3));
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
