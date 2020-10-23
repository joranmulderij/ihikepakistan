import 'dart:convert';
import 'dart:math' as math;

class PolylineEncoding {
  static String encodeList(List<double> dataPoints) {
    String polylineString = encode(dataPoints[0]) + encode(dataPoints[1]);
    for (int i = 1; i < dataPoints.length/2; i++) {
      polylineString += encode(dataPoints[i*2] - dataPoints[i*2 - 2]);
      polylineString += encode(dataPoints[i*2 + 1] - dataPoints[i*2 - 1]);
    }
    return polylineString;
  }

  static String encode(double value) {
    int valueInt = (value * 100000).round();
    valueInt = valueInt << 1;
    if (value < 0) valueInt = ~valueInt;
    int value1 = valueInt & 31;
    int value2 = (valueInt & 992) ~/ 32;
    int value3 = (valueInt & 31744) ~/ 1024;
    int value4 = (valueInt & 1015808) ~/ 32768;
    int value5 = (valueInt & 32505856) ~/ 1048576;
    int value6 = (valueInt & 1040187392) ~/ 33554432;
    List<int> byteList = [value1, value2, value3, value4, value5, value6];
    while (byteList.last == 0 && byteList.length != 1) {
      byteList.removeLast();
    }
    for (int i = 0; i < byteList.length; i++) {
      if (i != byteList.length - 1) byteList[i] = byteList[i] | 32;
      byteList[i] += 63;
    }
    return AsciiCodec().decode(byteList);
  }

  static List<double> decodeList(String value){
    String valueString = '';
    List<double> finalList = [];
    for (var i = 0; i < value.length; ++i) {
      var o = value[i];
      if(o.allMatches('_`abcdefghijklmnopqrstuvwxyz{|}~').length == 1){
        valueString += o;
      } else {
        valueString += o;
        finalList.add(((finalList.length < 2) ? 0 : finalList[finalList.length-2]) + decode(valueString));
        /*print(((finalList.length < 2) ? 0 : finalList[finalList.length-2]) + decode(valueString));
        print(valueString);
        print(o.allMatches('[_`abcdefghijklmnopqrstuvwxyz{|}~]').length);
        print(decode(valueString));
        print(((finalList.length < 2) ? 0 : finalList[finalList.length-2]));
        print('\n');*/
        print(decode(valueString));
        valueString = '';
      }
    }
    print(valueString);
    return finalList;
  }

  static double decode(String string){
    List<int> values = AsciiCodec().encode(string).map((e) => e - 63).toList();
    for (var i = 0; i < string.length - 1; ++i) {
      values[i] -= 32;
    }

    int r = 0;
    for (var i = 0; i < string.length; ++i) {
      r += values[i] * math.pow(32, i);
    }
    if(r % 2 == 1) r = ~r;
    r = r >> 1;

    return (r / 100000);
  }

  getGpx(List<double> dataPoints){
    return 'gpx file';
  }

  getKml(List<double> dataPoints){
    return 'kml file';
  }
}
