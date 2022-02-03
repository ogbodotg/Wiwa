import 'dart:async';
import 'package:wiwa_app/Music/FrontEnd/Screens/Home/home.dart';
import 'package:wiwa_app/Music/Services/songShare.dart';
import 'package:wiwa_app/Music/Services/songShareRoute.dart';
import 'package:wiwa_app/ahia/Pages/HomeScreen.dart';
import 'package:wiwa_app/ahia/Services/ProductRoute.dart';
import 'package:wiwa_app/helper/utility.dart';
import 'package:wiwa_app/ui/page/feed/feedPostDetail.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wiwa_app/helper/enum.dart';
import 'package:wiwa_app/model/push_notification_model.dart';
import 'package:wiwa_app/resource/push_notification_service.dart';
import 'package:wiwa_app/ui/page/feed/feedPage.dart';
import 'package:wiwa_app/ui/page/message/chatListPage.dart';
import 'package:wiwa_app/state/appState.dart';
import 'package:wiwa_app/state/authState.dart';
import 'package:wiwa_app/state/chats/chatState.dart';
import 'package:wiwa_app/state/feedState.dart';
import 'package:wiwa_app/state/notificationState.dart';
import 'package:wiwa_app/state/searchState.dart';
import 'package:wiwa_app/ui/page/profile/profilePage.dart';
import 'package:wiwa_app/widgets/bottomMenuBar/bottomMenuBar.dart';
import 'package:provider/provider.dart';
import 'common/locator.dart';
import 'common/sidebar.dart';
import 'notification/notificationPage.dart';
import 'search/SearchPage.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  int pageIndex = 0;
  // ignore: cancel_subscriptions
  StreamSubscription<PushNotificationModel> pushNotificationSubscription;
  @override
  void initState() {
    initDynamicLinks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var state = Provider.of<AppState>(context, listen: false);
      state.setpageIndex = 0;
      initTweets();
      initProfile();
      initSearch();
      initNotificaiton();
      initChat();
    });

    super.initState();
  }

  @override
  void dispose() {
    // getIt<PushNotificationService>().pushBehaviorSubject.close();
    super.dispose();
  }

  void initTweets() {
    var state = Provider.of<FeedState>(context, listen: false);
    state.databaseInit();
    state.getDataFromDatabase();
  }

  void initProfile() {
    var state = Provider.of<AuthState>(context, listen: false);
    state.databaseInit();
  }

  void initSearch() {
    var searchState = Provider.of<SearchState>(context, listen: false);
    searchState.getDataFromDatabase();
  }

  void initNotificaiton() {
    var state = Provider.of<NotificationState>(context, listen: false);
    var authstate = Provider.of<AuthState>(context, listen: false);
    state.databaseInit(authstate.userId);

    /// configure push notifications
    state.initfirebaseService();

    /// Suscribe the push notifications
    /// Whenever devices recieve push notifcation, `listenPushNotification` callback will trigger.
    pushNotificationSubscription = getIt<PushNotificationService>()
        .pushNotificationResponseStream
        .listen(listenPushNotification);
  }

  /// Listen for every push notifications when app is in background
  /// Check for push notifications when app is launched by tapping on push notifications from system tray.
  /// If notification type is `NotificationType.Message` then chat screen will open
  /// If notification type is `NotificationType.Mention` then user profile will open who taged/mentioned you in a tweet
  void listenPushNotification(PushNotificationModel model) {
    final authstate = Provider.of<AuthState>(context, listen: false);
    var state = Provider.of<NotificationState>(context, listen: false);

    /// Check if user recieve chat notification
    /// Redirect to chat screen
    /// `model.data.senderId` is a user id who sends you a message
    /// `model.data.receiverId` is a your user id.
    // if (model.data.type == NotificationType.Message.toString() &&
    //     model.data.receiverId == authstate.user.uid) {
    if (model.type == NotificationType.Message.toString() &&
        model.receiverId == authstate.user.uid) {
      /// Get sender profile detail from firebase
      // state.getuserDetail(model.data.senderId).then((user) {
      state.getuserDetail(model.senderId).then((user) {
        final chatState = Provider.of<ChatState>(context, listen: false);
        chatState.setChatUser = user;
        Navigator.pushNamed(context, '/ChatScreenPage');
      });
    }

    /// Checks for user tag tweet notification
    /// Redirect user to tweet detail if
    /// Tweet contains
    /// If you are mentioned in tweet then it redirect to user profile who mentioed you in a tweet
    /// You can check that tweet on his profile timeline
    /// `model.data.senderId` is user id who tagged you in a tweet
    // else if (model.data.type == NotificationType.Mention.toString() &&
    //     model.data.receiverId == authstate.user.uid) {
    //   Navigator.push(
    //       context, ProfilePage.getRoute(profileId: model.data.senderId));
    else if (model.type == NotificationType.Mention.toString() &&
        model.receiverId == authstate.user.uid) {
      var feedstate = Provider.of<FeedState>(context, listen: false);
      feedstate.getpostDetailFromDatabase(model.tweetId);
      Navigator.push(context, FeedPostDetail.getRoute(model.tweetId));
    }
  }

  void initChat() {
    final chatState = Provider.of<ChatState>(context, listen: false);
    final state = Provider.of<AuthState>(context, listen: false);
    chatState.databaseInit(state.userId, state.userId);

    /// It will update fcm token in database
    /// fcm token is required to send firebase notification
    state.updateFCMToken();

    /// It get fcm server key
    /// Server key is required to configure firebase notification
    /// Without fcm server notification can not be sent
    chatState.getFCMServerKey();
  }

  /// Initilise the firebase dynamic link sdk
  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      if (deepLink != null) {
        redirectFromDeepLink(deepLink);
      }
    }, onError: (OnLinkErrorException e) async {
      cprint(e.message, errorIn: "onLinkError");
    });

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      redirectFromDeepLink(deepLink);
    }
  }

  /// Redirect user to specfic screen when app is launched by tapping on deep link.
  void redirectFromDeepLink(Uri deepLink) {
    cprint("Found Url from share: ${deepLink.path}");
    var type = deepLink.path.split("/")[1];
    var id = deepLink.path.split("/")[2];
    if (type == "profilePage") {
      Navigator.push(context, ProfilePage.getRoute(profileId: id));
    } else if (type == "posts") {
      var feedstate = Provider.of<FeedState>(context, listen: false);
      feedstate.getpostDetailFromDatabase(id);
      Navigator.push(context, FeedPostDetail.getRoute(id));
    } else if (type == "songs") {
      //song
      Navigator.push(context, SongShareRoute.getRoute(id));
      // Navigator.push(context, HandleRoute().handleRoute(id));
      // HandleRoute().handleRoute(id);
    } else {
      Navigator.push(context, ProductRoute.getRoute(id));
    }
  }

  Widget _body() {
    return SafeArea(
      child: Container(
        child: _getPage(Provider.of<AppState>(context).pageIndex),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return FeedPage(
          scaffoldKey: _scaffoldKey,
          refreshIndicatorKey: refreshIndicatorKey,
        );
        break;
      case 1:
        return SearchPage(scaffoldKey: _scaffoldKey);
        break;
      case 2:
        return MusicFront(scaffoldKey: _scaffoldKey);
        // return NotificationPage(scaffoldKey: _scaffoldKey);
        break;
      case 3:
        return HomeScreen(scaffoldKey: _scaffoldKey);
        // return ChatListPage(scaffoldKey: _scaffoldKey);
        break;
      default:
        return FeedPage(scaffoldKey: _scaffoldKey);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: BottomMenubar(),
      drawer: SidebarMenu(),
      body: _body(),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<StreamSubscription<PushNotificationModel>>(
            'pushNotificationSubscription', pushNotificationSubscription));
  }
}
