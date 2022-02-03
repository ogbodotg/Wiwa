import 'package:wiwa_app/ahia/Providers/StoreProvider.dart';
import 'package:wiwa_app/ahia/Services/ProductServices.dart';
import 'package:wiwa_app/ahia/Widgets/Cart/CartNotification.dart';
import 'package:wiwa_app/ahia/Widgets/Products/FavouriteProductCard.dart';
import 'package:wiwa_app/ahia/Widgets/Products/ProductCardWidget.dart';
import 'package:wiwa_app/ahia/Widgets/Products/ProductFilterWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavouriteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ProductServices _services = ProductServices();
    User user = FirebaseAuth.instance.currentUser;
    return StreamBuilder<QuerySnapshot>(
      stream: _services.favourite
          .doc(user.uid)
          .collection('products')
          // .where('customerId', isEqualTo: user.uid)
          // .where('product', isNotEqualTo: null)

          // .where('isBestSelling', isEqualTo: true)
          // .where('category.subCategory',
          //     isEqualTo: _storeProvider.selectedSubCategory)
          // .where('seller.sellerUid',
          //     isEqualTo: _storeProvider.storeDetails['uid'])
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data.docs.isEmpty) {
          return Center(
              child: Text('You have no item in your wish list',
                  style: TextStyle(fontSize: 16)));
        }

        return Scaffold(
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: CartNotification(),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.purple),
            centerTitle: true,
            title: Text('Product Bookmark',
                style: TextStyle(color: Colors.black54)),
          ),
          body: SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  // ProductFilterWidget(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: FittedBox(
                              child: Row(
                            children: [
                              snapshot.data.docs.length <= 1
                                  ? Text('${snapshot.data.docs.length} Item',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold))
                                  : Text('${snapshot.data.docs.length} Items',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'in your Wish List',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w900),
                              )
                            ],
                          )),
                        ),
                      ),
                    ),
                  ),
                  new ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children:
                        snapshot.data.docs.map((DocumentSnapshot document) {
                      return new FavouriteProductCard(document);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
