import 'package:wiwa_app/ahia/Auth/WelcomeScreen.dart';
import 'package:wiwa_app/ahia/Pages/FavouriteScreen.dart';
import 'package:wiwa_app/ahia/Pages/HomeScreen.dart';
import 'package:wiwa_app/ahia/Pages/OrdersScreen.dart';
import 'package:wiwa_app/ahia/Pages/ProfileUpdate.dart';
import 'package:wiwa_app/ahia/Pages/SetDeliveryAddress.dart';
import 'package:wiwa_app/ahia/Providers/Auth_Provider.dart';
import 'package:wiwa_app/ahia/Providers/StoreProvider.dart';
import 'package:wiwa_app/ahia/Services/StoreServices.dart';
import 'package:wiwa_app/ahia_vendor/Auth/Register_Screen.dart';
import 'package:wiwa_app/ahia_vendor/Pages/CouponScreen.dart';
import 'package:wiwa_app/ahia_vendor/Pages/OrderPage.dart';
import 'package:wiwa_app/ahia_vendor/Pages/ProductScreen.dart';
import 'package:wiwa_app/ahia_vendor/Pages/VendorBanner.dart';
import 'package:wiwa_app/helper/constant.dart';
import 'package:wiwa_app/state/authState.dart';
import 'package:wiwa_app/state/profile_state.dart';
import 'package:wiwa_app/ui/page/profile/widgets/circular_image.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:wiwa_app/widgets/customWidgets.dart';
import 'package:wiwa_app/widgets/newWidget/rippleButton.dart';
import 'package:wiwa_app/widgets/newWidget/title_text.dart';
import 'package:wiwa_app/widgets/url_text/customUrlText.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  static const String id = 'profile-screen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isMyProfile = false;

  User user = FirebaseAuth.instance.currentUser;
  DocumentSnapshot doc;

  StoreServices _storeServices = StoreServices();
  bool _storeExists = false;
  bool _storeVerified = false;
  String _shopName;

  Future<void> getVendorDetails() async {
    _storeServices.vendors
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot document) {
      if (document.exists) {
        setState(() {
          _storeExists = true;
          doc = document;
          _shopName = doc['shopName'];
          _storeVerified = doc['accountVerified'] == true;
        });
      }
    });
  }

  @override
  void initState() {
    // var authstate = Provider.of<ProfileState>(context, listen: false);

    // isMyProfile = authstate.isMyProfile;
    getVendorDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var authstate = Provider.of<ProfileState>(context);
    final state = context.watch<AuthState>();

    var userDetails = Provider.of<AuthProvider>(context);
    userDetails?.getUserDetails();
    // User user = FirebaseAuth.instance.currentUser;

    return ListView(children: [
      AppBar(
        elevation: 0.0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.purple,
        ),
        title: Text('Dashboard', style: TextStyle(color: Colors.black54)),
      ),
      SingleChildScrollView(
        // physics: ScrollPhysics(),
        child: Container(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    color: Colors.purple[100],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 56,
                                width: 56,
                                margin: EdgeInsets.only(left: 17, top: 10),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                  borderRadius: BorderRadius.circular(28),
                                  image: DecorationImage(
                                    image: customAdvanceNetworkImage(
                                      state.userModel.profilePic ??
                                          Constants.dummyProfilePic,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // mainAxisAlignment:
                                //     MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: <Widget>[
                                      UrlText(
                                        text: state.userModel.displayName ??
                                            "ARYA STARK has 'NO NAME'",
                                        style: TextStyles.onPrimaryTitleText
                                            .copyWith(
                                                color: Colors.black,
                                                fontSize: 20),
                                      ),
                                      SizedBox(
                                        width: 3,
                                      ),
                                      state.userModel.isVerified ?? false
                                          ? customIcon(context,
                                              icon: AppIcon.blueTick,
                                              istwitterIcon: true,
                                              iconColor: AppColor.primary,
                                              size: 18,
                                              paddingIcon: 3)
                                          : SizedBox(
                                              width: 0,
                                            ),
                                    ],
                                  ),
                                  customText(
                                    state.userModel.userName,
                                    style: TextStyles.onPrimarySubTitleText
                                        .copyWith(
                                            color: Colors.black54,
                                            fontSize: 15),
                                  ),
                                  // Text(
                                  //     userDetails.snapshot.data() != null
                                  //         ? '${userDetails.snapshot['phoneNumber']}'
                                  //         : 'No Phone Number',
                                  //     style: TextStyle(
                                  //         fontWeight: FontWeight.bold,
                                  //         fontSize: 16,
                                  //         color: Colors.white)),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          // if (userDetails.snapshot.data() != null)
                          ListTile(
                            tileColor: Colors.white,
                            leading: Icon(Icons.location_on,
                                color: Theme.of(context).primaryColor),
                            title: userDetails?.snapshot?.data() != null
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          userDetails.snapshot != null
                                              ? '${userDetails.snapshot['number']}'
                                              : 'No Address',
                                          maxLines: 1),
                                      Text(
                                          userDetails.snapshot != null
                                              ? '${userDetails.snapshot['address']}'
                                              : 'No Phone Number',
                                          maxLines: 1),
                                    ],
                                  )
                                : Container(),
                            subtitle: userDetails?.snapshot?.data() != null
                                ? Row(
                                    children: [
                                      Text(
                                        userDetails.snapshot != null
                                            ? '${userDetails.snapshot['city']}'
                                            : 'No City',
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        userDetails.snapshot != null
                                            ? '${userDetails.snapshot['state']}'
                                            : 'No State',
                                      ),
                                    ],
                                  )
                                : Container(),
                            trailing: RippleButton(
                              onPressed: () async {
                                Navigator.pushNamed(
                                    context, SetDeliveryLocation.id);
                                pushNewScreenWithRouteSettings(
                                  context,
                                  settings: RouteSettings(
                                      name: SetDeliveryLocation.id),
                                  screen: SetDeliveryLocation(),
                                  withNavBar: false,
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: Color(0xffeeeeee),
                                      blurRadius: 15,
                                      offset: Offset(5, 5),
                                    ),
                                  ],
                                ),
                                child: Wrap(
                                  children: <Widget>[
                                    Icon(Icons.location_pin,
                                        color: Theme.of(context).primaryColor),
                                    SizedBox(width: 10),
                                    TitleText(
                                      'Set Delivery Address',
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // OutlineButton(
                            //   borderSide: BorderSide(
                            //     color: Theme.of(context).primaryColor,
                            //   ),
                            //   child: Text('Set Address',
                            //       style: TextStyle(
                            //           color: Theme.of(context).primaryColor)),
                            //   onPressed: () {
                            //     Navigator.pushNamed(
                            //         context, SetDeliveryLocation.id);
                            //     pushNewScreenWithRouteSettings(
                            //       context,
                            //       settings: RouteSettings(
                            //           name: SetDeliveryLocation.id),
                            //       screen: SetDeliveryLocation(),
                            //       withNavBar: false,
                            //       pageTransitionAnimation:
                            //           PageTransitionAnimation.cupertino,
                            //     );
                            //   },
                            // ),
                          )
                        ],
                      ),
                    ),
                  ),
                  // Positioned(
                  //     right: 10.0,
                  //     // top: 10.0,
                  //     child: IconButton(
                  //       icon: Icon(
                  //         Icons.edit_outlined,
                  //         color: Colors.white,
                  //       ),
                  //       onPressed: () {
                  //         // pushNewScreenWithRouteSettings(
                  //         //   context,
                  //         //   settings: RouteSettings(name: UpdateProfile.id),
                  //         //   screen: UpdateProfile(),
                  //         //   withNavBar: false,
                  //         //   pageTransitionAnimation:
                  //         //       PageTransitionAnimation.cupertino,
                  //         // );
                  //       },
                  //     )),
                ],
              ),
              ListTile(
                leading: Icon(Icons.history),
                title: Text('My Orders'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyOrders()));
                },
              ),
              Divider(),

              ListTile(
                leading: Icon(Icons.bookmark),
                title: Text('Product Bookmark'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FavouriteScreen()));
                },
              ),
              // Divider(),
              // ListTile(
              //     leading: Icon(Icons.notifications),
              //     title: Text('Notifications')),
              Divider(
                thickness: 5,
              ),
              ListTile(
                  title: Text('Vendor\'s Section',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              // check if user currently has a store before displaying Create Store menu
              // if (_storeData.storeDetails['uid'] != _firebaseAuth.currentUser.uid)
              _storeExists
                  ? ListTile(
                      leading: Icon(Icons.storefront),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Shop Name: ',
                            ),
                          ),
                          Flexible(
                              child: Text(
                            '${_shopName}',
                          )),
                          SizedBox(
                            width: 10,
                          ),
                          _storeVerified
                              ? Flexible(
                                  child: Text('Shop verified',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                          color: Colors.purple)),
                                )
                              : Flexible(
                                  child: Text('Shop not yet verified',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                          color: Colors.red)),
                                )
                        ],
                      ),
                    )
                  : ListTile(
                      leading: Icon(Icons.storefront),
                      title: Text('Start selling (Create a shop)'),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterScreen()));

                        // Navigator.pushReplacementNamed(context, RegisterScreen.id);
                      },
                    ),
              Divider(),
              _storeVerified
                  ? ListTile(
                      leading: Icon(Icons.shopping_bag_outlined),
                      title: Text('Products/Services'),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProductScreen()));
                      },
                    )
                  : Container(),
              Divider(),
              _storeVerified
                  ? ListTile(
                      leading: Icon(CupertinoIcons.gift),
                      title: Text('Coupons'),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CouponScreen()));
                      },
                    )
                  : Container(),
              Divider(),
              _storeVerified
                  ? ListTile(
                      leading: Icon(Icons.list_alt_outlined),
                      title: Text('Customer Orders'),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OrderPage()));
                      },
                    )
                  : Container(),
              Divider(),
              // ListTile(
              //     leading: Icon(Icons.comment_outlined),
              //     title: Text('My Ratings & Review')),
              // ListTile(
              //   leading: Icon(Icons.photo),
              //   title: Text('Shop Banner'),
              //   onTap: () {
              //     // Navigator.pushReplacementNamed(context, VendorBanner.id);

              //     Navigator.push(context,
              //         MaterialPageRoute(builder: (context) => VendorBanner()));
              //   },
              // ),
            ],
          ),
        ),
      ),
    ]);
  }
}
