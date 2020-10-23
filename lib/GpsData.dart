//import 'package:geolocator/geolocator.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';

/*class GpsDataList {
  List<GpsData> list = [];

  void add(GpsData data) {
    list.add(data);
  }

  LatLng getLast() {
    return list.last.getLocation();
  }

  String getString() {
    String listString = '';
    for (int i = 0; i < list.length; i++) {
      listString += list[i].getString();
    }
    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
<Placemark>
  <name>New York City</name>
  <description>New York City</description>
  <LineString>
    <tessellate>1</tessellate>
    <coordinates>$listString</coordinates>
  </LineString>
</Placemark>
</Document>
</kml>''';
  }
}

class GpsData {
  double lat;
  double lon;
  double accuracy;
  double altitude;
  double speed;
  double speedAccuracy;
  double timeStamp;

  GpsData(Position data) {
    this.fromLocationData(data);
  }

  void fromLocationData(Position data) {
    lon = data.longitude;
    lat = data.latitude;
    accuracy = data.accuracy;
    altitude = data.altitude;
    speed = data.speed;
    speedAccuracy = data.speedAccuracy;
    //timeStamp = data.;
  }

  LatLng getLocation() {
    return LatLng(lat, lon);
  }

  String getString() {
    return '$lat,$lon,$altitude\n';
  }
}
*/
