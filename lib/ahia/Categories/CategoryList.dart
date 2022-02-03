import 'package:wiwa_app/ahia/Categories/SubCategories.dart';
import 'package:wiwa_app/ahia/Pages/AllProductList.dart';
import 'package:wiwa_app/ahia/Providers/StoreProvider.dart';
import 'package:wiwa_app/ahia/Services/ProductServices.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class CategoryListScreen extends StatelessWidget {
  static const String id = 'category-list';

  @override
  Widget build(BuildContext context) {
    ProductServices _services = ProductServices();
    var _storeProvider = Provider.of<StoreProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        shape: Border(bottom: BorderSide(color: Colors.grey)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        title: Text(
          'Categories',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        child: FutureBuilder(
          future: _services.category.get(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Something went wrong...'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            // if (_catList.length == 0) {
            //   return Center(
            //     child: Text(''),
            //   );
            // }
            if (!snapshot.hasData) {
              return Container();
            }
            return Container(
              // height: 200,
              child: ListView.builder(
                  // scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    var doc = snapshot.data.docs[index];
                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
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
                            // if (doc['subCat'] == null) {
                            //   return      _storeProvider
                            //     .selectedCategory(doc.data()['categoryName']);
                            // _storeProvider.selectedCategorySub(null);
                            // pushNewScreenWithRouteSettings(
                            //   context,
                            //   settings: RouteSettings(name: AllProductList.id),
                            //   screen: AllProductList(),
                            //   withNavBar: true,
                            //   pageTransitionAnimation:
                            //       PageTransitionAnimation.cupertino,
                            // );
                            // }
                            // Navigator.pushNamed(context, SubCatListScreen.id,
                            //     arguments: doc);
                          },
                          leading: Image.network(
                            doc['categoryImage'],
                            width: 50,
                          ),
                          title: Text(doc['categoryName'],
                              style: TextStyle(fontSize: 15)),
                          trailing: Icon(Icons.arrow_forward_ios),
                        ));
                  }),
            );
          },
        ),
      ),
    );
  }
}
