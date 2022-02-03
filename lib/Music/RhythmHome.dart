// import 'dart:async';

// import 'package:WiwaApp/Music/FrontEnd/Screens/Home/home.dart';
// import 'package:WiwaApp/ahia/Pages/FavouriteScreen.dart';
// import 'package:WiwaApp/ahia/Pages/HomeScreen.dart';
// import 'package:WiwaApp/ahia/Pages/OrdersScreen.dart';
// import 'package:WiwaApp/ahia/Pages/ProfileScreen.dart';
// import 'package:WiwaApp/ahia/Widgets/Cart/CartNotification.dart';
// import 'package:WiwaApp/helper/enum.dart';
// import 'package:WiwaApp/model/push_notification_model.dart';
// import 'package:WiwaApp/resource/push_notification_service.dart';
// import 'package:WiwaApp/state/appState.dart';
// import 'package:WiwaApp/state/authState.dart';
// import 'package:WiwaApp/state/chats/chatState.dart';
// import 'package:WiwaApp/state/feedState.dart';
// import 'package:WiwaApp/state/notificationState.dart';
// import 'package:WiwaApp/state/searchState.dart';
// import 'package:WiwaApp/ui/page/common/locator.dart';
// import 'package:WiwaApp/ui/page/feed/feedPage.dart';
// import 'package:WiwaApp/ui/page/message/chatListPage.dart';
// import 'package:WiwaApp/ui/page/notification/notificationPage.dart';
// import 'package:WiwaApp/ui/page/profile/profilePage.dart';
// import 'package:WiwaApp/ui/page/search/SearchPage.dart';
// import 'package:WiwaApp/widgets/bottomMenuBar/bottomMenuBar.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
// import 'package:provider/provider.dart';

// class RhythmMainScreen extends StatefulWidget {
//   static const String id = 'rhythm-main-screen';

//   @override
//   _RhythmMainScreenState createState() => _RhythmMainScreenState();
// }

// class _RhythmMainScreenState extends State<RhythmMainScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
//   final refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
//   int pageIndex = 0;
//   // ignore: cancel_subscriptions
//   StreamSubscription<PushNotificationModel> pushNotificationSubscription;
//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       var state = Provider.of<AppState>(context, listen: false);
//       state.setpageIndex = 0;
//       initTweets();
//       initProfile();
//       initSearch();
//       initNotificaiton();
//       initChat();
//     });

//     super.initState();
//   }

//   void initTweets() {
//     var state = Provider.of<FeedState>(context, listen: false);
//     state.databaseInit();
//     state.getDataFromDatabase();
//   }

//   void initProfile() {
//     var state = Provider.of<AuthState>(context, listen: false);
//     state.databaseInit();
//   }

//   void initSearch() {
//     var searchState = Provider.of<SearchState>(context, listen: false);
//     searchState.getDataFromDatabase();
//   }

//   void initNotificaiton() {
//     var state = Provider.of<NotificationState>(context, listen: false);
//     var authstate = Provider.of<AuthState>(context, listen: false);
//     state.databaseInit(authstate.userId);

//     /// configure push notifications
//     state.initfirebaseService();

//     /// Suscribe the push notifications
//     /// Whenever devices recieve push notifcation, `listenPushNotification` callback will trigger.
//     pushNotificationSubscription = getIt<PushNotificationService>()
//         .pushNotificationResponseStream
//         .listen(listenPushNotification);
//   }

//   /// Listen for every push notifications when app is in background
//   /// Check for push notifications when app is launched by tapping on push notifications from system tray.
//   /// If notification type is `NotificationType.Message` then chat screen will open
//   /// If notification type is `NotificationType.Mention` then user profile will open who taged/mentioned you in a tweet
//   void listenPushNotification(PushNotificationModel model) {
//     final authstate = Provider.of<AuthState>(context, listen: false);
//     var state = Provider.of<NotificationState>(context, listen: false);

//     /// Check if user recieve chat notification
//     /// Redirect to chat screen
//     /// `model.data.senderId` is a user id who sends you a message
//     /// `model.data.receiverId` is a your user id.
//     if (model.data.type == NotificationType.Message.toString() &&
//         model.data.receiverId == authstate.user.uid) {
//       /// Get sender profile detail from firebase
//       state.getuserDetail(model.data.senderId).then((user) {
//         final chatState = Provider.of<ChatState>(context, listen: false);
//         chatState.setChatUser = user;
//         Navigator.pushNamed(context, '/ChatScreenPage');
//       });
//     }

//     /// Checks for user tag tweet notification
//     /// If you are mentioned in tweet then it redirect to user profile who mentioed you in a tweet
//     /// You can check that tweet on his profile timeline
//     /// `model.data.senderId` is user id who tagged you in a tweet
//     else if (model.data.type == NotificationType.Mention.toString() &&
//         model.data.receiverId == authstate.user.uid) {
//       Navigator.push(
//           context, ProfilePage.getRoute(profileId: model.data.senderId));
//     }
//   }

//   void initChat() {
//     final chatState = Provider.of<ChatState>(context, listen: false);
//     final state = Provider.of<AuthState>(context, listen: false);
//     chatState.databaseInit(state.userId, state.userId);

//     /// It will update fcm token in database
//     /// fcm token is required to send firebase notification
//     state.updateFCMToken();

//     /// It get fcm server key
//     /// Server key is required to configure firebase notification
//     /// Without fcm server notification can not be sent
//     chatState.getFCMServerKey();
//   }

//   Widget _body() {
//     return SafeArea(
//       child: Container(
//         child: _getPage(Provider.of<AppState>(context).pageIndex),
//       ),
//     );
//   }

//   Widget _getPage(int index) {
//     switch (index) {
//       case 0:
//         return MusicFront();
//         // FeedPage(
//         //   scaffoldKey: _scaffoldKey,
//         //   refreshIndicatorKey: refreshIndicatorKey,
//         // );
//         break;
//       case 1:
//         return SearchPage(scaffoldKey: _scaffoldKey);
//         break;
//       case 2:
//         return NotificationPage(scaffoldKey: _scaffoldKey);
//         break;
//       case 3:
//         return ChatListPage(scaffoldKey: _scaffoldKey);
//         break;
//       default:
//         return MusicFront();
//         // return FeedPage(scaffoldKey: _scaffoldKey);
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       bottomNavigationBar: BottomMenubar(),
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(bottom: 50),
//         child: CartNotification(),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       body: _body(),
//     );
//   }
// }
