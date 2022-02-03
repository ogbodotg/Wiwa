import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:wiwa_app/ahia/Models/ProductModel.dart';
import 'package:wiwa_app/ahia/Pages/ProductDetails.dart';
import 'package:wiwa_app/ahia/Services/ProductServices.dart';
import 'package:wiwa_app/ahia/Widgets/Cart/Counter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:wiwa_app/helper/utility.dart';

class SearchCard extends StatelessWidget {
  final String offer;
  final Product products;
  final DocumentSnapshot document;
  const SearchCard({Key key, this.offer, this.products, this.document})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    ProductServices _productServices = ProductServices();
    String offer =
        ((products.document['comparedPrice'] - products.document['price']) /
                (products.document['comparedPrice']) *
                100)
            .toStringAsFixed(00);
    var _formatedPrice =
        _productServices.formatedPrice((products.document['price']).toDouble());
    var _formatedComparedPrice = _productServices
        .formatedPrice(products.document['comparedPrice'].toDouble());
    return Container(
      height: 160,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: Colors.grey[300])),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
        child: Row(children: [
          Stack(
            children: [
              Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {
                    pushNewScreenWithRouteSettings(
                      context,
                      settings: RouteSettings(name: ProductDetails.id),
                      screen: ProductDetails(document: products.document),
                      withNavBar: true,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                  child: SizedBox(
                    height: 140,
                    width: 130,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Hero(
                            tag: 'product${products.document['productName']}',
                            child: Image.network(
                                products.document['productImage'],
                                fit: BoxFit.cover))),
                  ),
                ),
              ),
              if (products.document['comparedPrice'] >
                  products.document['price'])
                Container(
                  decoration: BoxDecoration(
                    // color: Theme.of(context).primaryColor,
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 3, bottom: 3),
                    child: Text(
                      '${offer}% OFF',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 95,
                    top: 100,
                  ),
                  child: Container(
                    height: 33,
                    width: 33,
                    decoration: BoxDecoration(
                      // color: Theme.of(context).primaryColor,
                      color: Colors.purple,
                      borderRadius: BorderRadius.all(Radius.circular(18)
                          // topLeft: Radius.circular(15),
                          // bottomRight: Radius.circular(20),
                          // topRight: Radius.circular(20),
                          // bottomLeft: Radius.circular(20),
                          ),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.share
                          // CustomIcon
                          //     .share_1,
                          ),
                      onPressed: () async {
                        var socialMetaTagParameters = SocialMetaTagParameters(
                            description:
                                "\NGN${_formatedPrice.toString()}",
                            title:
                                "${products.document['productName']} on Wiwa Mart",
                            imageUrl: Uri.parse(
                                products.document['productImage'].toString()));
                        // Navigator.pop(
                        //     context);
                        var url = Utility.createLinkToShare(
                          context,
                          "products/${products.document['productId']}",
                          socialMetaTagParameters: socialMetaTagParameters,
                        );
                        var uri = await url;
                        Utility.share(uri.toString(),
                            subject:
                                "${products.document['productName']} @ \NGN${_formatedPrice.toString()} on Wiwa Mart");
                      },
                      iconSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 5),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            products.document['brand'],
                            style: TextStyle(fontSize: 10),
                          ),
                          SizedBox(height: 5),
                          Text(
                            products.document['productName'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Text('\NGN${_formatedPrice.toString()}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(width: 10),
                              if (products.document['comparedPrice'] >
                                  products.document['price'])
                                Text('\NGN${_formatedComparedPrice.toString()}',
                                    style: TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                        fontSize: 12))
                            ],
                          ),
                        ]),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width - 160,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CounterForCard(products.document),
                          ],
                        ),
                      ),
                    ],
                  )
                ]),
          )
        ]),
      ),
    );
  }
}
