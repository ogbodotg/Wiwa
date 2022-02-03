import 'package:flutter/material.dart';
import 'package:wiwa_app/model/user.dart';
import 'package:wiwa_app/ui/page/settings/widgets/headerWidget.dart';
import 'package:wiwa_app/ui/page/settings/widgets/settingsAppbar.dart';
import 'package:wiwa_app/ui/page/settings/widgets/settingsRowWidget.dart';
import 'package:wiwa_app/state/authState.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthState>(context).userModel ?? UserModel();
    return Scaffold(
      backgroundColor: TwitterColor.white,
      appBar: SettingsAppBar(
        title: 'Notifications',
        subtitle: user.userName,
      ),
      body: ListView(
        children: <Widget>[
          HeaderWidget('Wiwa'),
          SettingRowWidget(
            "Quality filter",
            showCheckBox: true,
            subtitle:
                'Filter lower-quality from your notifications. This won\'t filter out notifications from people you follow or account you\'ve inteacted with recently.',
            // navigateTo: 'AccountSettingsPage',
          ),
          Divider(height: 0),
          // SettingRowWidget("Advanced filter"),
          // SettingRowWidget("Muted word"),
          // HeaderWidget(
          //   'Preferences',
          //   secondHeader: true,
          // ),
          // SettingRowWidget(
          //   "Unread notification count badge",
          //   showCheckBox: false,
          //   subtitle:
          //       'Display a badge with the number of notifications waiting for you inside the Fwitter app.',
          // ),
          // SettingRowWidget("Push notifications"),
          // SettingRowWidget("SMS notifications"),
          // SettingRowWidget(
          //   "Email notifications",
          //   subtitle: 'Control when how often Fwitter sends emails to you.',
          // ),
        ],
      ),
    );
  }
}
