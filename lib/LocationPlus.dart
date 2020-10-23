




class LocationPlus{
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;
  final double speedAccuracy;
  final double maxSpeed;
  final double accuracy;
  final double averageSpeed;
  final double maxAltitude;
  final double minAltitude;
  final double averageAltitude;
  final double ascent;
  final double descent;
  final double averageSpeedWhileMoving;
  final double wayPoints;
  final Duration time;
  final Duration movingTime;
  final Duration pauseTime;
  final double percentageTimeMoving;
  final double distanceWalked;

  LocationPlus({this.distanceWalked, this.pauseTime, this.percentageTimeMoving, this.averageAltitude, this.movingTime, this.time, this.wayPoints, this.maxSpeed, this.averageSpeedWhileMoving, this.accuracy, this.altitude, this.ascent, this.averageSpeed, this.descent, this.latitude, this.longitude, this.maxAltitude, this.minAltitude, this.speed, this.speedAccuracy});
}