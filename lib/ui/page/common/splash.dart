import 'dart:convert';
import 'dart:io';
import 'package:wiwa_app/widgets/newWidget/rippleButton.dart';
import 'package:wiwa_app/widgets/newWidget/title_text.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wiwa_app/helper/enum.dart';
import 'package:wiwa_app/helper/utility.dart';
import 'package:wiwa_app/ui/page/Auth/selectAuthMethod.dart';
import 'package:wiwa_app/ui/page/common/updateApp.dart';
import 'package:wiwa_app/ui/page/feed/feedPostDetail.dart';
import 'package:wiwa_app/ui/page/homePage.dart';
import 'package:wiwa_app/state/authState.dart';
import 'package:wiwa_app/state/feedState.dart';
import 'package:wiwa_app/ui/page/profile/profilePage.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:wiwa_app/widgets/customWidgets.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool internetConnected = false;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      timer();
    });
    // checkInternet();
    super.initState();
  }

  // CHECK INTERNET CONNECTIVITY
  // void checkInternet() async {
  //   bool result = await InternetConnectionChecker().hasConnection;
  //   if (result == true) {
  //     setState(() {
  //       internetConnected = true;
  //     });
  //     print('There\'s internet connectivity!');
  //   } else {
  //     internetConnected = false;
  //     print('No internet :( Reason:');
  //     // print(InternetConnectionChecker().lastTryResults);
  //   }
  // }

  /// Check if current app is updated app or not
  /// If app is not updated then redirect user to update app screen
  void timer() async {
    final isAppUpdated = await _checkAppVersion();
    if (isAppUpdated) {
      cprint("App is updated");
      Future.delayed(Duration(seconds: 1)).then((_) {
        var state = Provider.of<AuthState>(context, listen: false);
        // state.authStatus = AuthStatus.NOT_DETERMINED;
        state.getCurrentUser();
      });
    }
  }

  /// Return installed app version
  /// For testing purpose in debug mode update screen will not be open up
  /// If an old version of app is installed on user's device then
  /// User will not be able to see home screen
  /// User will redirected to update app screen.
  /// Once user update app with latest verson and back to app then user automatically redirected to welcome / Home page
  Future<bool> _checkAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final currentAppVersion = "${packageInfo.version}";
    final appVersion = await _getAppVersionFromFirebaseConfig();
    if (appVersion != currentAppVersion) {
      if (kDebugMode) {
        cprint("Latest version of app is not installed on your system");
        cprint(
            "In debug mode we are not restrict devlopers to redirect to update screen");
        cprint(
            "Redirect devs to update screen can put other devs in confusion");
        return true;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UpdateApp(),
        ),
      );
      return false;
    } else {
      return true;
    }
  }

  /// Returns app version from firebase config
  /// Fecth Latest app version from firebase Remote config
  /// To check current installed app version check [version] in pubspec.yaml
  /// you have to add latest app version in firebase remote config
  /// To fetch this key go to project setting in firebase
  /// Open `Remote Config` section in fireabse
  /// Add [appVersion]  as paramerter key and below json in Default value
  ///  ``` json
  ///  {
  ///    "key": "1.0.0"
  ///  } ```
  /// After adding app version key click on Publish Change button
  /// For package detail check:-  https://pub.dev/packages/firebase_remote_config#-readme-tab-
  Future<String> _getAppVersionFromFirebaseConfig() async {
    final RemoteConfig remoteConfig = await RemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    // await remoteConfig.activateFetched();
    var data = remoteConfig.getString('appVersion');
    if (data != null && data.isNotEmpty) {
      return jsonDecode(data)["key"];
    } else {
      cprint(
          "Please add your app's current version into Remote config in firebase",
          errorIn: "_getAppVersionFromFirebaseConfig");
      return null;
    }
  }

  Widget _body() {
    var height = 150.0;
    return Container(
      height: context.height,
      width: context.width,
      child: Container(
        height: height,
        width: height,
        alignment: Alignment.center,
        child: Container(
          padding: EdgeInsets.all(50),
          decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Platform.isIOS
                  ? CupertinoActivityIndicator(
                      radius: 35,
                    )
                  : CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
              Text(
                "Wiwa",
                style: TextStyle(
                    fontFamily: 'Signatra',
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),

              // Image.asset(
              //   'assets/images/icon-480.png',
              //   height: 30,
              //   width: 30,
              // )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    void _navigateTo(String path) {
      Navigator.pop(context);
      Navigator.of(context).pushNamed('/$path');
    }

    return Scaffold(
        backgroundColor: TwitterColor.dodgetBlue,
        body: state.authStatus == AuthStatus.NOT_DETERMINED
            ? _body()
            :
            // internetConnected == true
            //     ?
            state.authStatus == AuthStatus.NOT_LOGGED_IN
                ? WelcomePage()
                : HomePage()
        // : Dialog(
        //     child: Column(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         Icon(Icons.signal_wifi_connected_no_internet_4,
        //             size: 100, color: Colors.redAccent),
        //         Padding(
        //           padding: const EdgeInsets.all(20),
        //           child: Text(
        //               'You are not connected to the internet or your network is poor. Please, check your internet and try again.',
        //               maxLines: 3,
        //               style: TextStyle(
        //                   fontSize: 18, color: Colors.black87)),
        //         ),
        //         RippleButton(
        //           onPressed: () {
        //             Navigator.pushReplacement(
        //                 context,
        //                 MaterialPageRoute(
        //                     builder: (context) => SplashPage()));
        //             // Navigator.pop(context);
        //             // SplashPage();
        //           },
        //           borderRadius: BorderRadius.circular(10),
        //           child: Container(
        //             // width: 50,
        //             padding: EdgeInsets.symmetric(
        //                 horizontal: 20, vertical: 10),
        //             decoration: BoxDecoration(
        //               color: Colors.grey,
        //               borderRadius: BorderRadius.circular(20),
        //               boxShadow: <BoxShadow>[
        //                 BoxShadow(
        //                   color: Color(0xffeeeeee),
        //                   blurRadius: 15,
        //                   offset: Offset(5, 5),
        //                 ),
        //               ],
        //             ),
        //             child: Wrap(
        //               children: <Widget>[
        //                 TitleText(
        //                   '             Retry             ',
        //                   color: Colors.white,
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ),
        //         SizedBox(
        //           height: 30,
        //         )
        //       ],
        //     ),
        //   )

        );
  }
}
