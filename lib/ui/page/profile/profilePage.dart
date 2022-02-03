import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:wiwa_app/Services/SocialMediaServices.dart';
import 'package:wiwa_app/ahia_vendor/Services/FirebaseServices.dart';
import 'package:wiwa_app/helper/constant.dart';
import 'package:wiwa_app/state/profile_state.dart';
import 'package:wiwa_app/ui/page/profile/EditProfilePage.dart';
import 'package:wiwa_app/ui/page/profile/RhythmAhia/allUsersAlbum.dart';
import 'package:wiwa_app/ui/page/profile/RhythmAhia/allUsersSongs.dart';
import 'package:wiwa_app/ui/page/profile/RhythmAhia/usersProducts.dart';
import 'package:wiwa_app/ui/page/profile/follow/followerListPage.dart';
import 'package:wiwa_app/ui/page/profile/profileImageView.dart';
import 'package:wiwa_app/ui/page/profile/qrCode/scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:wiwa_app/helper/enum.dart';
import 'package:wiwa_app/helper/utility.dart';
import 'package:wiwa_app/model/feedModel.dart';
import 'package:wiwa_app/model/user.dart';
import 'package:wiwa_app/ui/page/profile/widgets/tabPainter.dart';
import 'package:wiwa_app/state/authState.dart';
import 'package:wiwa_app/state/chats/chatState.dart';
import 'package:wiwa_app/state/feedState.dart';
import 'package:wiwa_app/ui/theme/custom_icon_icons.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:wiwa_app/widgets/customWidgets.dart';
import 'package:wiwa_app/widgets/newWidget/customLoader.dart';
import 'package:wiwa_app/widgets/url_text/customUrlText.dart';
import 'package:wiwa_app/widgets/newWidget/emptyList.dart';
import 'package:wiwa_app/widgets/newWidget/rippleButton.dart';
import 'package:wiwa_app/widgets/tweet/tweet.dart';
import 'package:wiwa_app/widgets/tweet/widgets/tweetBottomSheet.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:wiwa_app/ui/page/profile/widgets/circular_image.dart';
import 'package:wiwa_app/widgets/cache_image.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.profileId}) : super(key: key);

  final String profileId;
  static MaterialPageRoute getRoute({String profileId}) {
    return new MaterialPageRoute(
      builder: (_) => Provider(
        create: (_) => ProfileState(profileId),
        child: ChangeNotifierProvider(
          create: (BuildContext context) => ProfileState(profileId),
          builder: (_, child) => ProfilePage(
            profileId: profileId,
          ),
        ),
      ),
    );
  }

  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  // I disabled "SingleTickerProviderStateMixin" and used "TickerProviderStateMixin" to accomodate "Music" & "Store" profile Tabs
  // SingleTickerProviderStateMixin
  bool isMyProfile = false;
  int pageIndex = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  MusicServices _services = MusicServices();
  FirebaseServices _vendorServices = FirebaseServices();
  bool _artistExists = false;
  bool _sellerExists = false;
  String artistSongsPlayCount;
  SocialMediaServices _smServices = SocialMediaServices();

  // User user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    _smServices.myBanner.load();

    checkArtistsExists(); // checks if user is an artist
    checkSellerExists(); // checks if user is a vendore
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var authstate = Provider.of<ProfileState>(context, listen: false);

      isMyProfile = authstate.isMyProfile;
    });
    _tabController = TabController(length: 3, vsync: this); //default number tab
    _sellerTabController = TabController(
        length: 4, vsync: this); //number of tabs to display if user has a store
    _artistTabController = TabController(
        length: 4,
        vsync: this); // number of tabs to display if user is an artist
    _artistSellerTabController = TabController(
        length: 5,
        vsync:
            this); // number of tabs to display if user is an artist and sells items

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sellerTabController.dispose();
    _artistTabController.dispose();
    _artistSellerTabController.dispose();
    _smServices.myBanner.dispose();

    super.dispose();
  }

  Future<void> checkArtistsExists() async {
    _services.artists
        .doc(widget.profileId)
        .get()
        .then((DocumentSnapshot document) {
      if (document.exists) {
        if (document['accountVerified'] == true) {
          setState(() {
            _artistExists = true;
          });
        }
      }
    });
  }

  Future<void> checkSellerExists() async {
    _vendorServices.vendors
        .doc(widget.profileId)
        .get()
        .then((DocumentSnapshot document) {
      if (document.exists) {
        setState(() {
          _sellerExists = true;
        });
      }
    });
  }

  SliverAppBar getAppbar() {
    var authstate = Provider.of<ProfileState>(context);
    return SliverAppBar(
      forceElevated: false,
      expandedHeight: 200,
      elevation: 0,
      stretch: true,
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Colors.transparent,
      actions: <Widget>[
        authstate.isbusy
            ? SizedBox.shrink()
            : PopupMenuButton<Choice>(
                onSelected: (d) {
                  if (d.title == "Share") {
                    shareProfile(context);
                  } else if (d.title == "QR code") {
                    Navigator.push(context,
                        ScanScreen.getRoute(authstate.profileUserModel));
                  }
                },
                itemBuilder: (BuildContext context) {
                  return choices.map((Choice choice) {
                    return PopupMenuItem<Choice>(
                      value: choice,
                      child: Row(
                        children: [
                          Icon(choice.icon, color: Colors.purple),
                          SizedBox(width: 3),
                          Text(
                            choice.title,
                            style: TextStyles.textStyle14.copyWith(
                                color: choice.isEnable
                                    ? AppColor.secondary
                                    : AppColor.lightGrey),
                          ),
                        ],
                      ),
                    );
                  }).toList();
                },
              ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: <StretchMode>[
          StretchMode.zoomBackground,
          StretchMode.blurBackground
        ],
        background: authstate.isbusy
            ? SizedBox.shrink()
            : Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  SizedBox.expand(
                    child: Container(
                      padding: EdgeInsets.only(top: 50),
                      height: 30,
                      color: Colors.white,
                    ),
                  ),
                  // Container(height: 50, color: Colors.black),

                  /// Banner image
                  Container(
                    height: 190,
                    padding: EdgeInsets.only(top: 28),
                    child: CacheImage(
                      path: authstate.profileUserModel.bannerImage != null
                          ? authstate.profileUserModel.bannerImage
                          : Constants.dummyProfilePic,
                      fit: BoxFit.cover,
                    ),
                  ),

                  /// UserModel avatar, message icon, profile edit and follow/following button
                  Container(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 5),
                              shape: BoxShape.circle),
                          child: RippleButton(
                            child: CircularImage(
                              path: authstate.profileUserModel.profilePic,
                              height: 110,
                            ),
                            borderRadius: BorderRadius.circular(50),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  ProfileImageView.getRoute(
                                      authstate.profileUserModel.profilePic));
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 90, right: 30),
                          child: Row(
                            children: <Widget>[
                              isMyProfile
                                  ? Container(height: 40)
                                  : RippleButton(
                                      splashColor: TwitterColor.dodgetBlue_50
                                          .withAlpha(100),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                      onPressed: () {
                                        if (!isMyProfile) {
                                          final chatState =
                                              Provider.of<ChatState>(context,
                                                  listen: false);
                                          chatState.setChatUser =
                                              authstate.profileUserModel;
                                          Navigator.pushNamed(
                                              context, '/ChatScreenPage');
                                        }
                                      },
                                      child: Container(
                                        height: 35,
                                        width: 35,
                                        padding: EdgeInsets.only(
                                            bottom: 5,
                                            top: 0,
                                            right: 0,
                                            left: 0),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: isMyProfile
                                                    ? Colors.black87
                                                        .withAlpha(180)
                                                    : Colors.purple,
                                                width: 1),
                                            shape: BoxShape.circle),
                                        child: Icon(
                                          AppIcon.messageEmpty,
                                          color: Colors.purple,
                                          size: 20,
                                        ),

                                        // customIcon(context, icon:AppIcon.messageEmpty, iconColor: TwitterColor.dodgetBlue, paddingIcon: 8)
                                      ),
                                    ),
                              SizedBox(width: 10),
                              RippleButton(
                                splashColor:
                                    TwitterColor.dodgetBlue_50.withAlpha(100),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(60)),
                                onPressed: () {
                                  if (isMyProfile) {
                                    Navigator.push(
                                        context, EditProfilePage.getRoute());
                                  } else {
                                    authstate.followUser(
                                        removeFollower: isFollower());
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isFollower()
                                        ? TwitterColor.dodgetBlue
                                        : TwitterColor.white,
                                    border: Border.all(
                                        color: isMyProfile
                                            ? Colors.black87.withAlpha(180)
                                            : Colors.purple,
                                        width: 1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  /// If [isMyProfile] is true then Edit profile button will display
                                  // Otherwise Follow/Following button will be display
                                  child: Text(
                                    isMyProfile
                                        ? 'Edit Profile'
                                        : isFollower()
                                            ? 'Following'
                                            : 'Follow',
                                    style: TextStyle(
                                      color: isMyProfile
                                          ? Colors.black87.withAlpha(180)
                                          : isFollower()
                                              ? TwitterColor.white
                                              : Colors.purple,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/CreateFeedPage');
      },
      child: customIcon(
        context,
        icon: AppIcon.edit,
        istwitterIcon: true,
        iconColor: Theme.of(context).colorScheme.onPrimary,
        size: 25,
      ),
    );
  }

  Widget _emptyBox() {
    return SliverToBoxAdapter(child: SizedBox.shrink());
  }

  bool isFollower() {
    var authstate = Provider.of<ProfileState>(context, listen: false);
    if (authstate.profileUserModel.followersList != null &&
        authstate.profileUserModel.followersList.isNotEmpty) {
      return (authstate.profileUserModel.followersList
          .any((x) => x == authstate.userId));
    } else {
      return false;
    }
  }

  /// This meathod called when user pressed back button
  /// When profile page is about to close
  /// Maintain minimum user's profile in profile page list
  Future<bool> _onWillPop() async {
    return true;
  }

// tab controllers
  TabController _tabController;
  TabController _artistTabController;
  TabController _sellerTabController;
  TabController _artistSellerTabController;

  void shareProfile(BuildContext context) async {
    // var authstate = context.read<AuthState>();
    var authstate = Provider.of<ProfileState>(context);
    var user = authstate.profileUserModel;

    Utility.createLinkAndShare(
      context,
      "profilePage/${widget.profileId}/",
      socialMetaTagParameters: SocialMetaTagParameters(
        description: !user.bio.contains("Edit profile")
            ? user.bio
            : "Checkout ${user.displayName}'s profile on Wiwa",
        title: "${user.displayName} is on Wiwa",
        imageUrl: Uri.parse(user.profilePic),
      ),
    );
  }

  @override
  build(BuildContext context) {
    var state = Provider.of<FeedState>(context);
    var authstate = Provider.of<ProfileState>(context);
    List<FeedModel> list;
    String id = widget.profileId;

    /// Filter user's tweet among all tweets available in home page tweets list
    if (state.feedlist != null && state.feedlist.length > 0) {
      list = state.feedlist.where((x) => x.userId == id).toList();
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: scaffoldKey,
        floatingActionButton: !isMyProfile ? null : _floatingActionButton(),
        backgroundColor: TwitterColor.mystic,
        body: NestedScrollView(
          // controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
            return <Widget>[
              getAppbar(),
              authstate.isbusy
                  ? _emptyBox()
                  : SliverToBoxAdapter(
                      child: Container(
                        color: Colors.white,
                        child: authstate.isbusy
                            ? SizedBox.shrink()
                            : UserNameRowWidget(
                                user: authstate.profileUserModel,
                                isMyProfile: isMyProfile,
                              ),
                      ),
                    ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      color: TwitterColor.white,
                      child: _artistExists && _sellerExists
                          ? TabBar(
                              indicator: TabIndicator(),
                              controller: _artistSellerTabController,
                              tabs: <Widget>[
                                Text("Posts"),
                                Text("Replies"),
                                // condition would be written to determine if these tab would appear or not
                                Text("Media"),
                                Text("Music"),
                                Text("Store")
                              ],
                            )
                          : _artistExists
                              ? TabBar(
                                  indicator: TabIndicator(),
                                  controller: _artistTabController,
                                  tabs: <Widget>[
                                    Text("Posts"),
                                    Text("Replies"),
                                    // condition would be written to determine if these tab would appear or not
                                    Text("Media"),
                                    Text("Music"),
                                    //  Text("Store")
                                  ],
                                )
                              : _sellerExists
                                  ? TabBar(
                                      indicator: TabIndicator(),
                                      controller: _sellerTabController,
                                      tabs: <Widget>[
                                        Text("Posts"),
                                        Text("Replies"),
                                        // condition would be written to determine if these tab would appear or not
                                        Text("Media"),
                                        //  Text("Music"),
                                        Text("Store")
                                      ],
                                    )
                                  : TabBar(
                                      indicator: TabIndicator(),
                                      controller: _tabController,
                                      tabs: <Widget>[
                                        Text("Posts"),
                                        Text("Replies"),
                                        // condition would be written to determine if these tab would appear or not
                                        Text("Media"),
                                        //  Text("Music"),
                                        //  Text("Store")
                                      ],
                                    ),
                    )
                  ],
                ),
              )
            ];
          },
          body: _artistExists && _sellerExists
              ? TabBarView(
                  controller: _artistSellerTabController,
                  children: [
                    /// Display all independent tweers list
                    _tweetList(context, authstate, list, false, false),

                    /// Display all reply tweet list
                    _tweetList(context, authstate, list, true, false),

                    /// Display all reply and comments tweet list
                    _tweetList(context, authstate, list, false, true),

                    // condition would be written to determine if these tab would appear or not

                    SingleChildScrollView(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          // shrinkWrap: true,
                          children: [
                            // Google Ads
                            Container(
                                width:
                                    _smServices.myBanner.size.width.toDouble(),
                                height:
                                    _smServices.myBanner.size.height.toDouble(),
                                child: AdWidget(ad: _smServices.myBanner)),
                            SizedBox(
                              height: 20,
                            ),

                            AllUsersSongs(uid: id),

                            AllUsersProfileAlbum(uid: id),

                            // MiniPlayer()
                          ],
                        ),
                      ),
                    ),

                    SingleChildScrollView(
                        child: SellerProducts(
                      uid: id,
                    ))
                  ],
                )
              : _artistExists
                  ? TabBarView(
                      controller: _artistTabController,
                      children: [
                        /// Display all independent tweers list
                        _tweetList(context, authstate, list, false, false),

                        /// Display all reply tweet list
                        _tweetList(context, authstate, list, true, false),

                        /// Display all reply and comments tweet list
                        _tweetList(context, authstate, list, false, true),

                        // condition would be written to determine if these tab would appear or not

                        SingleChildScrollView(
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              // shrinkWrap: true,
                              children: [
                                // Google Ads
                                Container(
                                    width: _smServices.myBanner.size.width
                                        .toDouble(),
                                    height: _smServices.myBanner.size.height
                                        .toDouble(),
                                    child: AdWidget(ad: _smServices.myBanner)),
                                SizedBox(
                                  height: 20,
                                ),
                                AllUsersSongs(uid: id),

                                AllUsersProfileAlbum(uid: id),

                                // MiniPlayer()
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  : _sellerExists
                      ? TabBarView(
                          controller: _sellerTabController,
                          children: [
                            /// Display all independent tweers list
                            _tweetList(context, authstate, list, false, false),

                            /// Display all reply tweet list
                            _tweetList(context, authstate, list, true, false),

                            /// Display all reply and comments tweet list
                            _tweetList(context, authstate, list, false, true),

                            // condition would be written to determine if these tab would appear or not

                            SingleChildScrollView(
                                child: SellerProducts(
                              uid: id,
                            ))
                          ],
                        )
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            /// Display all independent tweers list
                            _tweetList(context, authstate, list, false, false),

                            /// Display all reply tweet list
                            _tweetList(context, authstate, list, true, false),

                            /// Display all reply and comments tweet list
                            _tweetList(context, authstate, list, false, true),
                          ],
                        ),
        ),
      ),
    );
  }

  Widget _tweetList(BuildContext context, ProfileState authstate,
      List<FeedModel> tweetsList, bool isreply, bool isMedia) {
    List<FeedModel> list;

    /// If user hasn't tweeted yet
    if (tweetsList == null) {
      // cprint('No Tweet avalible');
    } else if (isMedia) {
      /// Display all Tweets with media file

      list = tweetsList
          .where((x) => x.imagePath != null || x.videoPath != null)
          .toList();
    } else if (!isreply) {
      /// Display all independent Tweets
      /// No comments Tweet will display

      list = tweetsList
          .where((x) => x.parentkey == null || x.childRetwetkey != null)
          .toList();
    } else {
      /// Display all reply Tweets
      /// No intependent tweet will display
      list = tweetsList
          .where((x) => x.parentkey != null && x.childRetwetkey == null)
          .toList();
    }

    /// if [authState.isbusy] is true then an loading indicator will be displayed on screen.
    return authstate.isbusy
        ? Container(
            height: context.height - 180,
            child: CustomScreenLoader(
              height: double.infinity,
              width: context.width,
              backgroundColor: Colors.white,
            ),
          )

        /// if tweet list is empty or null then need to show user a message
        : list == null || list.length < 1
            ? Container(
                padding: EdgeInsets.only(top: 50, left: 30, right: 30),
                child: NotifyText(
                  title: isMyProfile
                      ? 'You haven\'t ${isreply ? 'replied to any post' : isMedia ? 'published any media content yet' : 'made any post yet'}'
                      : '${authstate.profileUserModel.userName} hasn\'t ${isreply ? 'replied to any post' : isMedia ? 'published any media content yet' : 'made any post yet'}',
                  subTitle: isMyProfile ? 'Tap the pen icon' : '',
                ),
              )

            /// If tweets available then tweet list will displayed
            : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 0),
                itemCount: list.length,
                itemBuilder: (context, index) => Container(
                  color: TwitterColor.white,
                  child: Tweet(
                    model: list[index],
                    isDisplayOnProfile: true,
                    trailing: TweetBottomSheet().tweetOptionIcon(
                      context,
                      model: list[index],
                      type: TweetType.Tweet,
                      scaffoldKey: scaffoldKey,
                    ),
                  ),
                ),
              );
  }
}

class UserNameRowWidget extends StatefulWidget {
  const UserNameRowWidget({
    Key key,
    @required this.user,
    @required this.isMyProfile,
  }) : super(key: key);

  final bool isMyProfile;
  final UserModel user;

  @override
  _UserNameRowWidgetState createState() => _UserNameRowWidgetState();
}

class _UserNameRowWidgetState extends State<UserNameRowWidget> {
  MusicServices _services = MusicServices();
  int totalSongPlayCount;
  bool _artistExists = false;
  @override
  void initState() {
    var state = context.read<ProfileState>();
    _services.artists
        .doc(state.profileId)
        .get()
        .then((DocumentSnapshot document) {
      if (document.exists) {
        if (document['accountVerified'] == true) {
          setState(() {
            _artistExists = true;
          });
        }
        totalSongPlayCount = document['playCount'];
      }
    });

    super.initState();
  }

  String getBio(String bio) {
    if (widget.isMyProfile) {
      return bio;
    } else if (bio == "Edit profile to update bio") {
      return "No bio available";
    } else {
      return bio;
    }
  }

  Widget _tappbleText(
    BuildContext context,
    String count,
    String text,
    Function onPressed,
  ) {
    return InkWell(
      onTap: () {
        onPressed();
      },
      child: Row(
        children: <Widget>[
          customText(
            '$count ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          customText(
            '$text',
            style: TextStyle(color: AppColor.darkGrey, fontSize: 17),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Row(
            children: <Widget>[
              UrlText(
                text: widget.user.displayName,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(
                width: 3,
              ),
              widget.user.isVerified
                  ? customIcon(context,
                      icon: AppIcon.blueTick,
                      istwitterIcon: true,
                      iconColor: AppColor.primary,
                      size: 16,
                      paddingIcon: 3)
                  : SizedBox(width: 0),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 9),
          child: customText(
            '${widget.user.userName}',
            style: TextStyles.subtitleStyle.copyWith(fontSize: 13),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: customText(
            getBio(widget.user.bio),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              customIcon(context,
                  icon: AppIcon.locationPin,
                  size: 14,
                  istwitterIcon: true,
                  paddingIcon: 5,
                  iconColor: AppColor.darkGrey),
              SizedBox(width: 10),
              Expanded(
                child: customText(
                  widget.user.location,
                  style: TextStyle(color: AppColor.darkGrey),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: <Widget>[
              customIcon(context,
                  icon: AppIcon.calender,
                  size: 14,
                  istwitterIcon: true,
                  paddingIcon: 5,
                  iconColor: AppColor.darkGrey),
              SizedBox(width: 10),
              customText(
                Utility.getJoiningDate(widget.user.createdAt),
                style: TextStyle(color: AppColor.darkGrey),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 10,
                height: 30,
              ),
              _tappbleText(context, '${widget.user.getFollowing}', ' Following',
                  () {
                var state = context.read<ProfileState>();
                Navigator.push(
                    context,
                    FollowerListPage.getRoute(
                        profile: state.profileUserModel,
                        userList: state.profileUserModel.followingList));
              }),
              SizedBox(width: 40),
              _tappbleText(context, '${widget.user.getFollower}',
                  widget.user.followers > 1 ? ' Followers' : ' Follower', () {
                var state = context.read<ProfileState>();
                Navigator.push(
                    context,
                    FollowerListPage.getRoute(
                        profile: state.profileUserModel,
                        userList: state.profileUserModel.followersList));
              }),
              SizedBox(width: 40),
              if (_artistExists && totalSongPlayCount > 0)
                Row(
                  children: [
                    Icon(CustomIcon.headphones_alt,
                        color: Theme.of(context).primaryColor),
                    SizedBox(width: 5),
                    Text(_services.formatNumber(totalSongPlayCount))
                  ],
                )
            ],
          ),
        ),
      ],
    );
  }
}

class Choice {
  const Choice({this.title, this.icon, this.isEnable = false});
  final bool isEnable;

  final IconData icon;
  final String title;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Share', icon: Icons.share, isEnable: true),
  // const Choice(
  //     title: 'QR code', icon: Icons.directions_railway, isEnable: true),
  // const Choice(title: 'Draft', icon: Icons.directions_bike),
  // const Choice(title: 'View Lists', icon: Icons.directions_boat),
  // const Choice(title: 'View Moments', icon: Icons.directions_bus),
];
