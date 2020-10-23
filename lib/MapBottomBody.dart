import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'MapState.dart';
//import 'package:flutter_compass/flutter_compass.dart';





class MapBottomBody extends StatelessWidget {
  final double bottomSheetHeight;

  MapBottomBody({this.bottomSheetHeight});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        child: Column(
          children: <Widget>[
            Container(
              color: Theme.of(context).primaryColor,
              child: Builder(builder: (BuildContext context) => TabBar(
                labelPadding: EdgeInsets.zero,
                labelStyle: TextStyle(color: Colors.black),
                indicatorColor: Colors.amber,
                tabs: <Widget>[
                  Tab(child: GestureDetector(child: Text('Distance'), onTap: bottomSheetHeight == 300 ? (){DefaultTabController.of(context).animateTo(0);} : null,),),
                  Tab(child: GestureDetector(child: Text('Speed'), onTap: bottomSheetHeight == 300 ? (){DefaultTabController.of(context).animateTo(1);} : null,),),
                  Tab(child: GestureDetector(child: Text('Altitude'), onTap: bottomSheetHeight == 300 ? (){DefaultTabController.of(context).animateTo(2);} : null,),),
                  Tab(child: GestureDetector(child: Text('Location'), onTap: bottomSheetHeight == 300 ? (){DefaultTabController.of(context).animateTo(3);} : null,),),
                  Tab(child: GestureDetector(child: Text('Time'), onTap: bottomSheetHeight == 300 ? (){DefaultTabController.of(context).animateTo(4);} : null,),),
                  /*Tab(text: 'Location',),
                  Tab(text: 'Altitude',),
                  Tab(text: 'Time',),
                  Tab(text: 'Distance',),*/
                ],
                indicatorWeight: 5,
              ),),
            ),
            Expanded(
              child: Consumer<MapState>(
                builder: (BuildContext context, MapState mapState, Widget widget){
                  return TabBarView(
                    children: <Widget>[
                      buildPage(
                        [
                          'Distance Walked',
                          '',
                          'Total Climbed',
                          'Total Descended',
                        ],
                        [
                          mapState?.distanceWalked?.toStringAsFixed(3)??'0.00',
                          '',
                          mapState?.ascent?.toStringAsFixed(0)??'0',
                          mapState?.descent?.toStringAsFixed(0)??'0',
                        ],
                        [
                          'km',
                          '',
                          'meters',
                          'meters',
                        ],
                      ),
                      buildPage(
                        [
                          'Current Speed',
                          'Average Speed',
                          'Average Speed\nwhile Moving',
                          'Max Speed',
                        ],
                        [
                          mapState?.speed?.toStringAsFixed(1)??'NaN',
                          mapState?.averageSpeed?.toStringAsFixed(1)??'NaN',
                          mapState?.averageSpeedWhileMoving?.toStringAsFixed(1)??'NaN',
                          mapState?.maxSpeed?.toStringAsFixed(1)??'NaN',
                        ],
                        [
                          'km/hr',
                          'km/hr',
                          'km/hr',
                          'km/hr',
                        ],
                      ),
                      buildPage(
                        [
                          'Current Altitude',
                          'Average Altitude',
                          'Min Altitude',
                          'Max Altitude',
                        ],
                        [
                          mapState?.altitude?.toStringAsFixed(0)??'NaN',
                          mapState?.averageAltitude?.toStringAsFixed(0)??'NaN',
                          mapState?.minAltitude?.toStringAsFixed(0)??'NaN',
                          mapState?.maxAltitude?.toStringAsFixed(0)??'NaN',
                        ],
                        [
                          'meters',
                          'meters',
                          'meters',
                          'meters',
                        ],
                      ),
                      buildPage(
                        [
                          'Current Location',
                          'Accuracy',
                          'Waypoints',
                          'Heading',
                        ],
                        [
                          (mapState.latitude != null) ? mapState.latitude.toStringAsFixed(5)+',\n'+mapState.longitude.toStringAsFixed(5) : 'NaN',
                          '±'+(mapState?.accuracy?.toStringAsFixed(0)??'0'),
                          mapState?.wayPoints?.toStringAsFixed(0)??'0',
                          mapState?.headingAngle?.toStringAsFixed(0)??'NaN'
                        ],
                        [
                          'lat, lon',
                          'meters',
                          '',
                          '*',
                        ],
                      ),
                      buildPage(
                        [
                          'Recording Duration',
                          'Moving Duration',
                          'Moving Percentage',
                          'Pausing Duration',
                        ],
                        [
                          durationToString(mapState?.totalTime??Duration(seconds: 0)),
                          durationToString(mapState?.movingTime??Duration(seconds: 0)),
                          mapState?.percentageTimeMoving?.toStringAsFixed(0),
                          durationToString(mapState?.pauseTime??Duration(seconds: 0)),
                        ],
                        [
                          'hr:min:sec',
                          'hr:min:sec',
                          '%',
                          'hr:min:sec',
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String durationToString(Duration duration){
    return '${intToString(duration.inHours)
    }:${
        intToString(duration.inMinutes % 60)
    }:${
        intToString(duration.inSeconds % 60)
    }';
  }

  static String intToString(int num){
    return (num <= 9) ? '0' + num.toString() : num.toString();
  }

  static buildItem(String title, String value, String unit){
    return ListView(physics: NeverScrollableScrollPhysics(), children: <Widget>[
      Container(height: 150, child: Column(children: <Widget>[
        Text(title),
        Spacer(),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
        Text(unit),
        Spacer(flex: 2,),
      ],),),
    ],);
  }

  static const List<Widget> widgetsPlaceholder = [null, null, null, null];

  static buildPage(List<String> titles, List<String> values, List<String> units, {List<Widget> widgets = widgetsPlaceholder}){
    return Container(
      child: Column(
        children: <Widget>[
          Container(height: 10,),
          Expanded(
            child: Row(children: <Widget>[
              Expanded(
                child: (widgets[0] == null) ? buildItem(titles[0], values[0], units[0]) : widgets[0],
              ),
              Expanded(
                child: (widgets[1] == null) ? buildItem(titles[1], values[1], units[1]) : widgets[1],
              ),
            ],),
          ),
          Divider(color: Colors.grey,),
          Expanded(
            child: Row(children: <Widget>[
              Expanded(
                child: (widgets[2] == null) ? buildItem(titles[2], values[2], units[2]) : widgets[2],
              ),
              Expanded(
                child: (widgets[3] == null) ? buildItem(titles[3], values[3], units[3]) : widgets[3],
              ),
            ],),
          ),
          Container(height: 10,),
        ],
      ),
    );
  }
}

/*
class Compass extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    //platform.invokeMethod('sdf').then((value) => print(value));
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Image.asset('assets/compass.png'),
        StreamBuilder<double>(
          stream: FlutterCompass.events,
          builder: (BuildContext context, AsyncSnapshot<double> snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return CircularProgressIndicator();
            }
            if(snapshot.data == null){
              return Icon(Icons.error);
            }
            return Transform.rotate(angle: snapshot.data * (math.pi / 180) * -1, child: Image.asset('assets/placeholder.jpg'),);
          },
        ),
      ],
    );
  }
}

*/

