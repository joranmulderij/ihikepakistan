

class GpxProvider{
  static getSingleItem(double lat, double lon){
    return '<trkpt lat="$lat" lon="$lon"></trkpt>\n';

  }
  static const String begin = '''
<?xml version='1.0' encoding='UTF-8'?>
<gpx version="1.1" creator="JOSM GPX export" xmlns="http://www.topografix.com/GPX/1/1"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
  <metadata>
    <bounds minlat="33.7345903" minlon="73.0544123" maxlat="33.738516" maxlon="73.0585536"/>
  </metadata>
  <trk>
    <name>Trail 2</name>''';
  static String getGpx(List<double> track, String name){
    String begin = '''
<?xml version='1.0' encoding='UTF-8'?>
<gpx version="1.1" creator="Ihike Pakistan Gpx Export" xmlns="http://www.topografix.com/GPX/1/1"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
  <trk>
    <name>$name</name>
    <trkseg>\n''';
    String end = '''    </trkseg>
  </trk>
</gpx>''';
    String trackseg = '';
    for(int i = 0; i < track.length-1; i+=2){
      String item = getSingleItem(track[i], track[i+1]);
      trackseg += item;
    }
    return begin + trackseg + end;
  }
}