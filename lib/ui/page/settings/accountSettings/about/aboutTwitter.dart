import 'package:flutter/material.dart';
import 'package:wiwa_app/helper/utility.dart';
import 'package:wiwa_app/ui/page/settings/widgets/headerWidget.dart';
import 'package:wiwa_app/ui/page/settings/widgets/settingsRowWidget.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:wiwa_app/widgets/customAppBar.dart';
import 'package:wiwa_app/widgets/customWidgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wiwa_app/ui/page/settings/accountSettings/privacyAndSafety/Privacy.dart';
import 'package:wiwa_app/ui/page/settings/accountSettings/privacyAndSafety/Terms.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _url = 'https://icons8.com';
    void _launchURL() async => await canLaunch(_url)
        ? await launch(_url)
        : throw 'Could not launch $_url';
    return Scaffold(
      backgroundColor: TwitterColor.white,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(
          'About Wiwa',
        ),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          // HeaderWidget(
          //   'Help',
          //   secondHeader: true,
          // ),
          // SettingRowWidget(
          //   "Help Centre",
          //   vPadding: 0,
          //   showDivider: false,
          //   onPressed: () {
          //     Utility.launchURL(
          //         "https://github.com/TheAlphamerc/flutter_twitter_clone/issues");
          //   },
          // ),
          HeaderWidget('Legal'),
          Divider(height: 0),
          ListTile(
            title: Text(
              'Terms',
              // style: TextStyle(
              //     color: TwitterColor.paleSky, fontWeight: FontWeight.w400),
              style: TextStyle(fontSize: 15),
            ),
            onTap: () {
              Navigator.pushNamed(context, WiwaTerms.id);
            },
          ),
          Divider(height: 0),
          ListTile(
            title: Text(
              'Privacy Policies',
              // style: TextStyle(
              //     color: TwitterColor.paleSky, fontWeight: FontWeight.w400),
              style: TextStyle(fontSize: 15),
            ),
            onTap: () {
              Navigator.pushNamed(context, WiwaPrivacy.id);
            },
          ),
          Divider(height: 0),
          // SettingRowWidget(
          //   "Terms of Service",
          //   showDivider: true,
          // ),
          // SettingRowWidget(
          //   "Privacy policy",
          //   showDivider: true,
          // ),
          // SettingRowWidget(
          //   "Cookie use",
          //   showDivider: true,
          // ),
          // SettingRowWidget(
          //   "Legal notices",
          //   showDivider: true,
          //   // onPressed: () async {
          //   //   showLicensePage(
          //   //     context: context,
          //   //     applicationName: 'Wiwa',
          //   //     applicationVersion: '1.0.0',
          //   //     useRootNavigator: true,
          //   //   );
          //   // },
          // ),
          SizedBox(height: 5),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Wiwa',
                      style: TextStyle(
                          fontFamily: 'Signatra',
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor),
                    ),
                    SizedBox(width: 6),
                    Text('...for The People',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54)),
                  ],
                ),

                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Icons by"),
                      TextButton(onPressed: _launchURL, child: Text('Icons8')),
                    ],
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(10.0),
                //   child: Text(
                //     'Credits to: Ankit, Ryan Heise, Sonu, JamDev and other amazing software engineers whose work helped in the creation of Wiwa. Thanks to you, the wheels sometimes didn\'t have to be reinvented.',
                //     maxLines: 6,
                //   ),
                // )
              ],
            ),
          )
          // HeaderWidget('Developer'),
          // SettingRowWidget("Github", showDivider: true, onPressed: () {
          //   Utility.launchURL("https://github.com/TheAlphamerc");
          // }),
          // SettingRowWidget("LinkidIn", showDivider: true, onPressed: () {
          //   Utility.launchURL("https://www.linkedin.com/in/thealphamerc/");
          // }),
          // SettingRowWidget("Twitter", showDivider: true, onPressed: () {
          //   Utility.launchURL("https://twitter.com/TheAlphaMerc");
          // }),
          // SettingRowWidget("Blog", showDivider: true, onPressed: () {
          //   Utility.launchURL("https://dev.to/thealphamerc");
          // }),
        ],
      ),
    );
  }
}
