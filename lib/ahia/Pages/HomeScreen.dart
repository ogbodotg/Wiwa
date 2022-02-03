import 'package:wiwa_app/ahia/Auth/WelcomeScreen.dart';
import 'package:wiwa_app/ahia/Models/ProductModel.dart';
import 'package:wiwa_app/ahia/Pages/Map_Screen.dart';
import 'package:wiwa_app/ahia/Pages/ProfileScreen.dart';
import 'package:wiwa_app/ahia/Providers/Auth_Provider.dart';
import 'package:wiwa_app/ahia/Providers/Location_Provider.dart';
import 'package:wiwa_app/ahia/Widgets/AllCategoriesWidget.dart';
import 'package:wiwa_app/ahia/Widgets/AppBar.dart';
import 'package:wiwa_app/ahia/Widgets/Products/AllFeaturedProducts.dart';
import 'package:wiwa_app/ahia/Widgets/Products/AllServices.dart';
import 'package:wiwa_app/ahia/Widgets/Products/TopPickedProductsListWidget.dart';
import 'package:wiwa_app/ahia/Widgets/Cart/CartNotification.dart';
import 'package:wiwa_app/ahia/Widgets/ImageSlider.dart';
import 'package:wiwa_app/ahia/Widgets/NearByStores.dart';
import 'package:wiwa_app/ahia/Widgets/Products/AllProductListWidget.dart';
import 'package:wiwa_app/ahia/Widgets/Products/AllProductSearch.dart';
import 'package:wiwa_app/ahia/Widgets/Products/AllBestSellingProducts.dart';
import 'package:wiwa_app/ahia/Widgets/TopPickedStores.dart';
import 'package:wiwa_app/ui/page/common/sidebar.dart';
import 'package:wiwa_app/widgets/bottomMenuBar/bottomMenuBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:search_page/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home-screen';
  const HomeScreen({Key key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static List<AllProduct> allProducts = [];
  String offer;
  String shopName;
  DocumentSnapshot document;

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection('products')
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
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: CartNotification(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.purple),
        centerTitle: true,
        title: Text('Mart',
            style: TextStyle(
              fontFamily: 'Signatra',
              color: Theme.of(context).primaryColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            )),
        actions: <Widget>[
          IconButton(
              tooltip: 'Control shoping activities from Dashboard',
              icon: Icon(Icons.dashboard, color: Colors.purple, size: 20),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()));
              }),
          IconButton(
            tooltip: 'Search for products',
            icon: Icon(Icons.search, color: Colors.purple, size: 20),
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: SearchPage<AllProduct>(
                    barTheme: ThemeData(
                        hintColor: Colors.black,
                        primaryColor: Colors.white,
                        iconTheme: IconThemeData(color: Colors.purple)),
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
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            // shrinkWrap: true,
            children: [
              // top picked stores
              Container(height: 150, child: TopPickedStores()),
              Divider(),
              // Divider(thickness: 1, color: Colors.grey[400]),

              Container(height: 390, child: AllFeaturedProductsListWidget()),
              Divider(),

              Container(height: 220, child: AllServices()),
              Divider(),

              // all categories
              Container(
                  // height: 180,
                  // color: Colors.green[100],
                  child: AllCategories()),
              Divider(),
              // Divider(thickness: 1, color: Colors.grey[400]),

              // top picked products
              Container(height: 220, child: TopPickedProductsListWidget()),
              Divider(),

              // best selling products
              Container(child: AllBestSellingProducts()),
            ],
          ),
        ),
      ),

      // bottom navigation bar imported from wiwa
      // bottomNavigationBar: BottomMenubar(),

      // sidewide drawer
      drawer: SidebarMenu(),
    );
  }
}
