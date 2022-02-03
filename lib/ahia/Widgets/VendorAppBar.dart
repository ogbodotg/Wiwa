import 'package:wiwa_app/ahia/Models/ProductModel.dart';
import 'package:wiwa_app/ahia/Pages/ProductDetails.dart';
import 'package:wiwa_app/ahia/Providers/StoreProvider.dart';
import 'package:wiwa_app/ahia/Widgets/Cart/Counter.dart';
import 'package:wiwa_app/ahia/Widgets/Products/SearchCardWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:search_page/search_page.dart';

class VendorAppBar extends StatefulWidget {
  @override
  _VendorAppBarState createState() => _VendorAppBarState();
}

class _VendorAppBarState extends State<VendorAppBar> {
  static List<Product> products = [];
  String offer;
  String shopName;
  String shopUid;
  DocumentSnapshot document;

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection('products')
        .where('published', isEqualTo: true)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        document = doc;
        offer = ((doc['comparedPrice'] - doc['price']) /
                (doc['comparedPrice']) *
                100)
            .toStringAsFixed(00);
        products.add(Product(
          brand: doc['brand'],
          price: doc['price'],
          category: doc['category']['mainCategory'],
          image: doc['productImage'],
          productName: doc['productName'],
          shopName: doc['seller']['shopName'],
          sellerUid: doc['seller']['sellerUid'],
          document: doc,
        ));
        setState(() {});
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    products.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _storeData = Provider.of<StoreProvider>(context);
    shopName = _storeData.storeDetails['shopName'];
    shopUid = _storeData.storeDetails['uid'];

    return SliverAppBar(
      floating: true,
      snap: true,
      iconTheme: IconThemeData(
        color: Colors.purple,
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {});
            showSearch(
                context: context,
                delegate: SearchPage<Product>(
                  barTheme: ThemeData(
                      hintColor: Colors.black,
                      primaryColor: Colors.white,
                      iconTheme: IconThemeData(color: Colors.purple)),
                  onQueryUpdate: (s) => print(s),
                  items: products,
                  searchLabel: 'Search product',
                  suggestion: Center(
                    child: Text('Filter product by category, name or price'),
                  ),
                  failure: Center(
                    child: Text('No product found :('),
                  ),
                  filter: (products) => [
                    products.productName,
                    products.category,
                    products.brand,
                    products.price.toString(),
                  ],
                  builder: (products) => shopUid != products.sellerUid
                      ? Container()
                      : SearchCard(
                          offer: offer,
                          products: products,
                          document: products.document,
                        ),
                ));
          },
          icon: Icon(CupertinoIcons.search),
        )
      ],
      title: Text(_storeData.storeDetails['shopName'],
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }
}
