import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class AddMarkerDialog extends StatefulWidget {
  @override
  _AddMarkerDialogState createState() => _AddMarkerDialogState();
}

class _AddMarkerDialogState extends State<AddMarkerDialog> {
  static const List<IconData> icons = [
    Icons.place,
    Icons.location_city,
    Icons.opacity,
    Icons.restaurant,
    Icons.local_parking,
    Icons.local_taxi,
    Icons.local_florist,
    Icons.hotel,
    Icons.pool,
    Icons.terrain,
    Icons.visibility,
    Icons.nature,
  ];
  static const List<String> tooltips = [
    'Place',
    'City',
    'Water',
    'Restaurant',
    'Parking',
    'Taxi',
    'Nature',
    'Sleeping',
    'Swimming',
    'Landscape',
    'Viewpoint',
    'Nature',
  ];
  int iconIndex = 0;
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(0),
      title: Text('Add Marker'),
      children: <Widget>[
        Container(
          width: 0,
          height: 100,
          padding: EdgeInsets.all(10),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: (){
              List<Widget> widgets = [];
              for (int i = 0; i < icons.length; i++){
                widgets.add(IconButton(
                  icon: Icon(icons[i]),
                  tooltip: tooltips[i],
                  color: (i == iconIndex) ? Colors.amber : Colors.grey,
                  onPressed: (){
                    setState(() {
                      iconIndex = i;
                    });
                  },
                ));
              }
              return widgets;
            }(),
          ),
        ),
        Container(
          padding: EdgeInsets.all(20),
          child: Theme(
            data: ThemeData(
              primaryColor: Colors.amber,
            ),
            child: TextField(
              controller: textEditingController,
              decoration: InputDecoration(
                hintText: 'Marker Text',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
        ),
        ButtonBar(
          children: <Widget>[
            FlatButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            RaisedButton(
              child: Text('Add'),
              onPressed: (){},
              color: Colors.amber,
            ),
          ],
        ),
      ],
    );
  }
}
