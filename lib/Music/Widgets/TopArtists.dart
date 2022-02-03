import 'package:wiwa_app/Music/ArtistHomeScreen.dart';
import 'package:wiwa_app/Music/Providers/ArtistProvider.dart';
import 'package:wiwa_app/Music/Providers/SongProvider.dart';
import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:wiwa_app/ahia/Auth/WelcomeScreen.dart';
import 'package:wiwa_app/ahia/Pages/VendorHomeScreen.dart';
import 'package:wiwa_app/ahia/Providers/StoreProvider.dart';
import 'package:wiwa_app/ahia/Services/StoreServices.dart';
import 'package:wiwa_app/ahia/Services/UserServices.dart';
import 'package:wiwa_app/helper/constant.dart';
import 'package:wiwa_app/model/feedModel.dart';
import 'package:wiwa_app/model/user.dart';
import 'package:wiwa_app/state/authState.dart';
import 'package:wiwa_app/state/searchState.dart';
import 'package:wiwa_app/ui/page/profile/widgets/circular_image.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:wiwa_app/widgets/customWidgets.dart';
import 'package:wiwa_app/widgets/url_text/customUrlText.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class TopArtists extends StatelessWidget {
  // final UserModel userModel;

  // const TopArtists({
  //   Key key,
  //   this.userModel,
  // }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FeedModel model = FeedModel();
    MusicServices _services = MusicServices();
    // var _songData = Provider.of<SongProvider>(context);
    var _artistData = Provider.of<ArtistProvider>(context);
    var profilePic;
    var profileUsername;
    var profileDisplayName;
    var verifyBadge;

    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: _services.getTopPickedArtists(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapShot) {
          if (snapShot.hasError) {
            return Text('Something went wrong');
          }

          if (snapShot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapShot.hasData) {
            return Text("No top picked artists to display");
          }

          return Column(
            children: [
              Flexible(
                child: ListView(
                    scrollDirection: Axis.horizontal,
                    children:
                        snapShot.data.docs.map((DocumentSnapshot document) {
                      final searchState =
                          Provider.of<SearchState>(context, listen: false);
                      if (searchState.userlist != null) {
                        final userState = searchState.userlist.firstWhere(
                            (x) => x.userId == document['artistUid']);
                        profilePic = userState.profilePic;
                        profileUsername = userState.userName;
                        profileDisplayName = userState.displayName;
                        verifyBadge = userState.isVerified;
                      }

                      return InkWell(
                        onTap: () {
                          _artistData.getSelectedArtist(document);
                          pushNewScreenWithRouteSettings(
                            context,
                            settings: RouteSettings(name: ArtistHomeScreen.id),
                            screen: ArtistHomeScreen(),
                            withNavBar: true,
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Stack(
                            children: [
                              Column(
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  // mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: 70,
                                        height: 70,
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: Image.network(
                                                profilePic ??
                                                    Constants.dummyProfilePic,
                                                fit: BoxFit.cover))),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          profileDisplayName
                                              .toString()
                                              .substring(0, 8),
                                          // .toUpperCase(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                        ),
                                        verifyBadge
                                            ? customIcon(
                                                context,
                                                icon: AppIcon.blueTick,
                                                istwitterIcon: true,
                                                iconColor: AppColor.primary,
                                                size: 18,
                                              )
                                            : SizedBox(),
                                      ],
                                    ),
                                    Text(
                                      profileUsername
                                          .toString()
                                          .substring(0, 8),
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ]),
                            ],
                          ),
                        ),
                      );
                    }).toList()),
              ),
            ],
          );
        },
      ),
    );
  }
}
