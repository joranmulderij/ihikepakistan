/*import 'package:flutter/material.dart';
import 'package:ihikepakistan/ListDialog.dart';

class SwitchTile extends StatefulWidget{
  final String title;
  final String subtitle;
  final String setting;
  final bool def;
  final IconData icon;

  SwitchTile({this.subtitle, this.title, this.setting, this.def, this.icon});

  SwitchState createState() => SwitchState(title: title, subtitle: subtitle, setting: setting, def: def, icon: icon);
}
class SwitchState extends State<SwitchTile>{
  final String title;
  final String subtitle;
  final String setting;
  final bool def;
  final IconData icon;

  SwitchState({this.title, this.subtitle, this.setting, this.def, this.icon});

  void change(bool newValue){
    prefs.setBool(setting, newValue);
    setState(() {});
  }

  Widget build(BuildContext context){
    return SwitchListTile(
      secondary: Icon(icon),
      onChanged: change,
      value: prefs.getBool(setting) ?? def,
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}


class CheckTile extends StatefulWidget{
  final String title;
  final String subtitle;
  final String setting;
  final bool def;
  final IconData icon;

  CheckTile({this.subtitle, this.title, this.setting, this.def, this.icon});

  CheckState createState() => CheckState(title: title, subtitle: subtitle, setting: setting, def: def, icon: icon);
}
class CheckState extends State<CheckTile>{
  final String title;
  final String subtitle;
  final String setting;
  final bool def;
  final IconData icon;

  CheckState({this.title, this.subtitle, this.setting, this.def, this.icon});

  void change(bool newValue){
    prefs.setBool(setting, newValue);
    setState(() {});
  }

  Widget build(BuildContext context){
    return CheckboxListTile(
      //controlAffinity: ListTileControlAffinity.leading,
      secondary: Icon(icon),
      onChanged: change,
      value: prefs.getBool(setting) ?? def,
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}


class MultiSettingsTile extends StatefulWidget{
  final String title;
  final String setting;
  final int def;
  final List<String> items;
  final IconData icon;

  MultiSettingsTile({this.title, this.setting, this.def, this.items, this.icon});

  MultiState createState() => MultiState(title: title, setting: setting, def: def, items: items, icon: icon);
}
class MultiState extends State<MultiSettingsTile>{
  final String title;
  final String setting;
  final List<String> items;
  final int def;
  final IconData icon;

  MultiState({this.title, this.setting, this.items, this.def, this.icon});

  void change(bool newValue){
    prefs.setBool(setting, newValue);
    setState(() {});
  }

  Widget build(BuildContext context){
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(items[prefs.getInt(setting) ?? def]),
      onTap: () async {
        int value = await ListDialog(
          title: title,
          currentValue: prefs.getInt(setting) ?? def,
          items: items,
          context: context,
        ).show();
        setState(() {
          prefs.setInt(setting, value);
        });
      },
    );
  }
}


class TextSettingsTile extends StatefulWidget {
  final String title;
  final String setting;
  final String def;
  final IconData icon;
  final String regex;
  final String error;
  TextSettingsTile({this.title, this.def, this.icon, this.setting, this.regex, this.error});

  @override
  TextSettingsTileState createState() => TextSettingsTileState(icon: icon, title: title, def: def, setting: setting, regex: regex, error: error);
}

class TextSettingsTileState extends State<TextSettingsTile> {
  final String title;
  final String setting;
  final String def;
  final IconData icon;
  final String regex;
  final String error;
  bool valid = true;
  TextEditingController textEditingController;
  TextSettingsTileState({this.title, this.def, this.icon, this.setting, this.regex, this.error});

  @override
  Widget build(BuildContext context) {
    textEditingController = TextEditingController();
    textEditingController.text = prefs.getString(setting) ?? def;
    return ListTile(
      title: Text(title),
      subtitle: Text(prefs.getString(setting) ?? def),
      leading: Icon(icon),
      onTap: (){
        showDialog(
            context: context,
            child: SimpleDialog(
              title: Text(title),
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20),
                  child: SettingsTextInput(
                    icon: icon,
                    regex: regex,
                    setting: setting,
                    def: def,
                    error: error,
                  ),
                ),
                ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      child: Text('Cancel'),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: Text('Ok'),
                      onPressed: (){
                        if(valid){
                          prefs.setString(setting, textEditingController.text);
                          setState(() {});
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
        );
      },
    );
  }
}


class SettingsTextInput extends StatefulWidget {
  final String regex;
  final IconData icon;
  final String setting;
  final String def;
  final String error;
  SettingsTextInput({this.icon, this.regex, this.setting, this.def, this.error});

  @override
  SettingsTextInputState createState() => SettingsTextInputState(icon: icon, regex: regex, setting: setting, def: def, error: error);
}

class SettingsTextInputState extends State<SettingsTextInput> {
  TextEditingController textEditingController;
  bool isValid = true;
  final String regex;
  final IconData icon;
  final String setting;
  final String def;
  final String error;
  SettingsTextInputState({this.regex, this.icon, this.setting, this.def, this.error});

  @override
  Widget build(BuildContext context) {
    textEditingController = TextEditingController();
    textEditingController.text = prefs.getString(setting) ?? def;
    return TextField(
      autofocus: true,
      keyboardType: TextInputType.number,
      onChanged: (String value){
        if(regex != null){
          setState(() {
            isValid = RegExp(regex).hasMatch(value);
          });
        }
      },
      decoration: InputDecoration(
        icon: Icon(icon),
        errorText: isValid ? null : error,
      ),
      controller: textEditingController,
    );
  }
}
*/
