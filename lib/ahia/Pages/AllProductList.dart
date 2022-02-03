import 'package:wiwa_app/ahia/Providers/StoreProvider.dart';
import 'package:wiwa_app/ahia/Widgets/Products/AllProductListWidget.dart';
import 'package:wiwa_app/ahia/Widgets/Products/ProductFilterWidget.dart';
import 'package:wiwa_app/ahia/Widgets/Products/ProductListWidget.dart';
import 'package:wiwa_app/ahia/Widgets/VendorAppBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllProductList extends StatelessWidget {
  static const String id = 'product-list';
  @override
  Widget build(BuildContext context) {
    var _storeProvider = Provider.of<StoreProvider>(context);
    return Scaffold(
        body: NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverAppBar(
            floating: true,
            snap: true,
            title: Text(_storeProvider.selectedProductCategory,
                style: TextStyle(color: Colors.black87)),
            iconTheme: IconThemeData(
              color: Colors.purple,
            ),
            expandedHeight: 110,
            flexibleSpace: Padding(
              padding: EdgeInsets.only(top: 88),
              child: Container(
                height: 56,
                color: Colors.grey,
                child: ProductFilterWidget(),
              ),
            ),
          ),
        ];
      },
      body: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: [
          AllProductListWidget(),
        ],
      ),
    ));
  }
}
