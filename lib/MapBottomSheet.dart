// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:ihikepakistan/GpxProvider.dart';
// import 'package:ihikepakistan/MapState.dart';
//
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:share/share.dart';
// import 'ListDialog.dart';
// import 'MapBottomBody.dart';
// import 'package:provider/provider.dart';
// import 'package:mapbox_gl/mapbox_gl.dart' as mapbox;
//
// class MapBottomSheet extends StatefulWidget {
//   MapBottomSheet();
//
//   @override
//   BottomSheetState createState() => BottomSheetState();
// }
//
// class BottomSheetState extends State<MapBottomSheet> {
//   double height = 100;
//   double screenHeight;
//
//   BottomSheetState();
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 200),
//       height: height,
//       curve: Curves.ease,
//       color: Color.lerp(Theme.of(context).primaryColor, Colors.amber.shade100, (){
//         if(height > 200) return 1.0;
//         else if(height < 120) return 0.0;
//         else return (height-120) / 80;
//       }()),
//       child: GestureDetector(
//         onVerticalDragStart: (DragStartDetails details){
//           if(screenHeight == null){
//             screenHeight = details.globalPosition.dy - details.localPosition.dy + 100;
//           }
//         },
//         onVerticalDragUpdate: (DragUpdateDetails details){
//           if(height >= screenHeight) {
//             setState(() {
//               height = screenHeight;
//             });
//             return;
//           }
//           setState(() {
//             height -= details.delta.dy;
//             height = (height < 0) ? 0 : height;
//           });
//         },
//         onVerticalDragEnd: (DragEndDetails details){
//           height -= details.primaryVelocity / 10;
//           if(height >= screenHeight) {
//             setState(() {height = screenHeight;});
//           }
//           if(height < 75) setState(() {height = 50;});
//           else if(height < 187) setState(() {height = 100;});
//           else setState(() {height = 300;});
//           //setHeightGlobal(height);
//         },
//         child: Consumer<MapState>(
//           builder: (BuildContext context, MapState mapState, Widget widget){
//             return Stack(
//               alignment: Alignment.bottomCenter,
//               children: <Widget>[
//                 Opacity(
//                     opacity: (){
//                       if(height < 120) return 0.0;
//                       else if(height > 200) return 1.0;
//                       else return (height - 120) / 80;
//                     }(),
//                     child: Container(
//                       child: MapBottomBody(bottomSheetHeight: height,),
//                     )
//                 ),
//                 /*(height != 300 && height != 50) ? Opacity(
//                   opacity: (){
//                     if(height < 50) return 0.0;
//                     else if(height > 200) return 0.0;
//                     else if(height < 100) return (height - 50) / 50;
//                     else return 1 - (height - 100) / 100;
//                   }(),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: <Widget>[
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: <Widget>[
//                           InkWell(
//                             child: Container(
//                               width: 24,
//                             ),
//                           ),
//                           RaisedButton(
//                             color: Colors.red.shade700,
//                             elevation: 5,
//                             textColor: Colors.white,
//                             child: Text('Finish'),
//                             disabledColor: Colors.grey,
//                             disabledElevation: 0,
//                             onPressed: ((mapState.recordingState == RecordingState.recording || mapState.recordingState == RecordingState.paused) && height != 50 && height != 300) ? (){
//                               setState(() {
//                                 mapState.stopRecording();
//                               });
//                             } : null,
//                           ),
//                           Expanded(child: Center(child: Text({
//                             RecordingState.begin : 'Click Start',
//                             RecordingState.recording : (mapState.hasLocation) ? (mapState.onTrack ? 'Running' : 'Off Track!') : 'No Gps!',
//                             RecordingState.paused : 'Paused',
//                             RecordingState.finished : 'Finished',
//                           }[mapState.recordingState], style: TextStyle(fontSize: 16, color: ((!mapState.hasLocation || !mapState.onTrack) && mapState.recordingState == RecordingState.recording) ? Colors.red : Colors.white,), textAlign: TextAlign.center,),),),
//                           RaisedButton(
//                             textColor: Colors.white,
//                             color: {
//                               RecordingState.begin : Color(0xff00cc00),
//                               RecordingState.recording : Colors.amber,
//                               RecordingState.paused : Color(0xff00cc00),
//                               RecordingState.finished : Color(0xff00cc00),
//                             }[mapState.recordingState],
//                             elevation: 5,
//                             child: Text('Start'),
//                             onPressed: (mapState.recordingState != RecordingState.finished && height != 50 && height != 300) ? (){
//                               setState(() {
//                                 mapState.startPause();
//                               });
//                             } : null,
//                           ),
//                           InkWell(
//                             onTap: (){},
//                             child: Container(
//                               width: 24,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ) : Container(),*/
//                 Opacity(
//                   opacity: (){
//                     if(height > 200) return 0.0;
//                     if(height > 100) return 1 - (height - 100) / 100;
//                     return 1.0;
//                   }(),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: <Widget>[
//                       IconButton(icon: Icon(Icons.layers, color: Colors.white,), onPressed: height <= 100 ? () async {
//                         List<String> mapStyles = ['Normal', 'Satellite', 'Hybrid', 'Terrain', 'Light', 'Dark'];
//                         List<String> mapStyleUrls = [
//                           mapbox.MapboxStyles.MAPBOX_STREETS,
//                           mapbox.MapboxStyles.SATELLITE,
//                           mapbox.MapboxStyles.SATELLITE_STREETS,
//                           mapbox.MapboxStyles.OUTDOORS,
//                           mapbox.MapboxStyles.LIGHT,
//                           mapbox.MapboxStyles.DARK,
//                         ];
//                         int newIndex = await ListDialog(title: 'Map Type', context: context, items: mapStyles, currentValue: mapState.mapStyleIndex).show();
//                         mapState.setMapType(mapStyleUrls[newIndex], newIndex);
//                       } : null, tooltip: 'Set Map Type', highlightColor: Colors.transparent, splashColor: Colors.transparent,),
//                       IconButton(
//                         icon: Icon({
//                           MapCenterState.none: Icons.gps_not_fixed,
//                           MapCenterState.compass: Icons.explore,
//                           MapCenterState.gps: Icons.navigation,
//                           MapCenterState.centered: Icons.gps_fixed,
//                         }[mapState.mapCenterState], color: Colors.white,),
//                         onPressed: height <= 100 ? (){
//                           setState(() {
//                             mapState.toggleIsCentered(context);
//                           });
//                         } : null,
//                         tooltip: 'Center on Location',
//                         highlightColor: Colors.transparent, splashColor: Colors.transparent,
//                       ),
//                       Spacer(),
//                       IconButton(
//                         icon: Icon(mapState.showsNotifications ? Icons.notifications_active : Icons.notifications_none, color: Colors.white,),
//                         onPressed: height <= 100 ? (){
//                           setState(() {
//                             mapState.toggleNotifications();
//                           });
//                         } : null,
//                         tooltip: mapState.showsNotifications ? 'turn Notification Off' : 'turn Notifications On',
//                         highlightColor: Colors.transparent,
//                         splashColor: Colors.red,
//                       ),
//                       PopupMenuButton(itemBuilder: (context) => [
//                         PopupMenuItem(child: Text('Add to Ihike'), value: 'add_to_ihike',),
//                         PopupMenuItem(child: Text('Export to Gpx'), value: 'get_gpx',),
//                         //PopupMenuItem(child: Text('Save'), value: 'save',),
//                       ], child: Icon(Icons.more_vert, color: Colors.white,), onSelected: (String value) async {
//                         switch(value){
//                           case 'add_to_ihike':
//                             TextEditingController controller = TextEditingController();
//                             String track = mapState.myTrack.join(', ');
//                             showDialog(context: context, child: SimpleDialog(
//                               contentPadding: EdgeInsets.all(20),
//                               title: Text('Add to Ihike'),
//                               children: [
//                                 TextField(controller: controller, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: 'Email'),),
//                                 ButtonBar(children: [
//                                   FlatButton(
//                                       onPressed: (){
//                                         Navigator.pop(context);
//                                       },
//                                       child: Text('Cancel')
//                                   ),
//                                   RaisedButton(onPressed: (){
//                                     Navigator.pop(context);
//                                     http.get('https://script.google.com/macros/s/AKfycbwZObO3dRciDXBpNfC5p6NNexMIEVHQ4vJb4cL__YUN-N-QW1o/exec?track=$track\n${controller.text}').then((value) => {
//                                       Scaffold.of(context).showSnackBar(SnackBar(content: Text('Your track has been sent for review.\nThank you!'), duration: Duration(seconds: 3), backgroundColor: Colors.amber, behavior: SnackBarBehavior.floating,))
//                                     });
//                                   }, child: Text('Submit for review'), color: Colors.amber,),
//                                 ],)
//                               ],
//                             ));
//                             break;
//                           case 'get_gpx':
//                             TextEditingController controller = TextEditingController();
//                             showDialog(context: context, child: SimpleDialog(
//                               contentPadding: EdgeInsets.all(20),
//                               title: Text('Export Gpx'),
//                               children: [
//                                 TextField(controller: controller, keyboardType: TextInputType.text, decoration: InputDecoration(labelText: 'Name'),),
//                                 ButtonBar(children: [
//                                   FlatButton(
//                                       onPressed: (){
//                                         Navigator.pop(context);
//                                       },
//                                       child: Text('Cancel')
//                                   ),
//                                   RaisedButton(onPressed: () async {
//                                     Directory appDocDir = await getApplicationDocumentsDirectory();
//                                     File file = File(appDocDir.path + '/${controller.text}.gpx');
//                                     RandomAccessFile accessFile = await file.open(mode: FileMode.write);
//                                     await accessFile.writeString(GpxProvider.getGpx(mapState.myTrack, controller.text));
//                                     await accessFile.close();
//                                     Share.shareFiles([file.path]);
//                                     Navigator.pop(context);
//                                   }, child: Text('Export'), color: Colors.amber,),
//                                 ],),
//                               ],
//                             ));
//                             break;
//                           case 'save':
//                             TextEditingController controller = TextEditingController();
//                             showDialog(context: context, child: SimpleDialog(
//                               contentPadding: EdgeInsets.all(20),
//                               title: Text('Save'),
//                               children: [
//                                 TextField(controller: controller, keyboardType: TextInputType.text, decoration: InputDecoration(labelText: 'Name'),),
//                                 ButtonBar(children: [
//                                   FlatButton(
//                                       onPressed: (){
//                                         Navigator.pop(context);
//                                       },
//                                       child: Text('Cancel')
//                                   ),
//                                   RaisedButton(onPressed: () async {
//                                     Directory appDocDir = await getApplicationDocumentsDirectory();
//                                     File file = File(appDocDir.path + '/${controller.text}.gpx');
//                                     RandomAccessFile accessFile = await file.open(mode: FileMode.write);
//                                     await accessFile.writeString(GpxProvider.getGpx(mapState.myTrack, controller.text));
//                                     await accessFile.close();
//                                     Navigator.pop(context);
//                                     Scaffold.of(context).showSnackBar(SnackBar(content: Text('Your track has been saved. In future updates of the app, you will be able to view tracks.\nBe a little patient...'), duration: Duration(seconds: 5), backgroundColor: Colors.amber, behavior: SnackBarBehavior.floating,));
//                                   }, child: Text('Save'), color: Colors.amber,),
//                                 ],),
//                               ],
//                             ));
//                             break;
//                         }
//                       },)
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
//
// /*
//
//                             Directory appDocDir = await getApplicationDocumentsDirectory();
//                             File file = File(appDocDir.path + '/temp_gpx.gpx');
//                             RandomAccessFile accessFile = await file.open(mode: FileMode.write);
//                             accessFile.writeString('string');
//                             Share.shareFiles([file.path], );
//
//
//  */