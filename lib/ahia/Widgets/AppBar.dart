import 'package:wiwa_app/ahia/Auth/WelcomeScreen.dart';
import 'package:wiwa_app/ahia/Models/ProductModel.dart';
import 'package:wiwa_app/ahia/Pages/Map_Screen.dart';
import 'package:wiwa_app/ahia/Pages/ProfileScreen.dart';
import 'package:wiwa_app/ahia/Pages/SetDeliveryAddress.dart';
import 'package:wiwa_app/ahia/Providers/Location_Provider.dart';
import 'package:wiwa_app/ahia/Widgets/Products/AllProductSearch.dart';
import 'package:wiwa_app/ahia/Widgets/Products/SearchCardWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:search_page/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAppBar extends StatefulWidget {
  @override
  _MyAppBarState createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  static List<AllProduct> allProducts = [];
  String offer;
  String shopName;
  DocumentSnapshot document;

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection('products')
        .where('published', isEqualTo: true)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          document = doc;
          offer = ((doc['comparedPrice'] - doc['price']) /
                  (doc['comparedPrice']) *
                  100)
              .toStringAsFixed(00);
          allProducts.add(AllProduct(
            brand: doc['brand'],
            price: doc['price'],
            category: doc['category']['mainCategory'],
            image: doc['productImage'],
            productName: doc['productName'],
            document: doc,
          ));
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    allProducts.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      iconTheme: IconThemeData(color: Colors.purple),
      automaticallyImplyLeading: false,
      elevation: 0.0,
      floating: true,
      snap: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Wiwa Mart',
              style: TextStyle(
                fontFamily: 'Signatra',
                color: Colors.purple,
                fontSize: 30,
                // fontWeight: FontWeight.bold,
              )),
          SizedBox(width: 10),
          Text('powered by Ahia', style: TextStyle(fontSize: 10))
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.purple, size: 30),
          onPressed: () {
            showSearch(
                context: context,
                delegate: SearchPage<AllProduct>(
                  onQueryUpdate: (s) => print(s),
                  items: allProducts,
                  searchLabel: 'Search product',
                  suggestion: Center(
                    child: Text(
                      'Filter product by category, name or price',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  failure: Center(
                    child: Text('No product found :(',
                        style: TextStyle(fontSize: 20)),
                  ),
                  filter: (products) => [
                    products.productName,
                    products.category,
                    products.brand,
                    products.price.toString(),
                  ],
                  builder: (allProducts) => AllProductSearch(
                    offer: offer,
                    allProducts: allProducts,
                    document: allProducts.document,
                  ),
                ));
          },
        ),
        IconButton(
            icon: Icon(Icons.dashboard, color: Colors.purple, size: 30),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()));
            }),
      ],
      centerTitle: true,
    );
  }
}
