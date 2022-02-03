import 'package:flutter/material.dart';
import 'package:wiwa_app/model/user.dart';
import 'package:wiwa_app/ui/page/settings/widgets/headerWidget.dart';
import 'package:wiwa_app/state/authState.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:wiwa_app/widgets/customAppBar.dart';
import 'package:wiwa_app/widgets/customWidgets.dart';
import 'package:provider/provider.dart';
import 'widgets/settingsRowWidget.dart';

class SettingsAndPrivacyPage extends StatelessWidget {
  const SettingsAndPrivacyPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthState>(context).userModel ?? UserModel();
    return Scaffold(
      backgroundColor: TwitterColor.white,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(
          'Settings and privacy',
        ),
      ),
      body: ListView(
        children: <Widget>[
          HeaderWidget(user.userName),
          SettingRowWidget(
            "Account",
            navigateTo: 'AccountSettingsPage',
          ),
          Divider(height: 0),
          SettingRowWidget("Direct Messages",
              navigateTo: 'PrivacyAndSaftyPage'),
          Divider(height: 0),
          ListTile(
            title: Text(
              'Music Settings',
              // style: TextStyle(
              //     color: TwitterColor.paleSky, fontWeight: FontWeight.w400),
              style: TextStyle(fontSize: 15),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/setting');
            },
          ),
          Divider(height: 0),
          // SettingRowWidget("Notification", navigateTo: 'NotificationPage'),
          // SettingRowWidget("Content prefrences",
          //     navigateTo: 'ContentPrefrencePage'),
          // HeaderWidget(
          //   'General',
          //   secondHeader: true,
          // ),
          // SettingRowWidget("Display and Sound",
          //     navigateTo: 'DisplayAndSoundPage'),
          // SettingRowWidget("Data usage", navigateTo: 'DataUsagePage'),
          // SettingRowWidget("Accessibility", navigateTo: 'AccessibilityPage'),
          // SettingRowWidget("Proxy", navigateTo: "ProxyPage"),
          SettingRowWidget(
            "About Wiwa",
            navigateTo: "AboutPage",
          ),
          // SettingRowWidget(
          //   null,
          //   showDivider: false,
          //   vPadding: 10,
          //   subtitle:
          //       'These settings affect all of your Fwitter accounts on this devce.',
          // )
        ],
      ),
    );
  }
}
