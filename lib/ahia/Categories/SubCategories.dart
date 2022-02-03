import 'package:wiwa_app/ahia/Pages/AllProductList.dart';
import 'package:wiwa_app/ahia/Providers/StoreProvider.dart';
import 'package:wiwa_app/ahia/Services/ProductServices.dart';
import 'package:wiwa_app/ahia/Widgets/AllCategoriesWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubCatListScreen extends StatelessWidget {
  static const String id = 'subcat-list';

  @override
  Widget build(BuildContext context) {
    ProductServices _services = ProductServices();
    var _storeProvider = Provider.of<StoreProvider>(context);
    DocumentSnapshot args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        shape: Border(bottom: BorderSide(color: Colors.grey)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        title: Flexible(
          child: Text(
            args['categoryName'],
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ),
      ),
      body: Container(
        child: FutureBuilder<DocumentSnapshot>(
          future: _services.category.doc(args.id).get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
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
            var data = snapshot.data['subCat'];
            return Container(
              // height: 200,
              child: ListView.builder(
                  // scrollDirection: Axis.horizontal,
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8),
                        child: ListTile(
                          onTap: () {
                            _storeProvider.selectedCategorySub(
                                data[index]['categoryName']);
                            Navigator.pushNamed(context, AllProductList.id);
                          },
                          title: Text(data[index]['categoryName'],
                              style: TextStyle(fontSize: 15)),
                        ));
                  }),
            );
          },
        ),
      ),
    );
  }
}
