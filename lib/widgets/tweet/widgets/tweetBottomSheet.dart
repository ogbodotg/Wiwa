import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:wiwa_app/helper/constant.dart';
import 'package:wiwa_app/helper/enum.dart';
import 'package:wiwa_app/helper/utility.dart';
import 'package:wiwa_app/model/feedModel.dart';
import 'package:wiwa_app/model/user.dart';
import 'package:wiwa_app/state/authState.dart';
import 'package:wiwa_app/state/feedState.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:wiwa_app/widgets/customWidgets.dart';
import 'package:wiwa_app/widgets/share_widget.dart';
import 'package:wiwa_app/widgets/tweet/tweet.dart';
import 'package:provider/provider.dart';

class TweetBottomSheet {
  Widget tweetOptionIcon(BuildContext context,
      {FeedModel model, TweetType type, GlobalKey<ScaffoldState> scaffoldKey}) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: customIcon(context,
          icon: AppIcon.arrowDown,
          istwitterIcon: true,
          iconColor: AppColor.lightGrey),
    ).ripple(
      () {
        _openbottomSheet(context,
            type: type, model: model, scaffoldKey: scaffoldKey);
      },
      borderRadius: BorderRadius.circular(20),
    );
  }

  void _openbottomSheet(BuildContext context,
      {TweetType type,
      FeedModel model,
      GlobalKey<ScaffoldState> scaffoldKey}) async {
    var authState = Provider.of<AuthState>(context, listen: false);
    bool isMyTweet = authState.userId == model.userId;
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
            padding: EdgeInsets.only(top: 5, bottom: 0),
            height: context.height *
                (type == TweetType.Tweet
                    ? (isMyTweet ? .15 : .15)
                    : (isMyTweet ? .15 : .15)
                // This option would be used when other post options like, "pin to profile, mute, block, etc are ready"
                // ? (isMyTweet ? .25 : .44)
                // : (isMyTweet ? .38 : .52)
                ),
            width: context.width,
            decoration: BoxDecoration(
              color: Theme.of(context).bottomSheetTheme.backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: type == TweetType.Tweet
                ? _tweetOptions(context,
                    scaffoldKey: scaffoldKey,
                    isMyTweet: isMyTweet,
                    model: model,
                    type: type)
                : _tweetDetailOptions(context,
                    scaffoldKey: scaffoldKey,
                    isMyTweet: isMyTweet,
                    model: model,
                    type: type));
      },
    );
  }

  Widget _tweetDetailOptions(BuildContext context,
      {bool isMyTweet,
      FeedModel model,
      TweetType type,
      GlobalKey<ScaffoldState> scaffoldKey}) {
    return Column(
      children: <Widget>[
        Container(
          width: context.width * .1,
          height: 5,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
        // copy link to post bottomsheet option disbled until wiwa for web is launched
        _widgetBottomSheetRow(context, AppIcon.link,
            text: 'Copy link to post', isEnable: true, onPressed: () async {
          Navigator.pop(context);
          var uri = await Utility.createLinkToShare(
            context,
            "posts/${model.key}",
            socialMetaTagParameters: SocialMetaTagParameters(
                description: model.description ??
                    "${model.user.displayName} published a post on Wiwa.",
                title: "Post on Wiwa",
                imageUrl: Uri.parse(
                    model.user.profilePic ?? Constants.dummyProfilePic
                    // "https://play-lh.googleusercontent.com/e66XMuvW5hZ7HnFf8R_lcA3TFgkxm0SuyaMsBs3KENijNHZlogUAjxeu9COqsejV5w=s180-rw"
                    )),
          );

          Utility.copyToClipBoard(
              scaffoldKey: scaffoldKey,
              text: uri.toString(),
              message: "Post link copied to clipboard");
        }),
        isMyTweet
            ? _widgetBottomSheetRow(
                context,
                AppIcon.delete,
                text: 'Delete Post',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("Delete"),
                      content: Text('Do you want to delete this Post?'),
                      actions: [
                        // ignore: deprecated_member_use
                        FlatButton(
                          textColor: Colors.black,
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                        // ignore: deprecated_member_use
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              TwitterColor.dodgetBlue,
                            ),
                            foregroundColor: MaterialStateProperty.all(
                              TwitterColor.white,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteTweet(
                              context,
                              type,
                              model.key,
                              parentkey: model.parentkey,
                            );
                          },
                          child: Text('Confirm'),
                        ),
                      ],
                    ),
                  );
                },
                isEnable: true,
              )
            : Container(),
        // disabled bottom sheet options "mute, unfollow, block etc"
        // isMyTweet
        //     ? _widgetBottomSheetRow(
        //         context,
        //         AppIcon.unFollow,
        //         text: 'Pin to profile',
        //       )
        //     : _widgetBottomSheetRow(
        //         context,
        //         AppIcon.unFollow,
        //         text: 'Unfollow ${model.user.userName}',
        //       ),
        // isMyTweet
        //     ? Container()
        //     : _widgetBottomSheetRow(
        //         context,
        //         AppIcon.mute,
        //         text: 'Mute ${model.user.userName}',
        //       ),
        // _widgetBottomSheetRow(s
        //   context,
        //   AppIcon.mute,
        //   text: 'Mute this convertion',
        // ),
        // _widgetBottomSheetRow(
        //   context,
        //   AppIcon.viewHidden,
        //   text: 'View hidden replies',
        // ),
        // isMyTweet
        //     ? Container()
        //     : _widgetBottomSheetRow(
        //         context,
        //         AppIcon.block,
        //         text: 'Block ${model.user.userName}',
        //       ),
        isMyTweet
            ? Container()
            : _widgetBottomSheetRow(context, AppIcon.report,
                text: 'Report this post', isEnable: true, onPressed: () async {
                var state = Provider.of<FeedState>(context, listen: false);

                state.reportPost(model);
                Navigator.pop(context);
              }),
      ],
    );
  }

  Widget _tweetOptions(BuildContext context,
      {bool isMyTweet,
      FeedModel model,
      TweetType type,
      GlobalKey<ScaffoldState> scaffoldKey}) {
    return Column(
      children: <Widget>[
        Container(
          width: context.width * .1,
          height: 5,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
        _widgetBottomSheetRow(context, AppIcon.link,
            text: 'Copy link to post', isEnable: true, onPressed: () async {
          var uri = await Utility.createLinkToShare(
            context,
            // "${model.key}",
            "posts/${model.key}",
            socialMetaTagParameters: SocialMetaTagParameters(
                description: model.description ??
                    "${model.user.displayName} published a post on Wiwa.",
                title: "Post on Wiwa",
                imageUrl: Uri.parse(
                    model.user.profilePic ?? Constants.dummyProfilePic
                    // "https://play-lh.googleusercontent.com/e66XMuvW5hZ7HnFf8R_lcA3TFgkxm0SuyaMsBs3KENijNHZlogUAjxeu9COqsejV5w=s180-rw"
                    )),
          );
          Navigator.pop(context);
          Utility.copyToClipBoard(
              scaffoldKey: scaffoldKey,
              text: uri.toString(),
              message: "Post link copied to clipboard");
        }),
        isMyTweet
            ? _widgetBottomSheetRow(
                context,
                AppIcon.delete,
                text: 'Delete Post',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("Delete"),
                      content: Text('Do you want to delete this Post?'),
                      actions: [
                        // ignore: deprecated_member_use
                        FlatButton(
                          textColor: Colors.black,
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                        // ignore: deprecated_member_use
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              TwitterColor.dodgetBlue,
                            ),
                            foregroundColor: MaterialStateProperty.all(
                              TwitterColor.white,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteTweet(
                              context,
                              type,
                              model.key,
                              parentkey: model.parentkey,
                            );
                          },
                          child: Text('Confirm'),
                        ),
                      ],
                    ),
                  );
                },
                isEnable: true,
              )
            : Container(),
        // isMyTweet
        //     ? _widgetBottomSheetRow(
        //         context,
        //         AppIcon.thumbpinFill,
        //         text: 'Pin to profile',
        //       )
        //     : _widgetBottomSheetRow(
        //         context,
        //         AppIcon.sadFace,
        //         text: 'Not interested in this',
        //       ),
        // isMyTweet
        //     ? Container()
        //     : _widgetBottomSheetRow(
        //         context,
        //         AppIcon.unFollow,
        //         text: 'Unfollow ${model.user.userName}',
        //       ),
        // isMyTweet
        //     ? Container()
        //     : _widgetBottomSheetRow(
        //         context,
        //         AppIcon.mute,
        //         text: 'Mute ${model.user.userName}',
        //       ),
        // isMyTweet
        //     ? Container()
        //     : _widgetBottomSheetRow(
        //         context,
        //         AppIcon.block,
        //         text: 'Block ${model.user.userName}',
        //       ),
        isMyTweet
            ? Container()
            : _widgetBottomSheetRow(context, AppIcon.report,
                text: 'Report this post', isEnable: true, onPressed: () async {
                var state = Provider.of<FeedState>(context, listen: false);

                state.reportPost(model);

                Navigator.pop(context);
              }),
      ],
    );
  }

  Widget _widgetBottomSheetRow(BuildContext context, IconData icon,
      {String text, Function onPressed, bool isEnable = false}) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            customIcon(
              context,
              icon: icon,
              istwitterIcon: true,
              size: 25,
              paddingIcon: 8,
              iconColor:
                  onPressed != null ? AppColor.darkGrey : AppColor.lightGrey,
            ),
            SizedBox(
              width: 15,
            ),
            customText(
              text,
              context: context,
              style: TextStyle(
                color: isEnable ? AppColor.secondary : AppColor.lightGrey,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        ),
      ).ripple(() {
        if (onPressed != null)
          onPressed();
        else {
          Navigator.pop(context);
        }
      }),
    );
  }

  void _deleteTweet(BuildContext context, TweetType type, String tweetId,
      {String parentkey}) {
    var state = Provider.of<FeedState>(context, listen: false);
    state.deleteTweet(tweetId, type, parentkey: parentkey);
    // CLose bottom sheet
    Navigator.of(context).pop();
    if (type == TweetType.Detail) {
      // Close Tweet detail page
      Navigator.of(context).pop();
      // Remove last tweet from tweet detail stack page
      state.removeLastTweetDetail(tweetId);
    }
  }

  void openRetweetbottomSheet(BuildContext context,
      {TweetType type,
      FeedModel model,
      GlobalKey<ScaffoldState> scaffoldKey}) async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
            padding: EdgeInsets.only(top: 5, bottom: 0),
            height: 130,
            width: context.width,
            decoration: BoxDecoration(
              color: Theme.of(context).bottomSheetTheme.backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: _retweet(context, model, type));
      },
    );
  }

  Widget _retweet(BuildContext context, FeedModel model, TweetType type) {
    return Column(
      children: <Widget>[
        Container(
          width: context.width * .1,
          height: 5,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
        _widgetBottomSheetRow(
          context,
          AppIcon.retweet,
          isEnable: true,
          text: 'Repost',
          onPressed: () async {
            var state = Provider.of<FeedState>(context, listen: false);
            var authState = Provider.of<AuthState>(context, listen: false);
            var myUser = authState.userModel;
            myUser = UserModel(
                displayName: myUser.displayName ?? myUser.email.split('@')[0],
                profilePic: myUser.profilePic,
                userId: myUser.userId,
                isVerified: authState.userModel.isVerified,
                userName: authState.userModel.userName);
            // Prepare current Tweet model to reply
            FeedModel post = new FeedModel(
                childRetwetkey: model.getTweetKeyToRetweet,
                createdAt: DateTime.now().toUtc().toString(),
                user: myUser,
                userId: myUser.userId);
            state.createTweet(post);

            Navigator.pop(context);
            var sharedPost = await state.fetchTweet(post.childRetwetkey);
            if (sharedPost.retweetCount == null) {
              sharedPost.retweetCount = 0;
            }
            sharedPost.retweetCount += 1;
            state.updateTweet(sharedPost);
          },
        ),
        _widgetBottomSheetRow(
          context,
          AppIcon.edit,
          text: 'Repost with comment',
          isEnable: true,
          onPressed: () {
            var state = Provider.of<FeedState>(context, listen: false);
            // Prepare current Tweet model to reply
            state.setTweetToReply = model;
            Navigator.pop(context);

            /// `/ComposeTweetPage/retweet` route is used to identify that tweet is going to be retweet.
            /// To simple reply on any `Tweet` use `ComposeTweetPage` route.
            Navigator.of(context).pushNamed('/ComposeTweetPage/retweet');
          },
        )
      ],
    );
  }

  void openShareTweetBottomSheet(
      BuildContext context, FeedModel model, TweetType type) async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
            padding: EdgeInsets.only(top: 5, bottom: 0),
            height: 120,
            width: context.width,
            decoration: BoxDecoration(
              color: Theme.of(context).bottomSheetTheme.backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: _shareTweet(context, model, type));
      },
    );
  }

  Widget _shareTweet(BuildContext context, FeedModel model, TweetType type) {
    var socialMetaTagParameters = SocialMetaTagParameters(
        description: model.description ?? "",
        title: "${model.user.displayName} Published a Post on Wiwa.",
        imageUrl:
            Uri.parse(model.user?.profilePic ?? Constants.dummyProfilePic));
    return Column(
      children: <Widget>[
        Container(
          width: context.width * .1,
          height: 5,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
        SizedBox(height: 8),
        _widgetBottomSheetRow(
          context,
          AppIcon.bookmark,
          isEnable: true,
          text: 'Bookmark Post',
          onPressed: () async {
            var state = Provider.of<FeedState>(context, listen: false);
            await state.addBookmark(model.key);
            Navigator.pop(context);
            ScaffoldMessenger.maybeOf(context).showSnackBar(
              SnackBar(content: Text("Post Bookmarked")),
            );
          },
        ),
        SizedBox(height: 8),
        _widgetBottomSheetRow(
          context,
          AppIcon.link,
          isEnable: true,
          text: 'Share Post',
          onPressed: () async {
            Navigator.pop(context);
            var url = Utility.createLinkToShare(
              context,
              // "${model.key}",
              "posts/${model.key}",
              // "${model.key}",
              socialMetaTagParameters: socialMetaTagParameters,
            );
            var uri = await url;
            Utility.share(uri.toString(), subject: "Post on Wiwa");
          },
        ),
        // SizedBox(height: 8),
        // _widgetBottomSheetRow(
        //   context,
        //   AppIcon.image,
        //   text: 'Share with post thumbnail',
        //   isEnable: true,
        //   onPressed: () {
        //     socialMetaTagParameters = SocialMetaTagParameters(
        //         description: model.description ?? "",
        //         title: "${model.user.displayName} Published a Post on Wiwa.",
        //         imageUrl: Uri.parse(
        //             model.user?.profilePic ?? Constants.dummyProfilePic
        //             // "https://play-lh.googleusercontent.com/e66XMuvW5hZ7HnFf8R_lcA3TFgkxm0SuyaMsBs3KENijNHZlogUAjxeu9COqsejV5w=s180-rw"
        //             ));
        //     Navigator.pop(context);
        //     Navigator.push(
        //       context,
        //       ShareWidget.getRoute(
        //         child: Tweet(
        //           model: model,
        //           type: type,
        //         ),
        //         socialMetaTagParameters: socialMetaTagParameters,
        //         id: "posts/${model.key}",
        //         // id: "${model.key}",
        //       ),
        //     );
        //   },
        // ),
        SizedBox(height: 12),
      ],
    );
  }
}
