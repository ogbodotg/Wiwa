import 'dart:async';
import 'dart:io';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:wiwa_app/Services/SocialMediaServices.dart';
import 'package:wiwa_app/ahia/Services/ProductServices.dart';
import 'package:wiwa_app/ahia/Widgets/Products/BottomSheetContainer.dart';
import 'package:wiwa_app/ahia/Widgets/VendorBanner.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wiwa_app/helper/utility.dart';
// import 'package:galleryimage/galleryimage.dart';
// import 'package:photo_view/photo_view.dart';

class ProductDetails extends StatefulWidget {
  static const String id = 'product-details';
  final DocumentSnapshot document;

  ProductDetails({this.document});

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  bool _loading = true;
  int itemIndex = 0;
  SocialMediaServices _smServices = SocialMediaServices();

  @override
  void initState() {
    Timer(Duration(seconds: 2), () {
      setState(() {
        _loading = false;
      });
    });
    _smServices.myBigSquare.load();
  }

  @override
  void dispose() {
    _smServices.myBigSquare.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ProductServices _productServices = ProductServices();
    var _formatedPrice =
        _productServices.formatedPrice((widget.document['price']));
    var _formatedComparedPrice =
        _productServices.formatedPrice(widget.document['comparedPrice']);

    String offer =
        ((widget.document['comparedPrice'] - widget.document['price']) /
                (widget.document['comparedPrice']) *
                100)
            .toStringAsFixed(00);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.purple,
        ),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.search),
            onPressed: () {},
          )
        ],
      ),
      bottomSheet: BottomSheetContainer(widget.document),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView(
          shrinkWrap: true,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(.3),
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8, bottom: 2, top: 2),
                    child: Text(widget.document['brand']),
                  ),
                ),
                SizedBox(width: 100),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.share
                          // CustomIcon
                          //     .share_1,
                          ),
                      onPressed: () async {
                        var socialMetaTagParameters = SocialMetaTagParameters(
                            description: "\NGN${_formatedPrice.toString()}",
                            title:
                                "${widget.document['productName']} on Wiwa Mart",
                            imageUrl: Uri.parse(
                                widget.document['productImage'].toString()));
                        // Navigator.pop(
                        //     context);
                        var url = Utility.createLinkToShare(
                          context,
                          "products/${widget.document['productId']}",
                          socialMetaTagParameters: socialMetaTagParameters,
                        );
                        var uri = await url;
                        Utility.share(uri.toString(),
                            subject:
                                "${widget.document['productName']} @ \NGN${_formatedPrice.toString()} on Wiwa Mart");
                      },
                      iconSize: 55,
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(widget.document['productName'],
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              children: [
                Text('\NGN${_formatedPrice.toString()}',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                if (widget.document['comparedPrice'] > widget.document['price'])
                  Text(
                    '\NGN${_formatedComparedPrice.toString()}',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.lineThrough),
                  ),
                SizedBox(width: 10),
                if (widget.document['comparedPrice'] > widget.document['price'])
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8, right: 8, top: 3, bottom: 3),
                      child: Text('${offer}% OFF',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 12)),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Hero(
                  tag: 'product${widget.document['productName']}',
                  child: Image.network(widget.document['productImage'])),
            ),

            Divider(color: Colors.grey[400]),
            Container(
                child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text('Description', style: TextStyle(fontSize: 20)),
            )),
            // Divider(color: Colors.grey[300], thickness: 6),
            Padding(
              padding:
                  const EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 8),
              child: ExpandableText(
                widget.document['productDescription'],
                expandText: 'read more',
                collapseText: 'show less',
                maxLines: 3,
                linkColor: Colors.blue,
                // style: TextStyle(color: Colors.grey),
              ),
            ),
            // Google banner ad
            Container(
                width: _smServices.myBigSquare.size.width.toDouble(),
                height: _smServices.myBigSquare.size.height.toDouble(),
                child: AdWidget(ad: _smServices.myBigSquare)),
            Divider(color: Colors.grey[400]),

            widget.document['productImages']?.isNotEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Text('Product/Service Images',
                            style: TextStyle(fontSize: 20)),
                      )),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          height: 550,
                          color: Colors.grey.shade300,
                          child: _loading
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Theme.of(context).primaryColor),
                                      ),
                                      SizedBox(height: 10),
                                      Text('Loading'),
                                    ],
                                  ),
                                )
                              : Stack(
                                  children: [
                                    CarouselSlider.builder(
                                      itemCount: widget
                                          .document['productImages'].length,
                                      itemBuilder: (BuildContext context,
                                              int itemIndex,
                                              int pageViewIndex) =>
                                          Container(
                                        child: Image.network(
                                            widget.document['productImages']
                                                [itemIndex],
                                            fit: BoxFit.cover),
                                      ),
                                      options: CarouselOptions(
                                        height: 550,
                                        aspectRatio: 16 / 9,
                                        viewportFraction: 0.8,
                                        initialPage: 0,
                                        enableInfiniteScroll: true,
                                        reverse: false,
                                        autoPlay: true,
                                        autoPlayInterval: Duration(seconds: 6),
                                        autoPlayAnimationDuration:
                                            Duration(milliseconds: 800),
                                        autoPlayCurve: Curves.fastOutSlowIn,
                                        enlargeCenterPage: true,
                                        // onPageChanged: callbackFunction,
                                        scrollDirection: Axis.horizontal,
                                      ),
                                    ),
                                    // Positioned(
                                    //   bottom: 0.0,
                                    //   child: Container(
                                    //     height: 80,
                                    //     width: MediaQuery.of(context).size.width,
                                    //     child: Padding(
                                    //       padding: const EdgeInsets.only(
                                    //           left: 12, right: 12),
                                    //       child: ListView.builder(
                                    //         scrollDirection: Axis.horizontal,
                                    //         itemCount: widget.document
                                    //             ['productImages']
                                    //             .length,
                                    //         itemBuilder:
                                    //             (BuildContext context, int i) {
                                    //           return InkWell(
                                    //             onTap: () {
                                    //               setState(() {
                                    //                 itemIndex = i;
                                    //               });
                                    //             },
                                    //             child: Container(
                                    //                 height: 80,
                                    //                 width: 80,
                                    //                 // color: Colors.white,
                                    //                 child: Image.network(
                                    //                     widget.document.data()[
                                    //                         'productImages'][i],
                                    //                     fit: BoxFit.cover),
                                    //                 decoration: BoxDecoration(
                                    //                   border: Border.all(
                                    //                       color: Theme.of(context)
                                    //                           .primaryColor),
                                    //                 )),
                                    //           );
                                    //         },
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                )),
                    ],
                  )
                : Container(),

            Divider(color: Colors.grey[400]),

            Padding(
              padding:
                  const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Shop Name: ${widget.document['seller']['shopName']}',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
                ],
              ),
            ),
            SizedBox(height: 10),
            // Text('Star rating ***'),
            // Text('Comment area'),
            SizedBox(height: 100)
          ],
        ),
      ),
    );
  }
}
