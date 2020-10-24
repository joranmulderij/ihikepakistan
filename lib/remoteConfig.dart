import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
class MyRemoteConfig{
  static RemoteConfig remoteConfig;
  static Future<RemoteConfig> init() async {
    if(kIsWeb) return remoteConfig;
    remoteConfig = await RemoteConfig.instance;
    //await remoteConfig.setDefaults(remoteConfigConstValues);

    // TODO: remoteConfig time interval
    await remoteConfig.fetch(expiration: const Duration(minutes: 2));
    await remoteConfig.activateFetched();
    return remoteConfig;
  }
  static String getRemoteConfigValue(String valueName){
    if(remoteConfig == null){
      return remoteConfigConstValues[valueName];
    }
    print(remoteConfig.getString('categories'));
    return remoteConfig.getString(valueName);
  }
}

final remoteConfigConstValues = <String, String>{
  'categories' : '["Islamabad","KPK","Swat"]',
  'category_breakpoints' : '[0,12,14]',
  'hikes' : '[]',
  'homescreen_text' : ''
};