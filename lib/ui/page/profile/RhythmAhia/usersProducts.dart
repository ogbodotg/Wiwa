import 'package:wiwa_app/Services/SocialMediaServices.dart';
import 'package:wiwa_app/ahia/Providers/StoreProvider.dart';
import 'package:wiwa_app/ahia/Services/ProductServices.dart';
import 'package:wiwa_app/ahia/Widgets/Cart/CartNotification.dart';
import 'package:wiwa_app/ahia/Widgets/Products/ProductCardWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class SellerProducts extends StatefulWidget {
  final String uid;

  const SellerProducts({Key key, this.uid}) : super(key: key);

  @override
  _SellerProductsState createState() => _SellerProductsState();
}

class _SellerProductsState extends State<SellerProducts> {
  SocialMediaServices _smServices = SocialMediaServices();

  @override
  void initState() {
    _smServices.myBanner.load();
    super.initState();
  }

  @override
  void dispose() {
    _smServices.myBanner.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser.uid;
    ProductServices _services = ProductServices();
    var _store = Provider.of<StoreProvider>(context);
    return FutureBuilder<QuerySnapshot>(
      future: _services.product
          .where('published', isEqualTo: true)
          .where('seller.sellerUid', isEqualTo: widget.uid)
          // .where('collection', isEqualTo: 'Recently Added')
          .get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return Center(
            child: Text('No item for sale'),
          );
        }
        if (snapshot.data.docs.isEmpty) {
          return Center(
            child: Text('No item for sale'),
          );
        }

        return Column(
          children: [
            // Google Ads
            Container(
                width: _smServices.myBanner.size.width.toDouble(),
                height: _smServices.myBanner.size.height.toDouble(),
                child: AdWidget(ad: _smServices.myBanner)),

            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: CartNotification(),
            ),

            new ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: snapshot.data.docs.map((DocumentSnapshot document) {
                return new ProductCard(document);
              }).toList(),
            ),
            // Google Ads
            // Container(
            //     width: _smServices.myBanner.size.width.toDouble(),
            //     height: _smServices.myBanner.size.height.toDouble(),
            //     child: AdWidget(ad: _smServices.myBanner)),
          ],
        );
      },
    );
  }
}
