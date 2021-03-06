// import 'dart:async';
//
// import 'package:carp_background_location/carp_background_location.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:maps_toolkit/maps_toolkit.dart' as maps_toolkit;
// import 'package:mapbox_gl/mapbox_gl.dart' as mapbox;
// import 'package:flutter/material.dart';
// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
// import 'package:toast/toast.dart';
// import 'package:location/location.dart' as location;
//
import 'dart:async';

import 'package:carp_background_location/carp_background_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:ihikepakistan/main.dart';
import 'package:ihikepakistan/showUpgradeSnackbar.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;

class IhikeLatLng {
  double lat;
  double lng;

  IhikeLatLng(this.lat, this.lng);
}

class MapState with ChangeNotifier {
  MapCenterState mapCenterState = MapCenterState.none;
  String mapStyle = MapboxStyles.OUTDOORS;
  StreamSubscription locationStreamSub;
  LocationManager locationManager;
  Stream<LocationDto> dtoStream;
  StreamSubscription<LocationDto> dtoSubscription;
  StreamSubscription timeSub;
  List<IhikeLatLng> track = [];
  double currentAlt;
  double climb = 0;
  DateTime startTime;
  double totalDistance = 0;
  List<List<double>> multiData;
  bool notificationsAreOn = false;
  bool onTrack;
  bool alarmIsSounding = false;
  bool running = false;
  bool hasRun = false;

  MapState() {
    if (!kIsWeb) locationManager = LocationManager.instance;
    getLocation();
  }

  @override
  void dispose() {
    super.dispose();

    locationStreamSub.cancel();
    if (!kIsWeb) dtoSubscription.cancel();
  }

  void togglePlay(BuildContext context) async {
    // await showDialog(
    //   context: context,
    //   builder: (context) => AlertDialog(
    //     title: Text('Background Location'),
    //     content: Text('This app collects location data to make sure you stay on the path even when the app is closed or not in use.'),
    //   ),
    // );
    if (!prefs.containsKey('has_showed_disclaimer') && !kIsWeb) {
      await ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
            content: Text(
                'This app collects location data to make sure you stay on the path even when the app is closed or not in use.'),
            behavior: SnackBarBehavior.floating,
          ))
          .closed;
      prefs.setBool('has_showed_disclaimer', true);
    }
    if (!hasRun && !running) {
      hasRun = true;
      running = true;
      timeSub = Stream.periodic(Duration(seconds: 1)).listen((event) {
        notifyListeners();
      });
      startTime = DateTime.now().subtract(Duration(seconds: 1));
      if (!kIsWeb) startCarpLocation();
    } else if (hasRun && running) {
      running = false;
      timeSub.cancel();
      if (!kIsWeb) stopCarpLocation();
    }
    notifyListeners();
  }

  void getLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    locationStreamSub = location.onLocationChanged.listen((data) {
      if (canAddLocation(data.latitude, data.longitude) && running) {
        if (currentAlt != null) {
          if (data.altitude > currentAlt) {
            climb += data.altitude - currentAlt;
          }
        }
        currentAlt = data.altitude;
        if (track.isNotEmpty)
          totalDistance += mp.SphericalUtil.computeDistanceBetween(
              mp.LatLng(data.latitude, data.longitude),
              mp.LatLng(track.last.lat, track.last.lng));
        track.add(IhikeLatLng(data.latitude, data.longitude));
        notifyListeners();
        checkAlarm();
      }
    });
  }

  startCarpLocation() {
    locationManager.interval = 1;
    locationManager.distanceFilter = 2;
    locationManager.notificationTitle = 'Ihike Pakistan is Running';
    locationManager.notificationMsg = 'Ihike Pakistan collects location data to make sure you stay on the path even when the app is closed or not in use.';
    dtoStream = locationManager.dtoStream;
    dtoSubscription = dtoStream.listen((data) {
      if (canAddLocation(data.latitude, data.longitude) && running) {
        if (track.isNotEmpty)
          totalDistance += mp.SphericalUtil.computeDistanceBetween(
              mp.LatLng(data.latitude, data.longitude),
              mp.LatLng(track.last.lat, track.last.lng));
        track.add(IhikeLatLng(data.latitude, data.longitude));
      }
      checkAlarm();
      notifyListeners();
    });
    locationManager.start();
  }

  void stopCarpLocation() async {
    dtoSubscription.cancel();
    await locationManager.stop();
  }

  void toggleNotifications() {
    notificationsAreOn = !notificationsAreOn;
    notifyListeners();
    checkAlarm();
  }

  void checkAlarm() {
    bool isOnTrack = false;
    for (List<double> trail in multiData) {
      for (int i = 0; i < trail.length - 1; i += 2) {
        if (mp.SphericalUtil.computeDistanceBetween(
                mp.LatLng(trail[i], trail[i + 1]),
                mp.LatLng(track.last.lat, track.last.lng)) <
            40) isOnTrack = true;
      }
    }
    if (onTrack != isOnTrack) {
      onTrack = isOnTrack;
      notifyListeners();
    }
    if ((!isOnTrack) && notificationsAreOn) {
      if (!alarmIsSounding) {
        alarmIsSounding = true;
        FlutterRingtonePlayer.playAlarm(
          looping: true,
          asAlarm: true,
        );
      }
    } else if (isOnTrack || (!notificationsAreOn)) {
      if (alarmIsSounding) {
        alarmIsSounding = false;
        FlutterRingtonePlayer.stop();
      }
    }
  }

  bool canAddLocation(double lat, double lng) {
    for (IhikeLatLng latLng in track) {
      if (mp.SphericalUtil.computeDistanceBetween(
              mp.LatLng(lat, lng), mp.LatLng(latLng.lat, latLng.lng)) <
          2) {
        return false;
      }
    }
    return true;
  }

  changeMapStyle(String value) {
    mapStyle = value;
    notifyListeners();
  }

  changeCenterState(String value) {
    mapCenterState = {
      'none': MapCenterState.none,
      'centered': MapCenterState.centered,
      'compass': MapCenterState.compass,
      'gps': MapCenterState.gps,
    }[value];
    notifyListeners();
  }

  Widget getOnPathTile(BuildContext context) => hasRun ? Positioned(
    left: 10,
    right: 10,
    top: 10,
    child: Card(
      color: onTrack != null ? (onTrack ? Colors.green : Colors.red) : Colors.amber,
      elevation: 5,
      child: ListTile(
        title: Text(onTrack != null ? (onTrack
            ? 'You\'re on track!'
            : 'You left the path!') : 'No Location'),
        subtitle: notificationsAreOn
            ? Text('Notifications are on')
            : null,
        trailing: kIsWeb
            ? null
            : IconButton(
          icon: notificationsAreOn
              ? Icon(Icons.notifications_active)
              : Icon(Icons.notifications_outlined),
          onPressed: () {
            if (isPro())
              toggleNotifications();
            else {
              showUpgradeSnackbar(context,
                  'Notifications are only available in Ihike Pakistan Pro.');
            }
          },
        ),
      ),
    ),
  ) : Container();
}

// class MapState with ChangeNotifier {
//   LocationManager locationManager;
//   Stream<LocationDto> dtoStream;
//   StreamSubscription<location.LocationData> locationStream;
//   StreamSubscription<LocationDto> dtoSubscription;
//
//   onData(LocationDto data) {
//     print(data.latitude);
//     setLocation(data.latitude, data.longitude, data.altitude, data.speed * 3.6,
//         data.accuracy, data.speedAccuracy, data.heading);
//   }
//
//   MapState({this.track}) {
//     /*Stream.periodic(Duration(seconds: 1)).listen((event) {
//       print('sdf');
//       _totalTime = (recordingState == RecordingState.recording)
//           ? DateTime.now().difference(_startTime)
//           : Duration(seconds: 0);
//       if ((_speed ?? 0) > 3 && _recordingState == RecordingState.recording) {
//         _movingTime += Duration(seconds: 1);
//       } else {
//         _pauseTime += Duration(seconds: 1);
//       }
//       setLocation(33, 73, 250, 4, 20, 10, 70);
//       print('sdf');
//       setHasLocation(
//           DateTime.now().difference(_lastLocationTime) < Duration(seconds: 30));
//     });*/
//     locationStream = location.Location.instance.onLocationChanged
//         .listen((location.LocationData data) {
//       setLocation(
//         data.latitude,
//         data.longitude,
//         data.altitude,
//         data.speed * 3.6,
//         data.accuracy,
//         data.speedAccuracy,
//         (_myTrack.length >= 2)
//             ? maps_toolkit.SphericalUtil.computeHeading(
//                 maps_toolkit.LatLng(data.latitude, data.longitude),
//                 maps_toolkit.LatLng(
//                     _myTrack[_myTrack.length - 2], _myTrack.last))
//             : null,
//       );
//     });
//
//     if (!kIsWeb) {
//       locationManager = LocationManager.instance;
//       locationManager.interval = 1;
//       locationManager.distanceFilter = 0;
//       // locationaccuracy
//       //locationManager.accuracy = LocationAccuracy.HIGH;
//       locationManager.notificationTitle = 'Ihike Pakistan';
//       locationManager.notificationMsg = 'Ihike Pakistan is running.';
//       dtoStream = locationManager.dtoStream;
//     }
//   }
//
//   void startLocationStream() async {
//     if (kIsWeb) return;
//     // Subscribe if it hasn't been done already
//     if (dtoSubscription != null) {
//       dtoSubscription.cancel();
//     }
//     dtoSubscription = dtoStream.listen(onData);
//   }
//
//   void stopLocationStream() async {
//     if (kIsWeb) return;
//     dtoSubscription.cancel();
//     await locationManager.stop();
//   }
//
//   final List<double> track;
//   double _latitude;
//   double _longitude;
//   double _altitude;
//   double _speed;
//   double _speedAccuracy;
//   double _maxSpeed;
//   double _accuracy;
//   double _averageSpeed;
//   double _maxAltitude;
//   double _minAltitude;
//   double _ascent = 0;
//   double _descent = 0;
//   double _averageSpeedWhileMoving;
//   int _wayPoints = 0;
//   DateTime _startTime;
//   DateTime _lastLocationTime = DateTime.now();
//   bool _hasLocation = false;
//   Duration _totalTime = Duration(seconds: 0);
//   Duration _movingTime = Duration(seconds: 0);
//   Duration _pauseTime = Duration(seconds: 0);
//   double _distanceWalked = 0;
//   MapCenterState _mapCenterState = MapCenterState.none;
//   bool _showsNotifications = true;
//   RecordingState _recordingState = RecordingState.begin;
//   double _headingAngle;
//   bool _onTrack = true;
//   String _mapStyle = mapbox.MapboxStyles.MAPBOX_STREETS;
//   int _mapStyleIndex = 0;
//   List<mapbox.LatLng> mapboxTrack = [];
//   List<double> _myTrack = [];
//
//   bool get showsNotifications => _showsNotifications;
//   RecordingState get recordingState => _recordingState;
//   double get latitude => _hasLocation ? _latitude : null;
//   double get longitude => _hasLocation ? _longitude : null;
//   double get altitude => _hasLocation ? _altitude : null;
//   double get speed => _hasLocation ? _speed : null;
//   double get speedAccuracy => _hasLocation ? _speedAccuracy : null;
//   double get maxSpeed => _maxSpeed;
//   double get accuracy => _hasLocation ? _accuracy : null;
//   double get averageSpeed => _averageSpeed;
//   double get averageSpeedWhileMoving => _averageSpeedWhileMoving;
//   double get maxAltitude => _maxAltitude;
//   double get minAltitude => _minAltitude;
//   double get headingAngle => _hasLocation ? _headingAngle : null;
//   double get descent => _descent;
//   double get ascent => _ascent;
//   int get wayPoints => _wayPoints;
//   DateTime get startTime => _startTime;
//   Duration get totalTime => _totalTime;
//   Duration get movingTime => _movingTime;
//   Duration get pauseTime => _pauseTime;
//   double get percentageTimeMoving =>
//       _movingTime.inSeconds /
//       (_movingTime.inSeconds + _pauseTime.inSeconds) *
//       100;
//   double get distanceWalked => _distanceWalked;
//   bool get hasLocation => _hasLocation;
//   DateTime get lastLocationTime => _lastLocationTime;
//   bool get onTrack => _onTrack;
//   MapCenterState get mapCenterState => _mapCenterState;
//   String get mapStyle => _mapStyle;
//   int get mapStyleIndex => _mapStyleIndex;
//   List<double> get myTrack => _myTrack;
//
//   void setMapType(String newValue, int newIndex) {
//     _mapStyle = newValue;
//     _mapStyleIndex = newIndex;
//     notifyListeners();
//   }
//
//   void setHasLocation(bool has) {
//     _hasLocation = has;
//     notifyListeners();
//   }
//
//   void setLocation(double lat, double lng, double alt, double spd, double acc,
//       double spdacc, double heading) {
//     print(lat);
//     /*print(lat);
//     if (_myTrack.length >= 2
//         ? maps_toolkit.SphericalUtil.computeDistanceBetween(
//                 maps_toolkit.LatLng(_myTrack[_myTrack.length - 2],
//                     _myTrack[_myTrack.length - 1]),
//                 maps_toolkit.LatLng(lat, lng)) <
//             5
//         : true) {
//       print('Remove Node!!!!!!!!!!!!!!!!!');
//       if (_recordingState == RecordingState.recording)
//         _pauseTime += DateTime.now().difference(_lastLocationTime);
//       _lastLocationTime = DateTime.now();
//       return;
//     } else {
//       print('Add Node!!!!!!!!!!!!!!!!!!');
//       if (_recordingState == RecordingState.recording)
//         _movingTime += DateTime.now().difference(_lastLocationTime);
//       _lastLocationTime = DateTime.now();
//     }
//     _headingAngle = heading;
//     if (recordingState == RecordingState.recording && _hasFirstLocation) {
//       _wayPoints++;
//       _altitudeSum += alt;
//       _averageAltitude = _altitudeSum / _wayPoints;
//       _averageSpeed = _distanceWalked / _totalTime.inHours;
//       _averageSpeedWhileMoving = _distanceWalked / _movingTime.inHours;
//       mapboxTrack.add(mapbox.LatLng(lat, lng));
//       _myTrack.add(lat);
//       _myTrack.add(lng);
//       _distanceWalked += maps_toolkit.SphericalUtil.computeDistanceBetween(
//               maps_toolkit.LatLng(_latitude, _longitude),
//               maps_toolkit.LatLng(lat, lng)) /
//           1000;
//       if (_altitude > alt)
//         _ascent += _altitude - alt;
//       else
//         _descent += alt - _altitude;
//       if (spd > (_maxSpeed ?? double.minPositive)) _maxSpeed = spd;
//       if (alt > (_maxAltitude ?? double.minPositive)) _maxAltitude = alt;
//       if (alt < (_minAltitude ?? double.maxFinite)) _minAltitude = alt;
//       bool inRange = (track ?? []).length < 4;
//       for (int i = 0; i < track.length - 1; i += 2) {
//         if (maps_toolkit.SphericalUtil.computeDistanceBetween(
//                 maps_toolkit.LatLng(_latitude, _longitude),
//                 maps_toolkit.LatLng(track[i], track[i + 1])) <
//             50) inRange = true;
//       }
//       if (!inRange) {
//         if (_showsNotifications && _onTrack == true) {
//           playAlarm();
//         }
//         _onTrack = false;
//       } else {
//         if (_showsNotifications && !_onTrack) {
//           stopAlarm();
//         }
//         _onTrack = true;
//       }
//     }*/
//     if (lat == _latitude && lng == _longitude) return;
//     _latitude = lat;
//     _longitude = lng;
//     _altitude = alt;
//     _speed = spd;
//     _accuracy = acc;
//     _speedAccuracy = spdacc;
//     _hasLocation = true;
//     _lastLocationTime = DateTime.now();
//     if (isTooClose() && recordingState == RecordingState.recording) addNode();
//     notifyListeners();
//   }
//
//   bool isTooClose() {
//     if (_myTrack.length < 2) return true;
//     return (_myTrack[_myTrack.length - 2] - _latitude) < 2 &&
//         (_myTrack[_myTrack.length - 1] - _longitude) < 2;
//   }
//
//   void addNode() {
//     _myTrack.add(_latitude);
//     _myTrack.add(_longitude);
//     mapboxTrack.add(mapbox.LatLng(_latitude, _longitude));
//   }
//
//   void playAlarm() {
//     FlutterRingtonePlayer.play(
//         android: AndroidSounds.alarm, ios: IosSounds.alarm);
//   }
//
//   void stopAlarm() {
//     FlutterRingtonePlayer.stop();
//   }
//
//   void stopRecording() {
//     _recordingState = RecordingState.finished;
//     stopAlarm();
//     notifyListeners();
//     stopLocationStream();
//   }
//
//   void startPause() {
//     if (_recordingState == RecordingState.begin) {
//       startLocationStream();
//       _startTime = DateTime.now();
//       _recordingState = RecordingState.recording;
//       if (!_onTrack && _showsNotifications) playAlarm();
//     } else if (_recordingState == RecordingState.recording) {
//       _recordingState = RecordingState.paused;
//       stopAlarm();
//     } else if (_recordingState == RecordingState.paused) {
//       _recordingState = RecordingState.recording;
//       if (!_onTrack && _showsNotifications) playAlarm();
//     }
//     notifyListeners();
//   }
//
//   void toggleNotifications() {
//     _showsNotifications = !_showsNotifications;
//     if (!_showsNotifications) stopAlarm();
//     if (_showsNotifications &&
//         !_onTrack &&
//         _recordingState == RecordingState.recording) playAlarm();
//     notifyListeners();
//   }
//
//   void toggleIsCentered(context) {
//     switch (_mapCenterState) {
//       case MapCenterState.none:
//         _mapCenterState = MapCenterState.centered;
//         Toast.show('Map Center Mode:\nCentered (no rotation)', context,
//             duration: 3);
//         break;
//       case MapCenterState.centered:
//         _mapCenterState = MapCenterState.gps;
//         Toast.show('Map Center Mode:\nMovement', context, duration: 3);
//         break;
//       case MapCenterState.gps:
//         _mapCenterState = MapCenterState.compass;
//         Toast.show('Map Center Mode:\nCompass', context, duration: 3);
//         break;
//       case MapCenterState.compass:
//         _mapCenterState = MapCenterState.none;
//         Toast.show('Map Center Mode:\nNone', context, duration: 3);
//         break;
//     }
//     notifyListeners();
//   }
// }
//
// enum RecordingState {
//   begin,
//   recording,
//   paused,
//   finished,
// }
//
enum MapCenterState {
  none,
  centered,
  compass,
  gps,
}
//
enum MapType { normal }
