import 'package:wiwa_app/Music/FrontEnd/CustomWidgets/GradientContainers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info/package_info.dart';

class SettingPage extends StatefulWidget {
  final Function callback;
  SettingPage({this.callback});
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  double appVersion;
  Box settingsBox = Hive.box('settings');
  String downloadPath = Hive.box('settings')
      .get('downloadPath', defaultValue: '/storage/emulated/0/Music');
  List dirPaths = Hive.box('settings').get('searchPaths', defaultValue: []);
  String streamingQuality =
      Hive.box('settings').get('streamingQuality', defaultValue: '96 kbps');
  String downloadQuality =
      Hive.box('settings').get('downloadQuality', defaultValue: '320 kbps');
  bool stopForegroundService =
      Hive.box('settings').get('stopForegroundService', defaultValue: true);
  bool stopServiceOnPause =
      Hive.box('settings').get('stopServiceOnPause', defaultValue: true);
  String region = Hive.box('settings').get('region', defaultValue: 'India');
  String themeColor =
      Hive.box('settings').get('themeColor', defaultValue: 'Teal');
  int colorHue = Hive.box('settings').get('colorHue', defaultValue: 400);
  bool synced = false;
  List languages = [
    "Hindi",
    "English",
    "Punjabi",
    "Tamil",
    "Telugu",
    "Marathi",
    "Gujarati",
    "Bengali",
    "Kannada",
    "Bhojpuri",
    "Malayalam",
    "Urdu",
    "Haryanvi",
    "Rajasthani",
    "Odia",
    "Assamese"
  ];
  List preferredLanguage = Hive.box('settings')
      .get('preferredLanguage', defaultValue: ['Hindi'])?.toList();

  @override
  void initState() {
    main();
    super.initState();
  }

  void main() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    List temp = packageInfo.version.split('.');
    temp.removeLast();
    appVersion = double.parse(temp.join('.'));
    setState(() {});
  }

  updateUserDetails(String key, dynamic value) {
    final userID = Hive.box('settings').get('userID');
    final dbRef = FirebaseDatabase.instance.reference().child("Users");
    dbRef.child(userID).update({"$key": "$value"});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Music Settings', style: TextStyle(color: Colors.black)),
        // centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          // padding: EdgeInsets.only(left: 1.5, right: 1.5, top: 10),
          shrinkWrap: true,
          children: [
            Column(
              children: [
                ListTile(
                  title: Text('Streaming Quality'),
                  subtitle: Text('Higher quality consumes more data'),
                  onTap: () {},
                  trailing: DropdownButton(
                    value: streamingQuality ?? '96 kbps',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyText1.color,
                    ),
                    underline: SizedBox(),
                    onChanged: (String newValue) {
                      setState(() {
                        streamingQuality = newValue;
                        Hive.box('settings').put('streamingQuality', newValue);
                        updateUserDetails('streamingQuality', newValue);
                      });
                    },
                    items: <String>['96 kbps', '160 kbps', '320 kbps']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  dense: true,
                ),
                Column(children: [
                  SwitchListTile(
                      activeColor: Theme.of(context).accentColor,
                      title: Text('Show Last Session on Home Screen'),
                      subtitle: Text('Default: On'),
                      dense: true,
                      value: settingsBox.get('showRecent') ?? true,
                      onChanged: (val) {
                        settingsBox.put('showRecent', val);
                        updateUserDetails('showRecent', val);
                        setState(() {});
                        widget.callback();
                      }),
                  SwitchListTile(
                      activeColor: Theme.of(context).accentColor,
                      title: Text('Stop music on App Close'),
                      subtitle: Text(
                          "If turned off, music won't stop even after app closes. Until you press stop button\nDefault: On\n"),
                      isThreeLine: true,
                      dense: true,
                      value: stopForegroundService ?? true,
                      onChanged: (val) {
                        Hive.box('settings').put('stopForegroundService', val);
                        stopForegroundService = val;
                        updateUserDetails('stopForegroundService', val);
                        setState(() {});
                      }),
                  SwitchListTile(
                      activeColor: Theme.of(context).accentColor,
                      title: Text(
                          'Remove Music Service from foreground when paused'),
                      subtitle: Text(
                          "If turned on, you can slide notification when paused to stop music service. But music service can also be stopped by android to release memory."),
                      isThreeLine: true,
                      dense: true,
                      value: stopServiceOnPause ?? true,
                      onChanged: (val) {
                        Hive.box('settings').put('stopServiceOnPause', val);
                        stopServiceOnPause = val;
                        updateUserDetails('stopServiceOnPause', val);
                        setState(() {});
                      }),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
