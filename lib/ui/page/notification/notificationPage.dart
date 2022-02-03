import 'package:wiwa_app/helper/enum.dart';
import 'package:wiwa_app/ui/page/notification/widget/follow_notification_tile.dart';
import 'package:wiwa_app/ui/page/notification/widget/post_dislike_tile.dart';
import 'package:wiwa_app/ui/page/notification/widget/post_like_tile.dart';
import 'package:flutter/material.dart';
import 'package:wiwa_app/model/feedModel.dart';
import 'package:wiwa_app/model/notificationModel.dart';
import 'package:wiwa_app/model/user.dart';
import 'package:wiwa_app/state/authState.dart';
import 'package:wiwa_app/state/feedState.dart';
import 'package:wiwa_app/state/notificationState.dart';
import 'package:wiwa_app/ui/page/feed/feedPostDetail.dart';
import 'package:wiwa_app/ui/page/profile/profilePage.dart';
import 'package:wiwa_app/ui/page/profile/widgets/circular_image.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:wiwa_app/widgets/customAppBar.dart';
import 'package:wiwa_app/widgets/customWidgets.dart';
import 'package:wiwa_app/widgets/url_text/customUrlText.dart';
import 'package:wiwa_app/widgets/newWidget/emptyList.dart';
import 'package:wiwa_app/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  NotificationPage({Key key, this.scaffoldKey}) : super(key: key);

  /// scaffoldKey used to open sidebaar drawer
  final GlobalKey<ScaffoldState> scaffoldKey;

  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var state = Provider.of<NotificationState>(context, listen: false);
      var authstate = Provider.of<AuthState>(context, listen: false);
      state.getDataFromDatabase(authstate.userId);
    });
  }

  void onSettingIconPressed() {
    Navigator.pushNamed(context, '/NotificationPage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwitterColor.mystic,
      appBar: CustomAppBar(
        isBackButton: true,
        scaffoldKey: widget.scaffoldKey,
        title: customTitleText(
          'Notifications',
        ),
        // icon: AppIcon.settings,
        // onActionPressed: onSettingIconPressed,
      ),
      body: NotificationPageBody(),
    );
  }
}

class NotificationPageBody extends StatelessWidget {
  const NotificationPageBody({Key key}) : super(key: key);

  Widget _notificationRow(BuildContext context, NotificationModel model) {
    var state = Provider.of<NotificationState>(context);
    if (model.type == NotificationType.Follow.toString()) {
      return FollowNotificationTile(
        model: model,
      );
    }
    return FutureBuilder(
      future: state.getTweetDetail(model.tweetKey),
      builder: (BuildContext context, AsyncSnapshot<FeedModel> snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              Container(child: PostLikeTile(model: snapshot.data)),
              Container(child: PostDislikeTile(model: snapshot.data)),
            ],
          );
        } else if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.active) {
          return SizedBox(
            height: 4,
            child: LinearProgressIndicator(),
          );
        } else {
          /// remove notification from firebase db if tweet in not available or deleted.
          var authstate = Provider.of<AuthState>(context);
          state.removeNotification(authstate.userId, model.tweetKey);
          return SizedBox();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<NotificationState>(context);
    var list = state.notificationList;
    // if (state?.isbusy ?? true && (list == null || list.isEmpty)) {
    if (state.isbusy) {
      return SizedBox(
        height: 3,
        child: LinearProgressIndicator(),
      );
    } else if (list == null || list.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: EmptyList(
            'No Notification available yet',
            subTitle:
                'When new notification are found, they\'ll be listed here.',
          ),
        ),
      );
    }
    return ListView.builder(
      addAutomaticKeepAlives: true,
      itemBuilder: (context, index) => _notificationRow(context, list[index]),
      itemCount: list.length,
    );
  }
}
