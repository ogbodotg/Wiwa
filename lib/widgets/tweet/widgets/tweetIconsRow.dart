import 'package:flutter/material.dart';
import 'package:wiwa_app/helper/customRoute.dart';
import 'package:wiwa_app/helper/enum.dart';
import 'package:wiwa_app/helper/utility.dart';
import 'package:wiwa_app/model/feedModel.dart';
import 'package:wiwa_app/ui/page/common/usersListPage.dart';
import 'package:wiwa_app/state/authState.dart';
import 'package:wiwa_app/state/feedState.dart';
import 'package:wiwa_app/ui/theme/custom_icon_icons.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:wiwa_app/widgets/customWidgets.dart';
import 'package:wiwa_app/widgets/tweet/widgets/tweetBottomSheet.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class TweetIconsRow extends StatelessWidget {
  final FeedModel model;
  final Color iconColor;
  final Color iconEnableColor;
  final double size;
  final bool isTweetDetail;
  final TweetType type;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const TweetIconsRow(
      {Key key,
      this.model,
      this.iconColor,
      this.iconEnableColor,
      this.size,
      this.isTweetDetail = false,
      this.type,
      this.scaffoldKey})
      : super(key: key);

  Widget _likeCommentsIcons(BuildContext context, FeedModel model) {
    var authState = Provider.of<AuthState>(context, listen: false);

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(bottom: 0, top: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          _iconWidget(
            context,
            text: isTweetDetail ? '' : model.commentCount.toString(),
            icon: CustomIcon.comment_empty,
            iconColor: iconColor,
            size: size ?? 20,
            onPressed: () {
              var state = Provider.of<FeedState>(context, listen: false);
              state.setTweetToReply = model;
              Navigator.of(context).pushNamed('/ComposeTweetPage');
            },
          ),
          _iconWidget(context,
              text: isTweetDetail ? '' : model.retweetCount.toString(),
              icon: CustomIcon.retweet_1,
              iconColor: iconColor,
              size: size ?? 20, onPressed: () {
            TweetBottomSheet().openRetweetbottomSheet(context,
                type: type, model: model, scaffoldKey: scaffoldKey);
          }),
          _iconWidget(
            context,
            text: isTweetDetail ? '' : model.likeCount.toString(),
            icon: model.likeList.any((userId) => userId == authState.userId)
                ? CustomIcon.thumbs_up_alt
                : CustomIcon.thumbs_up_1,
            onPressed: () {
              addLikeToTweet(context);
            },
            iconColor:
                model.likeList.any((userId) => userId == authState.userId)
                    ? Colors.purple
                    : iconColor,
            size: size ?? 20,
          ),

          // Dislike Icon
          _iconWidget(
            context,
            text: isTweetDetail ? '' : model?.dislikeCount.toString() ?? 0,
            icon: model.dislikeList.any((userId) => userId == authState.userId)
                ? CustomIcon.thumbs_down_alt
                : CustomIcon.thumbs_down_1,
            onPressed: () {
              addDislikeToTweet(context);
            },
            iconColor:
                model.dislikeList.any((userId) => userId == authState.userId)
                    ? TwitterColor.ceriseRed
                    : iconColor,
            size: size ?? 20,
          ),
          // share icon disabled until wiwa web is launched
          _iconWidget(context, text: '', icon: null, sysIcon: Icons.share,
              onPressed: () {
            shareTweet(context);
          }, iconColor: iconColor, size: size ?? 20),
        ],
      ),
    );
  }

  Widget _iconWidget(BuildContext context,
      {String text,
      IconData icon,
      Function onPressed,
      IconData sysIcon,
      Color iconColor,
      double size = 20}) {
    return Expanded(
      child: Container(
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: () {
                if (onPressed != null) onPressed();
              },
              icon: sysIcon != null
                  ? Icon(sysIcon, color: iconColor, size: size)
                  : customIcon(
                      context,
                      size: size,
                      icon: icon,
                      istwitterIcon: true,
                      iconColor: iconColor,
                    ),
            ),
            customText(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: iconColor,
                fontSize: size - 5,
              ),
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 8),
        Row(
          children: <Widget>[
            SizedBox(width: 5),
            customText(Utility.getPostTime2(model.createdAt),
                style: TextStyles.textStyle14),
            SizedBox(width: 10),
            Platform.isIOS
                ? customText('Wiwa for iPhone',
                    style: TextStyle(color: Theme.of(context).primaryColor))
                : Platform.isAndroid
                    ? customText('Wiwa for Android',
                        style: TextStyle(color: Theme.of(context).primaryColor))
                    : customText('Wiwa for Web',
                        style: TextStyle(color: Theme.of(context).primaryColor))
          ],
        ),
        SizedBox(height: 5),
      ],
    );
  }

  Widget _likeCommentWidget(BuildContext context) {
    bool isLikeAvailable =
        model.likeCount != null ? model.likeCount > 0 : false;
    bool isDislikeAvailable =
        model.dislikeCount != null ? model.dislikeCount > 0 : false;
    bool isRetweetAvailable = model.retweetCount > 0;
    bool isLikeRetweetAvailable =
        isRetweetAvailable || isLikeAvailable || isDislikeAvailable;
    return Column(
      children: <Widget>[
        Divider(
          endIndent: 10,
          height: 0,
        ),
        AnimatedContainer(
          padding:
              EdgeInsets.symmetric(vertical: isLikeRetweetAvailable ? 12 : 0),
          duration: Duration(milliseconds: 500),
          child: !isLikeRetweetAvailable
              ? SizedBox.shrink()
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    !isRetweetAvailable
                        ? SizedBox.shrink()
                        : customText(model.retweetCount.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold)),
                    !isRetweetAvailable
                        ? SizedBox.shrink()
                        : SizedBox(width: 5),
                    AnimatedCrossFade(
                      firstChild: SizedBox.shrink(),
                      secondChild: model.retweetCount > 1
                          ? customText('Reposts',
                              style: TextStyles.subtitleStyle)
                          : customText('Repost',
                              style: TextStyles.subtitleStyle),
                      crossFadeState: !isRetweetAvailable
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: Duration(milliseconds: 800),
                    ),
                    !isRetweetAvailable
                        ? SizedBox.shrink()
                        : SizedBox(width: 20),
                    InkWell(
                      onTap: () {
                        onLikeTextPressed(context);
                      },
                      child: AnimatedCrossFade(
                        firstChild: SizedBox.shrink(),
                        secondChild: Row(
                          children: <Widget>[
                            customSwitcherWidget(
                              duraton: Duration(milliseconds: 300),
                              child: customText(model.likeCount.toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  key: ValueKey(model.likeCount)),
                            ),
                            SizedBox(width: 5),
                            model.likeCount > 1
                                ? customText('Likes',
                                    style: TextStyles.subtitleStyle)
                                : customText('Like',
                                    style: TextStyles.subtitleStyle)
                          ],
                        ),
                        crossFadeState: !isLikeAvailable
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: Duration(milliseconds: 300),
                      ),
                    ),
                    SizedBox(width: 20),
                    InkWell(
                      onTap: () {
                        onDislikeTextPressed(context);
                      },
                      child: AnimatedCrossFade(
                        firstChild: SizedBox.shrink(),
                        secondChild: Row(
                          children: <Widget>[
                            customSwitcherWidget(
                              duraton: Duration(milliseconds: 300),
                              child: customText(model.dislikeCount.toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  key: ValueKey(model.dislikeCount)),
                            ),
                            SizedBox(width: 5),
                            model.dislikeCount > 1
                                ? customText('Dislikes',
                                    style: TextStyles.subtitleStyle)
                                : customText('Dislike',
                                    style: TextStyles.subtitleStyle)
                          ],
                        ),
                        crossFadeState: !isDislikeAvailable
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: Duration(milliseconds: 300),
                      ),
                    )
                  ],
                ),
        ),
        !isLikeRetweetAvailable
            ? SizedBox.shrink()
            : Divider(
                endIndent: 10,
                height: 0,
              ),
      ],
    );
  }

  Widget customSwitcherWidget(
      {@required child, Duration duraton = const Duration(milliseconds: 500)}) {
    return AnimatedSwitcher(
      duration: duraton,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(child: child, scale: animation);
      },
      child: child,
    );
  }

  void addLikeToTweet(BuildContext context) {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    state.addLikeToTweet(model, authState.userId);
  }

  void addDislikeToTweet(BuildContext context) {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    state.addDislikeToTweet(model, authState.userId);
  }

  void onLikeTextPressed(BuildContext context) {
    Navigator.of(context).push(
      CustomRoute<bool>(
        builder: (BuildContext context) => UsersListPage(
          pageTitle: "Liked by",
          userIdsList: model.likeList.map((userId) => userId).toList(),
          emptyScreenText: "This post has no like yet",
          emptyScreenSubTileText:
              "Once a user likes this post, user list will be shown here",
        ),
      ),
    );
  }

  void onDislikeTextPressed(BuildContext context) {
    Navigator.of(context).push(
      CustomRoute<bool>(
        builder: (BuildContext context) => UsersListPage(
          pageTitle: "Disliked by",
          userIdsList: model.dislikeList.map((userId) => userId).toList(),
          emptyScreenText: "This post has no dislike yet",
          emptyScreenSubTileText:
              "Once a user dislikes this post, user list will be shown here",
        ),
      ),
    );
  }

  void shareTweet(BuildContext context) async {
    TweetBottomSheet().openShareTweetBottomSheet(context, model, type);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        isTweetDetail ? _timeWidget(context) : SizedBox(),
        isTweetDetail ? _likeCommentWidget(context) : SizedBox(),
        _likeCommentsIcons(context, model)
      ],
    ));
  }
}
