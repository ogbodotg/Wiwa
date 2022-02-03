import 'package:wiwa_app/ahia/Auth/WelcomeScreen.dart';
import 'package:wiwa_app/ahia/Pages/VendorHomeScreen.dart';
import 'package:wiwa_app/ahia/Providers/StoreProvider.dart';
import 'package:wiwa_app/ahia/Services/StoreServices.dart';
import 'package:wiwa_app/ahia/Services/UserServices.dart';
import 'package:wiwa_app/helper/constant.dart';
import 'package:wiwa_app/state/searchState.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:wiwa_app/widgets/customWidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class TopPickedStores extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    StoreServices _storeServices = StoreServices();
    // StoreProvider _storeData = StoreProvider();
    var _storeData = Provider.of<StoreProvider>(context);
    var userState;
    var profileDisplayName;
    var profilePic;

    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: _storeServices.getTopPickedStores(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapShot) {
          if (snapShot.hasError) {
            return Text('Something went wrong');
          }

          if (snapShot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapShot.hasData) {
            return Text("No store to display");
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Text('Top Picked Stores',
                    style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ),
              Flexible(
                child: ListView(
                    scrollDirection: Axis.horizontal,
                    children:
                        snapShot.data.docs.map((DocumentSnapshot document) {
                      final searchState =
                          Provider.of<SearchState>(context, listen: false);
                      if (searchState.userlist != null) {
                        userState = searchState.userlist
                            .firstWhere((x) => x.userId == document['uid']);
                        profilePic = userState.profilePic;
                        // var profileUsername = userState.userName;
                        profileDisplayName = userState.displayName;
                      }

                      // final userState = searchState.userlist
                      //     .firstWhere((x) => x.userId == document['uid']);
                      // var profilePic = userState.profilePic;
                      // // var profileUsername = userState.userName;
                      // var profileDisplayName = userState.displayName;
                      return InkWell(
                        onTap: () {
                          _storeData.getSelectedStore(document);
                          pushNewScreenWithRouteSettings(
                            context,
                            settings: RouteSettings(name: VendorHomeScreen.id),
                            screen: VendorHomeScreen(),
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                      children: [
                                        Text(
                                          profileDisplayName
                                              .toString()
                                              .substring(0, 8),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        userState.isVerified
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
                                        document['shopCity'] +
                                            ' - ' +
                                            document['shopState'],
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                        )),
                                  ]),
                            ],
                          ),
                        ),
                      );
                    }).toList()),
              )
            ],
          );
        },
      ),
    );
  }
}
