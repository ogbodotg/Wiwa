import 'package:wiwa_app/ahia/Providers/StoreProvider.dart';
import 'package:wiwa_app/ahia/Widgets/Cart/CartNotification.dart';
import 'package:wiwa_app/ahia/Widgets/CategoriesWidget.dart';
import 'package:wiwa_app/ahia/Widgets/ImageSlider.dart';
import 'package:wiwa_app/ahia/Widgets/Products/BestSellingProduct.dart';
import 'package:wiwa_app/ahia/Widgets/Products/FeaturedProducts.dart';
import 'package:wiwa_app/ahia/Widgets/Products/RecentlyAddedProducts.dart';
import 'package:wiwa_app/ahia/Widgets/Products/ShopServices.dart';
import 'package:wiwa_app/ahia/Widgets/VendorAppBar.dart';
import 'package:wiwa_app/ahia/Widgets/VendorBanner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VendorHomeScreen extends StatelessWidget {
  static const String id = 'vendor-home-screen';
  @override
  Widget build(BuildContext context) {
    // StoreProvider _storeData = StoreProvider();
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: CartNotification(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            VendorAppBar(),
          ];
        },
        body: ListView(
          shrinkWrap: true,
          children: [
            // VendorBanner(),
            VendorCategories(),
            RecentlyAddedProducts(),
            FeaturedProducts(),
            BestSellingProducts(),
            ShopServices()
          ],
        ),
      ),
    );
  }
}
