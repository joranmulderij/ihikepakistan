
import 'package:maps_toolkit/maps_toolkit.dart' as maps_toolkit;
import 'package:mapbox_gl/mapbox_gl.dart' as mapbox;
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class MapState with ChangeNotifier{
  final List<double> track;
  MapState({this.track});
  double _latitude;
  double _longitude;
  double _altitude;
  double _speed;
  double _speedAccuracy;
  double _maxSpeed;
  double _accuracy;
  double _averageSpeed;
  double _maxAltitude;
  double _minAltitude;
  double _averageAltitude;
  double _ascent = 0;
  double _descent = 0;
  double _averageSpeedWhileMoving;
  int _wayPoints = 0;
  DateTime _startTime;
  DateTime _lastLocationTime = DateTime.now();
  bool _hasLocation = false;
  Duration _totalTime = Duration(seconds: 0);
  Duration _movingTime = Duration(seconds: 0);
  double _distanceWalked = 0;
  int _mapType = 0;
  bool _isCentered = true;
  bool _showsNotifications = true;
  RecordingState _recordingState = RecordingState.begin;
  double _headingAngle;
  bool _onTrack = true;
  
  List<mapbox.LatLng> mapboxTrack = [];

  bool get isCentered => _isCentered;
  bool get showsNotifications => _showsNotifications;
  RecordingState get recordingState => _recordingState;

  double get latitude => _hasLocation ? _latitude : null;
  double get longitude => _hasLocation ? _longitude : null;
  double get altitude => _hasLocation ? _altitude : null;
  double get speed => _hasLocation ? _speed : null;
  double get speedAccuracy => _hasLocation ? _speedAccuracy : null;
  double get maxSpeed => _maxSpeed;
  double get accuracy => _hasLocation ? _accuracy : null;
  double get averageSpeed => _averageSpeed;
  double get averageSpeedWhileMoving => _averageSpeedWhileMoving;
  double get maxAltitude => _maxAltitude;
  double get minAltitude => _minAltitude;
  double get averageAltitude => _averageAltitude;
  double get headingAngle => _hasLocation ? _headingAngle : null;
  double get descent => _descent;
  double get ascent => _ascent;
  int get wayPoints => _wayPoints;
  DateTime get startTime => _startTime;
  Duration get totalTime => _totalTime;
  Duration get movingTime => _movingTime;
  Duration get pauseTime => _totalTime - _movingTime;
  double get percentageTimeMoving => _movingTime.inSeconds / _totalTime.inSeconds * 100;
  double get distanceWalked => _distanceWalked;
  int get mapType => _mapType;
  bool get hasLocation => _hasLocation;
  DateTime get lastLocationTime => _lastLocationTime;
  bool get onTrack => _onTrack;

  double _speedSum = 0;
  double _speedWMovingSum = 0;
  double _altitudeSum = 0;

  void setMapType(int newValue){
    _mapType = newValue;
    notifyListeners();
  }

  void setHasLocation(bool has){
    _hasLocation = has;
    notifyListeners();
  }

  void setLocation(double lat, double lng, double alt, double spd, double acc, double spdacc){
    if(_latitude != null && _longitude != null) {
      if (maps_toolkit.SphericalUtil.computeDistanceBetween(
          maps_toolkit.LatLng(_latitude, _longitude),
          maps_toolkit.LatLng(lat, lng)) > 3)
        _headingAngle = maps_toolkit.SphericalUtil.computeHeading(
            maps_toolkit.LatLng(_latitude, _longitude),
            maps_toolkit.LatLng(lat, lng));
      else
        _headingAngle = null;
    }
    if(recordingState == RecordingState.recording){
      _wayPoints++;
      _speedSum += spd;
      if(spd >= 1) _speedWMovingSum += spd;
      _altitudeSum += alt;
      _averageAltitude = _altitudeSum / wayPoints;
      _averageSpeed = _speedSum / wayPoints;
      _averageSpeedWhileMoving = _speedWMovingSum / wayPoints;
      if(maps_toolkit.SphericalUtil.computeDistanceBetween(maps_toolkit.LatLng(_latitude, _longitude), maps_toolkit.LatLng(lat, lng)) > 3){
        mapboxTrack.add(mapbox.LatLng(lat, lng));
        _distanceWalked += maps_toolkit.SphericalUtil.computeDistanceBetween(maps_toolkit.LatLng(_latitude, _longitude), maps_toolkit.LatLng(lat, lng)) / 1000;
      }
      if(_altitude > alt)
        _ascent += _altitude - alt;
      else
        _descent += alt - _altitude;
      if(spd > (_maxSpeed??double.minPositive))
        _maxSpeed = spd;
      if(alt > (_maxAltitude??double.minPositive))
        _maxAltitude = alt;
      if(alt < (_minAltitude??double.maxFinite))
        _minAltitude = alt;
      bool inRange = (track??[]).length < 4;
      for (int i = 0; i < track.length - 1; i += 2) {
        if (maps_toolkit.SphericalUtil.computeDistanceBetween(
            maps_toolkit.LatLng(_latitude, _longitude),
            maps_toolkit.LatLng(track[i], track[i + 1])) < 30) inRange = true;
      }
      if(!inRange){
        if(_showsNotifications && _onTrack == true){
          playAlarm();
        }
        _onTrack = false;
      } else {
        if(_showsNotifications && !_onTrack){
          stopAlarm();
        }
        _onTrack = true;
      }
    }
    _latitude = lat;
    _longitude = lng;
    _altitude = alt;
    _speed = spd;
    _accuracy = acc;
    _speedAccuracy = spdacc;
    _hasLocation = true;
    _lastLocationTime = DateTime.now();
    notifyListeners();
  }

  void playAlarm(){
    FlutterRingtonePlayer.playAlarm();
  }

  void stopAlarm(){
    FlutterRingtonePlayer.stop();
  }

  void stopRecording(){
    _recordingState = RecordingState.finished;
    notifyListeners();
  }

  void startPause(){
    if(_recordingState == RecordingState.begin){
      _recordingState = RecordingState.recording;
    }
    else if(_recordingState == RecordingState.recording){
      _recordingState = RecordingState.paused;
    }
    else if(_recordingState == RecordingState.paused){
      _recordingState = RecordingState.recording;
    }
    notifyListeners();
  }
  void toggleNotifications(){
    _showsNotifications = !_showsNotifications;
    if(!_showsNotifications){
      stopAlarm();
    }
    notifyListeners();
  }
  void toggleIsCentered(){
    _isCentered = !_isCentered;
    notifyListeners();
  }
}

enum RecordingState{
  begin,
  recording,
  paused,
  finished,
}

enum mapCenterState{
  none,
  centered,
  compass,
  gps,
}