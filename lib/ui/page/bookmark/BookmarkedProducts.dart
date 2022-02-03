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
import 'package:wiwa_app/widgets/newWidget/emptyList.dart';

class BookMarkedProducts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ProductServices _services = ProductServices();
    User user = FirebaseAuth.instance.currentUser;
    return StreamBuilder<QuerySnapshot>(
      stream:
          _services.favourite.doc(user.uid).collection('products').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return SingleChildScrollView(
            child: SizedBox(
              height: 3,
              child: LinearProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData) {
          return SingleChildScrollView(
            child: SizedBox(
              height: 3,
              child: LinearProgressIndicator(),
            ),
          );
        }
        if (snapshot.data.docs.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: EmptyList(
              'You have not bookmarked any product yet',
              subTitle: 'Bookmarked products appear here.',
            ),
          );
          // Center(
          //     child: Text('You have no item in your product bookmark',
          //         style: TextStyle(fontSize: 16)));
        }

        return Scaffold(
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: CartNotification(),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          // appBar: AppBar(
          //   iconTheme: IconThemeData(color: Colors.purple),
          //   centerTitle: true,
          //   title: Text('Favourites (Wish List)',
          //       style: TextStyle(color: Colors.black54)),
          // ),
          body: SingleChildScrollView(
            child: Container(
              child: new ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: snapshot.data.docs.map((DocumentSnapshot document) {
                  return new FavouriteProductCard(document);
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
