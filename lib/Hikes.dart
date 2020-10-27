import 'package:ihikepakistan/remoteConfig.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'Hike.dart';
import 'dart:convert' as convert;

class Hikes {
  static List<Hike> get all{
    List<Hike> toReturn = [];
    dynamic json = convert.json.decode(MyRemoteConfig.getRemoteConfigValue('hikes'));
    for (var i = 0; i < json.length; i++) {
      print(json[i]['data']);
      toReturn.add(Hike(
        height: json[i]['climb'].toString(),
        //heightFeet: json[i]['ascentfeet'].toDouble(),
        //dataString: json[i]['polyline'].toString(),
        title: json[i]['name'].toString(),
        time: json[i]['time'].toString(),
        length: json[i]['length'].toString(),
        //lengthMiles: json[i]['lengthmiles'].toDouble(),
        photo: json[i]['photo'].toString(),
        storyShort: json[i]['storyshort'].toString(),
        story: json[i]['story'].toString(),
        data: json[i]['data'] == null ? null : List.from(json[i]['data']),
        photos: json[i]['photos'],
      ));
    }
    return toReturn;
  }
}
