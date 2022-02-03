// import 'package:WiwaApp/Music/Player/PlayList.dart';
// import 'package:WiwaApp/Music/Player/SongPlayer.dart';
// import 'package:WiwaApp/Music/Player/Widgets/ArtistPlaylist.dart';
// import 'package:WiwaApp/Music/Player/Widgets/ArtistsSongs.dart';
// import 'package:WiwaApp/Music/Player/Widgets/Playlist.dart';
// // import 'package:WiwaApp/Music/Player/Widgets/Playlist.dart';
// import 'package:WiwaApp/Music/SongDashboard.dart';
// import 'package:WiwaApp/Music/Widgets/TopArtists.dart';
// import 'package:WiwaApp/ahia/Auth/WelcomeScreen.dart';
// import 'package:WiwaApp/ahia/Models/ProductModel.dart';
// import 'package:WiwaApp/ahia/Pages/Map_Screen.dart';
// import 'package:WiwaApp/ahia/Pages/ProfileScreen.dart';
// import 'package:WiwaApp/ahia/Providers/Auth_Provider.dart';
// import 'package:WiwaApp/ahia/Providers/Location_Provider.dart';
// import 'package:WiwaApp/ahia/Widgets/AllCategoriesWidget.dart';
// import 'package:WiwaApp/ahia/Widgets/AppBar.dart';
// import 'package:WiwaApp/ahia/Widgets/Products/AllFeaturedProducts.dart';
// import 'package:WiwaApp/ahia/Widgets/Products/TopPickedProductsListWidget.dart';
// import 'package:WiwaApp/ahia/Widgets/Cart/CartNotification.dart';
// import 'package:WiwaApp/ahia/Widgets/ImageSlider.dart';
// import 'package:WiwaApp/ahia/Widgets/NearByStores.dart';
// import 'package:WiwaApp/ahia/Widgets/Products/AllProductListWidget.dart';
// import 'package:WiwaApp/ahia/Widgets/Products/AllProductSearch.dart';
// import 'package:WiwaApp/ahia/Widgets/Products/AllBestSellingProducts.dart';
// import 'package:WiwaApp/ahia/Widgets/TopPickedStores.dart';
// import 'package:WiwaApp/ui/page/common/sidebar.dart';
// import 'package:WiwaApp/widgets/bottomMenuBar/bottomMenuBar.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:provider/provider.dart';
// import 'package:search_page/search_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class MusicHome extends StatefulWidget {
//   static const String id = 'music-home-screen';

//   @override
//   _MusicHomeState createState() => _MusicHomeState();
// }

// class _MusicHomeState extends State<MusicHome> {
//   static List<AllProduct> allProducts = [];
//   String offer;
//   String shopName;
//   DocumentSnapshot document;

//   @override
//   void initState() {
//     FirebaseFirestore.instance
//         .collection('products')
//         .get()
//         .then((QuerySnapshot querySnapshot) {
//       querySnapshot.docs.forEach((doc) {
//         setState(() {
//           document = doc;
//           offer = ((doc.data()['comparedPrice'] - doc.data()['price']) /
//                   (doc.data()['comparedPrice']) *
//                   100)
//               .toStringAsFixed(00);
//           allProducts.add(AllProduct(
//             brand: doc['brand'],
//             price: doc['price'],
//             category: doc['category']['mainCategory'],
//             image: doc['productImage'],
//             productName: doc['productName'],
//             document: doc,
//           ));
//         });
//       });
//     });
//     super.initState();
//   }

//   @override
//   void dispose() {
//     allProducts.clear();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(bottom: 50),
//         child: CartNotification(),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         iconTheme: IconThemeData(color: Colors.purple),
//         centerTitle: true,
//         title: Text('Wiwa Music',
//             style: TextStyle(
//               fontFamily: 'Signatra',
//               color: Colors.purple,
//               fontSize: 30,
//               // fontWeight: FontWeight.bold,
//             )),
//         actions: [
//           FlatButton(
//               splashColor: Colors.grey.shade200,
//               child: Row(
//                 children: [
//                   Text(
//                     'Upload',
//                     style: TextStyle(
//                         color: Colors.purple, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(width: 2),
//                   Icon(Icons.cloud_upload, color: Colors.purple, size: 30),
//                 ],
//               ),
//               onPressed: () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => SongDashBoard()));
//               }),
//           IconButton(
//             icon: Icon(Icons.search, color: Colors.purple, size: 30),
//             onPressed: () {
//               showSearch(
//                   context: context,
//                   delegate: SearchPage<AllProduct>(
//                     barTheme: ThemeData(
//                         hintColor: Colors.black,
//                         primaryColor: Colors.white,
//                         iconTheme: IconThemeData(color: Colors.purple)),
//                     onQueryUpdate: (s) => print(s),
//                     items: allProducts,
//                     searchLabel: 'Search product',
//                     suggestion: Center(
//                       child: Text(
//                         'Filter product by category, name or price',
//                         style: TextStyle(fontSize: 20),
//                       ),
//                     ),
//                     failure: Center(
//                       child: Text('No product found :(',
//                           style: TextStyle(fontSize: 20)),
//                     ),
//                     filter: (products) => [
//                       products.productName,
//                       products.category,
//                       products.brand,
//                       products.price.toString(),
//                     ],
//                     builder: (allProducts) => AllProductSearch(
//                       offer: offer,
//                       allProducts: allProducts,
//                       document: allProducts.document,
//                     ),
//                   ));
//             },
//           ),
//         ],
//       ),
//       body: ListView(
//         shrinkWrap: true,
//         children: [
//           // top picked stores
//           Container(height: 150, child: Expanded(child: TopArtists())),
//           // Divider(thickness: 1, color: Colors.grey[400]),
//           Container(
//               height: 340,
//               child: Expanded(
//                 child: AllArtistSongs(),
//               )),

//           // Container(
//           //     height: 500,
//           //     child: Expanded(
//           //       child: Playlist(),
//           //     )),

//           // Container(height: 520, child: home_pg()),

//           // // all categories
//           // Container(
//           //     height: 130, color: Colors.green[100], child: AllCategories()),
//           // // Divider(thickness: 1, color: Colors.grey[400]),

//           // // top picked products
//           // Container(
//           //     height: 220,
//           //     child: Expanded(child: TopPickedProductsListWidget())),
//           // Divider(thickness: 1, color: Colors.grey[400]),

//           // // best selling products
//           // Expanded(child: AllBestSellingProducts()),
//         ],
//       ),

//       // bottom navigation bar imported from wiwa
//       bottomNavigationBar: BottomMenubar(),

//       // sidewide drawer
//       drawer: SidebarMenu(),
//     );
//   }
// }
