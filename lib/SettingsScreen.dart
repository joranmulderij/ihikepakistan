/*import 'package:flutter/material.dart';
import 'SettingsTiles.dart';

class SettingsScreen extends StatefulWidget {
  @override
  SettingsScreenState createState() => SettingsScreenState();
}


class SettingsScreenState extends State<SettingsScreen> {
  bool mapSettings = false;
  bool drawSettings = false;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        //key: Key('SettingsList'),
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.map),
            title: Text('Map Settings'),
            onTap: (){
              setState(() {
                mapSettings = !mapSettings;
              });
            },
          ),
          AnimatedContainer(
            height: (mapSettings) ? 360 : 0,
            duration: Duration(milliseconds: 500),
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                MultiSettingsTile(
                  icon: Icons.layers,
                  title: 'Default Map Type',
                  def: 0,
                  items: ['Normal', 'Sattelite', 'Terrain', 'Dark Map', 'Normal + Elevation Lines', 'Sattelite + Elevation Lines', 'Offline Map', 'Blank'],
                  setting: 'maptype',
                ),
                MultiSettingsTile(
                  title: 'Line Thickness',
                  icon: Icons.line_weight,
                  items: ['1', '2', '3', '5', '7', '10'],
                  def: 0,
                  setting: 'linethickness',
                ),
                MultiSettingsTile(
                  title: 'Line Color',
                  setting: 'linecolor',
                  icon: Icons.color_lens,
                  def: 0,
                  items: ['Default', 'Black', 'White', 'Red', 'Orange', 'Amber', 'Yellow', 'Light Green', 'Green', 'Light Blue', 'Dark Blue', 'Purple', 'Pink'],
                ),
                CheckTile(
                  title: 'Show Markers',
                  def: true,
                  icon: Icons.place,
                  setting: 'showmarkers',
                  subtitle: 'Your own Markers will still be visible',
                ),
                SwitchTile(
                  icon: Icons.brightness_medium,
                  title: 'Dark Map',
                  subtitle: 'Only effects Map screen',
                  setting: 'darkmode',
                  def: false,
                ),
              ],
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Drawing'),
            onTap: (){
              setState(() {
                drawSettings = !drawSettings;
              });
            },
          ),
          AnimatedContainer(
            height: (drawSettings) ? 360 : 0,
            duration: Duration(milliseconds: 500),
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                MultiSettingsTile(
                  icon: Icons.layers,
                  title: 'Default Map Type',
                  def: 0,
                  items: ['Normal', 'Sattelite', 'Terrain', 'Dark Map', 'Normal + Elevation Lines', 'Sattelite + Elevation Lines', 'Offline Map', 'Blank'],
                  setting: 'maptype',
                ),
                MultiSettingsTile(
                  title: 'Line Thickness',
                  icon: Icons.line_weight,
                  items: ['1', '2', '3', '5', '7', '10'],
                  def: 0,
                  setting: 'linethickness',
                ),
                MultiSettingsTile(
                  title: 'Line Color',
                  setting: 'linecolor',
                  icon: Icons.color_lens,
                  def: 0,
                  items: ['Default', 'Black', 'White', 'Red', 'Orange', 'Amber', 'Yellow', 'Light Green', 'Green', 'Light Blue', 'Dark Blue', 'Purple', 'Pink'],
                ),
                CheckTile(
                  title: 'Show Markers',
                  def: true,
                  icon: Icons.place,
                  setting: 'showmarkers',
                  subtitle: 'Your own Markers will still be visible',
                ),
                SwitchTile(
                  icon: Icons.brightness_medium,
                  title: 'Dark Map',
                  subtitle: 'Only effects Map screen',
                  setting: 'darkmode',
                  def: false,
                ),
              ],
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.more_horiz),
            title: Text('More Info'),
            onTap: () {
              showAbout(context);
            },
          ),
        ],
      ),
    );
  }

  void showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationVersion: '1.0.1',
      applicationIcon: Image.asset('assets/logo_small.png'),
    );
  }
}

/*class SettingsTile extends StatefulWidget {
  final String type;
  final String title;
  final String subtitle;
  final List<String> options;
  final int valueInt;
  final bool valueBool;

  SettingsTile(
      {this.options,
      this.title,
      this.type,
      this.valueBool,
      this.valueInt,
      this.subtitle});

  SettingsTileState createState() => new SettingsTileState(
      type: type,
      options: options,
      title: title,
      valueBool: valueBool,
      valueInt: valueInt,
      subtitle: subtitle);
}

class SettingsTileState extends State<SettingsTile> {
  final String type;
  final String title;
  final String subtitle;
  final List<String> options;
  int valueInt;
  bool valueBool;

  SettingsTileState(
      {this.type,
      this.valueInt,
      this.valueBool,
      this.title,
      this.options,
      this.subtitle});

  Widget build(BuildContext context) {
    if (type == 'switch') {
      return SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: valueBool,
        onChanged: (bool value) {
          setState(() {
            valueBool = value;
          });
        },
      );
    } else if (type == 'check') {
      return CheckboxListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: valueBool,
        onChanged: (bool value) {
          setState(() {
            valueBool = value;
          });
        },
      );
    } else if (type == 'multiple') {
      return ListTile(
        title: Text(title),
        subtitle: Text(options[valueInt]),
        onTap: () async {
          valueInt = await ListDialog(context: context, title: title, items: options, currentValue: valueInt).show() ?? valueInt;
          setState(() {});
        },
      );
    } else {
      return null;
    }
    //return
  }
}
*/
*/
