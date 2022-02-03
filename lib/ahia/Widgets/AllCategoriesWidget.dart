import 'package:wiwa_app/ahia/Categories/CategoryList.dart';
import 'package:wiwa_app/ahia/Pages/AllProductList.dart';
import 'package:wiwa_app/ahia/Pages/ProductList.dart';
import 'package:wiwa_app/ahia/Widgets/Products/ProductListWidget.dart';
import 'package:wiwa_app/ahia/Providers/StoreProvider.dart';
import 'package:wiwa_app/ahia/Services/ProductServices.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class AllCategories extends StatefulWidget {
  @override
  _AllCategoriesState createState() => _AllCategoriesState();
}

class _AllCategoriesState extends State<AllCategories> {
  ProductServices _services = ProductServices();
  List _catList = [];

  @override
  void didChangeDependencies() {
    var _store = Provider.of<StoreProvider>(context);

    FirebaseFirestore.instance
        .collection('products')
        // .where('seller.sellerUid', isEqualTo: _store.storeDetails['uid'])
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                setState(() {
                  _catList.add(doc['category']['mainCategory']);
                });
              }),
            });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var _storeProvider = Provider.of<StoreProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder(
        future: _services.category.get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong...'));
          }
          if (_catList.length == 0) {
            return Center(
              child: Text(''),
            );
          }
          if (!snapshot.hasData) {
            return Container();
          }
          return Container(
            height: 200,
            child: Column(children: [
              Row(children: [
                Expanded(child: Text('Categories')),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, CategoryListScreen.id);
                  },
                  child: Row(
                    children: [
                      Text('See all'),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ),
              ]),
              Expanded(
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      var doc = snapshot.data.docs[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            _storeProvider
                                .selectedCategory(doc['categoryName']);
                            _storeProvider.selectedCategorySub(null);
                            pushNewScreenWithRouteSettings(
                              context,
                              settings: RouteSettings(name: AllProductList.id),
                              screen: AllProductList(),
                              withNavBar: true,
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          },
                          child: Container(
                              width: 75,
                              height: 60,
                              child: Column(
                                children: [
                                  Image.network(doc['categoryImage'],
                                      fit: BoxFit.cover),
                                  Flexible(
                                    child: Text(
                                        doc['categoryName'].toUpperCase(),
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 10)),
                                  )
                                ],
                              )),
                        ),
                      );
                    }),
              ),
            ]),
          );
          // SingleChildScrollView(
          //   child: Column(
          //     children: [
          //       Padding(
          //         padding: const EdgeInsets.only(left: 8, right: 8),
          //         child: Text('Shop by Categories',
          //             style:
          //                 TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          //       ),
          //       Wrap(
          //         direction: Axis.horizontal,
          //         children: snapshot.data.docs.map((DocumentSnapshot document) {
          //           return _catList.contains(document.data()['categoryName'])
          //               ? InkWell(
          //                   onTap: () {
          //                     _storeProvider.selectedCategory(
          //                         document.data()['categoryName']);
          //                     _storeProvider.selectedCategorySub(null);
          //                     pushNewScreenWithRouteSettings(
          //                       context,
          //                       settings: RouteSettings(name: AllProductList.id),
          //                       screen: AllProductList(),
          //                       withNavBar: true,
          //                       pageTransitionAnimation:
          //                           PageTransitionAnimation.cupertino,
          //                     );
          //                   },
          //                   child: Padding(
          //                     padding: const EdgeInsets.all(4.0),
          //                     child: Stack(
          //                       children: [
          //                         Container(
          //                           width: 100,
          //                           // height: 180,
          //                           child: Column(
          //                             children: [
          //                               Stack(
          //                                 children: [
          //                                   SizedBox(
          //                                     width: 100,
          //                                     height: 60,
          //                                     child: Card(
          //                                       child: ClipRRect(
          //                                           borderRadius:
          //                                               BorderRadius.circular(4),
          //                                           child: Image.network(
          //                                               document.data()[
          //                                                   'categoryImage'])),
          //                                     ),
          //                                   ),
          //                                 ],
          //                               ),
          //                               Text(
          //                                 document.data()['categoryName'],
          //                                 style: TextStyle(
          //                                     fontWeight: FontWeight.bold),
          //                                 textAlign: TextAlign.center,
          //                               ),
          //                             ],
          //                           ),
          //                         ),
          //                       ],
          //                     ),
          //                   ),
          //                 )
          //               : Text('');
          //         }).toList(),
          //       ),
          //     ],
          //   ),
          // );
        },
      ),
    );
  }
}
