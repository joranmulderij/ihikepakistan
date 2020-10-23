import 'package:flutter/material.dart';
import 'package:ihikepakistan/MapState.dart';

import 'AddMarkerDialog.dart';
import 'ListDialog.dart';
import 'MapBottomBody.dart';
import 'package:provider/provider.dart';

class MapBottomSheet extends StatefulWidget {
  MapBottomSheet();

  @override
  BottomSheetState createState() => BottomSheetState();
}

class BottomSheetState extends State<MapBottomSheet> {
  double height = 100;
  double screenHeight;

  BottomSheetState();

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: height,
      curve: Curves.ease,
      color: Color.lerp(Theme.of(context).primaryColor, Colors.amber.shade100, (){
        if(height > 200) return 1.0;
        else if(height < 120) return 0.0;
        else return (height-120) / 80;
      }()),
      child: GestureDetector(
        onVerticalDragStart: (DragStartDetails details){
          if(screenHeight == null){
            screenHeight = details.globalPosition.dy - details.localPosition.dy + 100;
          }
        },
        onVerticalDragUpdate: (DragUpdateDetails details){
          if(height >= screenHeight) {
            setState(() {
              height = screenHeight;
            });
            return;
          }
          setState(() {
            height -= details.delta.dy;
            height = (height < 0) ? 0 : height;
          });
        },
        onVerticalDragEnd: (DragEndDetails details){
          height -= details.primaryVelocity / 10;
          if(height >= screenHeight) {
            setState(() {height = screenHeight;});
          }
          if(height < 75) setState(() {height = 50;});
          else if(height < 187) setState(() {height = 100;});
          else setState(() {height = 300;});
          //setHeightGlobal(height);
        },
        child: Consumer<MapState>(
          builder: (BuildContext context, MapState mapState, Widget widget){
            return Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Opacity(
                    opacity: (){
                      if(height < 120) return 0.0;
                      else if(height > 200) return 1.0;
                      else return (height - 120) / 80;
                    }(),
                    child: Container(
                      child: MapBottomBody(bottomSheetHeight: height,),
                    )
                ),
                (height != 300 && height != 50) ? Opacity(
                  opacity: (){
                    if(height < 50) return 0.0;
                    else if(height > 200) return 0.0;
                    else if(height < 100) return (height - 50) / 50;
                    else return 1 - (height - 100) / 100;
                  }(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          InkWell(
                            child: Container(
                              width: 24,
                            ),
                          ),
                          RaisedButton(
                            color: Colors.red.shade700,
                            elevation: 5,
                            textColor: Colors.white,
                            child: Text('Finish'),
                            disabledColor: Colors.grey,
                            disabledElevation: 0,
                            onPressed: (mapState.recordingState != RecordingState.begin && height != 50 && height != 300) ? (){
                              setState(() {
                                mapState.stopRecording();
                              });
                            } : null,
                          ),
                          Expanded(child: Center(child: Text({
                            RecordingState.begin : 'Click Start',
                            RecordingState.recording : (mapState.hasLocation) ? 'Started' : 'No Gps!',
                            RecordingState.paused : 'Paused',
                            RecordingState.finished : 'Finished',
                          }[mapState.recordingState], style: TextStyle(fontSize: 16, color: (!mapState.hasLocation && mapState.recordingState == RecordingState.recording) ? Colors.red : Colors.white,), textAlign: TextAlign.center,),),),
                          RaisedButton(
                            textColor: Colors.white,
                            color: {
                              RecordingState.begin : Color(0xff00cc00),
                              RecordingState.recording : Colors.amber,
                              RecordingState.paused : Color(0xff00cc00),
                              RecordingState.finished : Color(0xff00cc00),
                            }[mapState.recordingState],
                            elevation: 5,
                            child: Text({
                              RecordingState.begin : 'Start',
                              RecordingState.recording : 'Pause',
                              RecordingState.paused : 'Start',
                              RecordingState.finished : 'Start',
                            }[mapState.recordingState]),
                            onPressed: (height != 50 && height != 300) ? (){
                              setState(() {
                                mapState.startPause();
                              });
                            } : null,
                          ),
                          InkWell(
                            onTap: (){},
                            child: Container(
                              width: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ) : Container(),
                Opacity(
                  opacity: (){
                    if(height > 200) return 0.0;
                    if(height > 100) return 1 - (height - 100) / 100;
                    return 1.0;
                  }(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      IconButton(icon: Icon(Icons.layers, color: Colors.white,), onPressed: height <= 100 ? () async {
                        int newValue = await ListDialog(title: 'Map Type', context: context, items: ['Normal', 'Sattelite', 'Terrain', 'Streets', 'Offline Map', 'Blank'], currentValue: mapState.mapType).show();
                        mapState.setMapType(newValue);
                      } : null, tooltip: 'Set Map Type', highlightColor: Colors.transparent, splashColor: Colors.transparent,),
                      IconButton(
                        icon: Icon(mapState.isCentered ? Icons.gps_fixed : Icons.gps_not_fixed, color: Colors.white,),
                        onPressed: height <= 100 ? (){
                          setState(() {
                            mapState.toggleIsCentered();
                          });
                        } : null,
                        tooltip: 'Center on Location',
                        highlightColor: Colors.transparent, splashColor: Colors.transparent,
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(mapState.showsNotifications ? Icons.notifications_active : Icons.notifications_none, color: Colors.white,),
                        onPressed: height <= 100 ? (){
                          setState(() {
                            mapState.toggleNotifications();
                          });
                        } : null, tooltip: mapState.showsNotifications ? 'turn Notification Off' : 'turn Notifications On', highlightColor: Colors.transparent, splashColor: Colors.red,),
                      IconButton(icon: Icon(Icons.add_location, color: Colors.white,), onPressed: height <= 100 ? (){
                        showDialog(context: context, child: AddMarkerDialog());
                      } : null, tooltip: 'Add Marker', highlightColor: Colors.transparent, splashColor: Colors.transparent,),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}