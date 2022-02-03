import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:wiwa_app/ahia/Auth/WelcomeScreen.dart';
import 'package:wiwa_app/ahia/Pages/ProductDetails.dart';
import 'package:wiwa_app/ahia/Pages/VendorHomeScreen.dart';
import 'package:wiwa_app/ahia/Providers/StoreProvider.dart';
import 'package:wiwa_app/ahia/Services/ProductServices.dart';
import 'package:wiwa_app/ahia/Services/StoreServices.dart';
import 'package:wiwa_app/ahia/Services/UserServices.dart';
import 'package:wiwa_app/ahia/Widgets/Cart/Counter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:wiwa_app/helper/customRoute.dart';
import 'package:wiwa_app/helper/utility.dart';

class ProductRoute extends StatelessWidget {
  final String productId;

  const ProductRoute({Key key, this.productId}) : super(key: key);

  // static getRoute(String songId) {
  //   return SongShareRoute(
  //     songId: songId,
  //   );
  // }

  static Route<Null> getRoute(String productId) {
    return SlideLeftRoute<Null>(
      builder: (BuildContext context) => ProductRoute(
        productId: productId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ProductServices _productServices = ProductServices();

    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: _productServices.product
            .where('published', isEqualTo: true)
            .where('productId', isEqualTo: productId)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapShot) {
          if (snapShot.hasError) {
            return Text('Something went wrong');
          }

          if (snapShot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapShot.hasData) {
            return Text("No product to display");
          }

          return Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: Theme.of(context).primaryColor,
              ),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Padding(
                //   padding: const EdgeInsets.only(left: 8, right: 8, top: 10),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     children: [
                //       Text('Best Deals on Wiwa',
                //           style: TextStyle(
                //               color: Colors.black87,
                //               fontWeight: FontWeight.w900,
                //               fontSize: 16)),
                //     ],
                //   ),
                // ),
                Flexible(
                  child: ListView(
                      scrollDirection: Axis.vertical,
                      children:
                          snapShot.data.docs.map((DocumentSnapshot document) {
                        String offer =
                            ((document['comparedPrice'] - document['price']) /
                                    (document['comparedPrice']) *
                                    100)
                                .toStringAsFixed(00);
                        var _formatedPrice =
                            _productServices.formatedPrice(document['price']);
                        var _formatedComparedPrice = _productServices
                            .formatedPrice(document['comparedPrice']);
                        return InkWell(
                            onTap: () {
                              pushNewScreenWithRouteSettings(
                                context,
                                settings:
                                    RouteSettings(name: ProductDetails.id),
                                screen: ProductDetails(document: document),
                                withNavBar: true,
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                            },
                            child: Container(
                              height: 700,
                              // width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        width: 1, color: Colors.grey[400])),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 8, left: 10, right: 10),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Stack(
                                        children: [
                                          Material(
                                            elevation: 5,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: SizedBox(
                                              height: 400,
                                              width: 400,
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Hero(
                                                      tag:
                                                          'product${document['productName']}',
                                                      child: Image.network(
                                                          document[
                                                              'productImage'],
                                                          fit: BoxFit.cover))),
                                            ),
                                          ),
                                          if (document['comparedPrice'] >
                                              document['price'])
                                            Container(
                                              decoration: BoxDecoration(
                                                // color: Theme.of(context).primaryColor,
                                                color: Colors.red,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10),
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10,
                                                    right: 10,
                                                    top: 3,
                                                    bottom: 3),
                                                child: Text(
                                                  '${offer}% OFF',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          Container(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 350,
                                                  right: 3,
                                                  top: 350,
                                                  bottom: 3),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  // color: Theme.of(context).primaryColor,
                                                  color: Colors.purple,
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(18)
                                                      // topLeft: Radius.circular(15),
                                                      // bottomRight: Radius.circular(20),
                                                      // topRight: Radius.circular(20),
                                                      // bottomLeft: Radius.circular(20),
                                                      ),
                                                ),
                                                child: IconButton(
                                                  icon: Icon(Icons.share
                                                      // CustomIcon
                                                      //     .share_1,
                                                      ),
                                                  onPressed: () async {
                                                    var socialMetaTagParameters =
                                                        SocialMetaTagParameters(
                                                            description:
                                                                "Price: \NGN${_formatedPrice.toString()}",
                                                            title:
                                                                "${document['productName']} on Wiwa Mart",
                                                            imageUrl: Uri.parse(
                                                                document[
                                                                        'productImage']
                                                                    .toString()));
                                                    // Navigator.pop(
                                                    //     context);
                                                    var url = Utility
                                                        .createLinkToShare(
                                                      context,
                                                      "products/${document['productId']}",
                                                      socialMetaTagParameters:
                                                          socialMetaTagParameters,
                                                    );
                                                    var uri = await url;
                                                    Utility.share(
                                                        uri.toString(),
                                                        subject:
                                                            "${document['productName']} @ \NGN${_formatedPrice.toString()} on Wiwa Mart");
                                                  },
                                                  iconSize: 25,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8, top: 20),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        document['brand'],
                                                        style: TextStyle(
                                                            fontSize: 15),
                                                      ),
                                                      SizedBox(height: 5),
                                                      Text(
                                                        document['productName'],
                                                        style: TextStyle(
                                                            fontSize: 28,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      SizedBox(height: 5),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                              '\NGN${_formatedPrice.toString()}',
                                                              style: TextStyle(
                                                                  fontSize: 22,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          SizedBox(width: 10),
                                                          if (document[
                                                                  'comparedPrice'] >
                                                              document['price'])
                                                            Text(
                                                                '\NGN${_formatedComparedPrice.toString()}',
                                                                style: TextStyle(
                                                                    decoration:
                                                                        TextDecoration
                                                                            .lineThrough,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        20))
                                                        ],
                                                      ),
                                                      SizedBox(height: 35),
                                                      Center(
                                                          child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          CounterForCard(
                                                              document),
                                                        ],
                                                      )),
                                                    ]),
                                              ),
                                            ]),
                                      )
                                    ]),
                              ),
                            ));
                      }).toList()),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
