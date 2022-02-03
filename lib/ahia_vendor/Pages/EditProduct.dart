import 'dart:io';

import 'package:wiwa_app/ahia_vendor/Providers/VendorProductProvider.dart';
import 'package:wiwa_app/ahia_vendor/Services/FirebaseServices.dart';
import 'package:wiwa_app/ahia_vendor/Widgets/CategoryList.dart';
import 'package:wiwa_app/ahia_vendor/Widgets/ImagePickerWidget.dart';
import 'package:wiwa_app/widgets/newWidget/rippleButton.dart';
import 'package:wiwa_app/widgets/newWidget/title_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class EditViewProduct extends StatefulWidget {
  final String productId;
  EditViewProduct({this.productId});
  @override
  _EditViewProductState createState() => _EditViewProductState();
}

class _EditViewProductState extends State<EditViewProduct> {
  FirebaseServices _services = FirebaseServices();
  DocumentSnapshot doc;
  final _formKey = GlobalKey<FormState>();
  List<File> images = [];
  final picker = ImagePicker();

  List<String> _collections = [
    'Featured Products',
    'Best Selling',
    'Recently Added',
    'Services',
  ];
  String dropdownValue;

  var _brandText = TextEditingController();
  var _productNameText = TextEditingController();
  var _priceText = TextEditingController();
  var _comparedPriceText = TextEditingController();
  var _productDescriptionText = TextEditingController();
  var _categoryTextController = TextEditingController();
  var _subCategoryTextController = TextEditingController();
  var _stockTextController = TextEditingController();
  var _lowStockTextController = TextEditingController();
  var _vatTextController = TextEditingController();
  var _shopName;

  double discount;
  String image;
  File _image;
  bool _visible = false;
  bool _editing = true;
  bool _loading = true;
  int itemIndex = 0;
  // List<String> urlList = [];

  @override
  void initState() {
    getProductDetails();
    super.initState();
  }

  Future<void> getProductDetails() async {
    _services.products
        .doc(widget.productId)
        .get()
        .then((DocumentSnapshot document) {
      if (document.exists) {
        setState(() {
          doc = document;
          _shopName = document['seller']['shopName'];
          _brandText.text = document['brand'];
          _productNameText.text = document['productName'];
          _productDescriptionText.text = document['productDescription'];
          _categoryTextController.text = document['category']['mainCategory'];
          _subCategoryTextController.text = document['category']['subCategory'];

          _priceText.text = document['price'].toString();
          _comparedPriceText.text = document['comparedPrice'].toString();
          var difference = (double.parse(_comparedPriceText.text) -
              double.parse(_priceText.text));
          discount = (difference / double.parse(_priceText.text)) * 100;
          image = document['productImage'];
          // urlList.addAll(document['productImages']);
          dropdownValue = document['collection'];
          _stockTextController.text = document['stockQuantity'].toString();
          _lowStockTextController.text =
              document['lowStockQuantity'].toString();
          _vatTextController.text = document['tax'].toString() ?? '';
        });
      }
    });
  }

  // select multiple images

//   chooseImages() async {
//     final pickedFile = await picker.getImage(source: ImageSource.gallery);
//     setState(() {
//       images.add(File(pickedFile?.path));
//     });
//     if (pickedFile.path == null) retrieveLostData();
//   }

//   Future<void> retrieveLostData() async {
//     final LostData response = await picker.getLostData();
//     if (response.isEmpty) {
//       return;
//     }
//     if (response.file != null) {
//       setState(() {
//         images.add(File(response.file.path));
//       });
//     } else {
//       print(response.file);
//     }
//   }

// // display multiple images in gridview
//   Widget buildGridView() {
//     return GridView.builder(
//       shrinkWrap: true,
//       itemCount: images.length,
//       gridDelegate:
//           SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
//       itemBuilder: (context, index) {
//         return
//             // index == 0
//             //     ? Center(
//             //         child: IconButton(
//             //           icon: Icon(Icons.add),
//             //           onPressed: () {
//             //             chooseImages();
//             //           },
//             //         ),
//             //       )
//             //     :
//             Container(
//           margin: EdgeInsets.all(3),
//           decoration: BoxDecoration(
//               image: DecorationImage(
//                   image: FileImage(images[index]), fit: BoxFit.cover)),
//         );
//       },
//     );
//   }

// upload multiple images to cloud storage and retrieve download urls
  // Future uploadProductImages(images, productName) async {
  //   firebase_storage.Reference ref;
  //   CollectionReference _productImages =
  //       FirebaseFirestore.instance.collection('productImages');
  //   for (var img in images) {
  //     ref = firebase_storage.FirebaseStorage.instance.ref().child(
  //         'ProductImages/${_shopName}/$productName/${Path.basename(img.path)}');
  //     await ref.putFile(img).whenComplete(() async {
  //       await ref.getDownloadURL().then((value) {
  //         _productImages.add({
  //           'productImages': value,
  //           'productId': widget.productId,
  //         });
  //       });
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var _provider = Provider.of<VendorProductProvider>(context);

    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.purple),
          actions: [
            FlatButton(
                onPressed: () {
                  setState(() {
                    _editing = false;
                  });
                },
                child: Text('Edit', style: TextStyle(color: Colors.black)))
          ],
        ),
        bottomSheet: Container(
          height: 60,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                      color: Colors.black54,
                      child: Center(
                          child: Text('Cancel',
                              style: TextStyle(color: Colors.white)))),
                ),
              ),
              Expanded(
                child: AbsorbPointer(
                  absorbing: _editing,
                  child: InkWell(
                    onTap: () {
                      if (_formKey.currentState.validate()) {
                        EasyLoading.show(status: 'Saving...');
                        if (_image != null) {
                          _provider
                              .uploadProductImage(
                                  _image.path, _productNameText.text, _shopName)
                              .then((url) {
                            if (url != null) {
                              EasyLoading.dismiss();
                              // if (images.isNotEmpty) {
                              //   // _provider.uploadProductImages(
                              //   //     images, _productNameText.text, _shopName);
                              // }

                              _provider.updateProduct(
                                context: context,
                                productName: _productNameText.text,
                                productDescription:
                                    _productDescriptionText.text,
                                tax: double.parse(_vatTextController.text),
                                stockQuantity:
                                    int.parse(_stockTextController.text),
                                lowStockQuanity:
                                    int.parse(_lowStockTextController.text),
                                price: double.parse(_priceText.text),
                                comparedPrice:
                                    double.parse(_comparedPriceText.text),
                                brand: _brandText.text,
                                collection: dropdownValue,
                                category: _categoryTextController.text,
                                subCategory: _subCategoryTextController.text,
                                productId: widget.productId,
                                images: _provider.urlList,
                                image: url,
                              );
                            }
                          });
                        } else {
                          _provider.updateProduct(
                            context: context,
                            productName: _productNameText.text,
                            productDescription: _productDescriptionText.text,
                            tax: double.parse(_vatTextController.text),
                            stockQuantity: int.parse(_stockTextController.text),
                            lowStockQuanity:
                                int.parse(_lowStockTextController.text),
                            price: double.parse(_priceText.text),
                            comparedPrice:
                                double.parse(_comparedPriceText.text),
                            brand: _brandText.text,
                            collection: dropdownValue,
                            category: _categoryTextController.text,
                            subCategory: _subCategoryTextController.text,
                            productId: widget.productId,
                            images: _provider.urlList,
                            image: image,
                          );
                          EasyLoading.dismiss();
                        }
                        _provider.resetProvider();
                      }
                    },
                    child: Container(
                        color: Theme.of(context).primaryColor,
                        child: Center(
                            child: Text('Save',
                                style: TextStyle(color: Colors.white)))),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: doc == null
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: ListView(
                      children: [
                        AbsorbPointer(
                          absorbing: _editing,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width * .5,
                                  height: 40,
                                  child: TextFormField(
                                    controller: _brandText,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.only(left: 10, right: 10),
                                      hintText: 'Brand',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(.1),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      border: InputBorder.none,
                                    ),
                                    controller: _productNameText,
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 200,
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.zero,
                                          border: InputBorder.none,
                                          prefixText: '\NGN',
                                          prefixStyle: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        controller: _priceText,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Container(
                                      width: 180,
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.zero,
                                          border: InputBorder.none,
                                          prefixText: '\NGN',
                                          prefixStyle: TextStyle(
                                              decoration:
                                                  TextDecoration.lineThrough),
                                        ),
                                        controller: _comparedPriceText,
                                        style: TextStyle(
                                            fontSize: 14,
                                            decoration:
                                                TextDecoration.lineThrough),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        color: Colors.red,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8, right: 8.0),
                                        child: Text(
                                            '${discount.toStringAsFixed(0)}% OFF',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    )
                                  ],
                                ),
                                Text('VAT inclusive',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                                InkWell(
                                  onTap: () {
                                    _provider.getProductImage().then((image) {
                                      setState(() {
                                        _image = image;
                                      });
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: _image != null
                                        ? Image.file(_image, height: 300)
                                        : Image.network(image, height: 400),
                                  ),
                                ),
                                Text('Description',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: TextFormField(
                                    maxLines: null,
                                    controller: _productDescriptionText,
                                    keyboardType: TextInputType.multiline,
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20.0, bottom: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Category',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 16),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: AbsorbPointer(
                                          absorbing: true,
                                          child: TextFormField(
                                            controller: _categoryTextController,
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Please select product category';
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'not selected',
                                              labelStyle:
                                                  TextStyle(color: Colors.grey),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: _editing ? false : true,
                                        child: IconButton(
                                          icon: Icon(Icons.edit_outlined),
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return CategoryList();
                                                }).whenComplete(() {
                                              setState(() {
                                                _categoryTextController.text =
                                                    _provider.selectedCategory;
                                                _visible = true;
                                              });
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: _visible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 20.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Sub-Category',
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 16),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: AbsorbPointer(
                                            absorbing: true,
                                            child: TextFormField(
                                              controller:
                                                  _subCategoryTextController,
                                              validator: (value) {
                                                if (value.isEmpty) {
                                                  return 'Please select product sub-category';
                                                }
                                                return null;
                                              },
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Pls select Category first to avoid error',
                                                labelStyle: TextStyle(
                                                    color: Colors.grey),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.grey[300],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit_outlined),
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return SubCategoryList();
                                                }).whenComplete(() {
                                              setState(() {
                                                _subCategoryTextController
                                                        .text =
                                                    _provider
                                                        .selectedSubCategory;
                                              });
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Row(children: [
                                    Text(
                                      'Collection',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    SizedBox(width: 10),
                                    DropdownButton(
                                      hint: Text('Select Collection'),
                                      value: dropdownValue,
                                      icon: Icon(Icons.arrow_drop_down),
                                      onChanged: (String value) {
                                        setState(() {
                                          dropdownValue = value;
                                        });
                                      },
                                      items: _collections
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ]),
                                ),
                                Row(
                                  children: [
                                    Text('Stock : '),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _stockTextController,
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text('Low Stock : '),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _lowStockTextController,
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text('VAT %: '),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _vatTextController,
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 60),
                                // FlatButton(
                                //     color: Theme.of(context).primaryColor,
                                //     onPressed: chooseImages,
                                //     child: Text("Add more product images",
                                //         style: TextStyle(color: Colors.white))),
                                // buildGridView(),
                                // Divider(),
                                // urlList.isEmpty
                                //     ? Container(
                                //         height: 50,
                                //         child: Center(
                                //             child: Text('No image uploaded')))
                                //     : Column(
                                //         mainAxisAlignment:
                                //             MainAxisAlignment.start,
                                //         children: [
                                //           Container(
                                //               width: MediaQuery.of(context)
                                //                   .size
                                //                   .width,
                                //               height: 150,
                                //               color: Colors.grey.shade300,
                                //               child: _loading
                                //                   ? Center(
                                //                       child: Column(
                                //                         mainAxisSize:
                                //                             MainAxisSize.min,
                                //                         children: [
                                //                           CircularProgressIndicator(
                                //                             valueColor:
                                //                                 AlwaysStoppedAnimation<
                                //                                     Color>(Theme.of(
                                //                                         context)
                                //                                     .primaryColor),
                                //                           ),
                                //                           SizedBox(height: 10),
                                //                           Text('Loading'),
                                //                         ],
                                //                       ),
                                //                     )
                                //                   : Stack(
                                //                       children: [
                                //                         CarouselSlider.builder(
                                //                           itemCount:
                                //                               urlList.length,
                                //                           itemBuilder: (BuildContext
                                //                                       context,
                                //                                   int itemIndex,
                                //                                   int pageViewIndex) =>
                                //                               Container(
                                //                             child: Image.network(
                                //                                 urlList[
                                //                                     itemIndex],
                                //                                 fit: BoxFit
                                //                                     .cover),
                                //                           ),
                                //                           options:
                                //                               CarouselOptions(
                                //                             height: 150,
                                //                             aspectRatio: 16 / 9,
                                //                             viewportFraction:
                                //                                 0.8,
                                //                             initialPage: 0,
                                //                             enableInfiniteScroll:
                                //                                 true,
                                //                             reverse: false,
                                //                             autoPlay: true,
                                //                             autoPlayInterval:
                                //                                 Duration(
                                //                                     seconds: 3),
                                //                             autoPlayAnimationDuration:
                                //                                 Duration(
                                //                                     milliseconds:
                                //                                         800),
                                //                             autoPlayCurve: Curves
                                //                                 .fastOutSlowIn,
                                //                             enlargeCenterPage:
                                //                                 true,
                                //                             // onPageChanged: callbackFunction,
                                //                             scrollDirection:
                                //                                 Axis.horizontal,
                                //                           ),
                                //                         ),
                                //                       ],
                                //                     )),
                                //         ],
                                //       ),

                                SizedBox(
                                  height: 20,
                                ),
                                Divider(),
                                _provider.urlList.length == 0
                                    ? Container(
                                        height: 50,
                                        child: Center(
                                            child: Text('No image uploaded')))
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 200,
                                              color: Colors.grey.shade300,
                                              child: _loading
                                                  ? Center(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          CircularProgressIndicator(
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                    Color>(Theme.of(
                                                                        context)
                                                                    .primaryColor),
                                                          ),
                                                          SizedBox(height: 10),
                                                          Text('Loading'),
                                                        ],
                                                      ),
                                                    )
                                                  : Stack(
                                                      children: [
                                                        CarouselSlider.builder(
                                                          itemCount: _provider
                                                              .urlList.length,
                                                          itemBuilder: (BuildContext
                                                                      context,
                                                                  int itemIndex,
                                                                  int pageViewIndex) =>
                                                              Container(
                                                            child: Image.network(
                                                                _provider
                                                                        .urlList[
                                                                    itemIndex],
                                                                fit: BoxFit
                                                                    .cover),
                                                          ),
                                                          options:
                                                              CarouselOptions(
                                                            height: 200,
                                                            aspectRatio: 16 / 9,
                                                            viewportFraction:
                                                                0.8,
                                                            initialPage: 0,
                                                            enableInfiniteScroll:
                                                                true,
                                                            reverse: false,
                                                            autoPlay: true,
                                                            autoPlayInterval:
                                                                Duration(
                                                                    seconds: 3),
                                                            autoPlayAnimationDuration:
                                                                Duration(
                                                                    milliseconds:
                                                                        800),
                                                            autoPlayCurve: Curves
                                                                .fastOutSlowIn,
                                                            enlargeCenterPage:
                                                                true,
                                                            // onPageChanged: callbackFunction,
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                          ),
                                                        ),
                                                      ],
                                                    )),
                                        ],
                                      ),
                                Center(
                                  child: RippleButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ImagePickerWidget(
                                              shopName: _shopName,
                                              productName:
                                                  _productNameText.text,
                                            );
                                          });
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color: Color(0xffeeeeee),
                                            blurRadius: 15,
                                            offset: Offset(5, 5),
                                          ),
                                        ],
                                      ),
                                      child: Wrap(
                                        children: <Widget>[
                                          Icon(Icons.photo),
                                          SizedBox(width: 10),
                                          TitleText(
                                            'Add more images',
                                            color: Colors.black54,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // InkWell(
                                //   onTap: () {
                                //     showDialog(
                                //         context: context,
                                //         builder: (BuildContext context) {
                                //           return ImagePickerWidget(
                                //             shopName: _shopName,
                                //             productName: _productNameText.text,
                                //           );
                                //         });
                                //   },
                                //   child: Padding(
                                //     padding: const EdgeInsets.all(50),
                                //     child: Row(
                                //       children: [
                                //         Expanded(
                                //           child: Container(
                                //               height: 50,
                                //               color: Theme.of(context)
                                //                   .primaryColor,
                                //               child: Padding(
                                //                 padding: const EdgeInsets.only(
                                //                     top: 10),
                                //                 child: Text("Add more images",
                                //                     textAlign: TextAlign.center,
                                //                     style: TextStyle(
                                //                       color: Colors.white,
                                //                       fontWeight:
                                //                           FontWeight.bold,
                                //                       fontSize: 16,
                                //                     )),
                                //               )),
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // ),
                                SizedBox(height: 60),
                              ]),
                        )
                      ],
                    ))));
  }
}
