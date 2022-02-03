import 'dart:async';
import 'dart:io';
import 'package:wiwa_app/ahia_vendor/Providers/VendorProductProvider.dart';
import 'package:wiwa_app/ahia_vendor/Services/FirebaseServices.dart';
import 'package:wiwa_app/ahia_vendor/Widgets/CategoryList.dart';
import 'package:wiwa_app/ahia_vendor/Widgets/ImagePickerWidget.dart';
import 'package:wiwa_app/widgets/newWidget/rippleButton.dart';
import 'package:wiwa_app/widgets/newWidget/title_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:galleryimage/galleryimage.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as Path;

class AddNewProduct extends StatefulWidget {
  static const String id = 'addnew-product';

  @override
  _AddNewProductState createState() => _AddNewProductState();
}

class _AddNewProductState extends State<AddNewProduct> {
  User user = FirebaseAuth.instance.currentUser;
  FirebaseServices _services = FirebaseServices();
  DocumentSnapshot doc;
  firebase_storage.Reference ref;

  final _formKey = GlobalKey<FormState>();
  List<String> _collections = [
    'Featured Products',
    'Best Selling',
    'Recently Added',
    'Services',
  ];
  String dropdownValue;
  String _shopName;

  var _categoryTextController = TextEditingController();
  var _subCategoryTextController = TextEditingController();
  var _comparedPriceTextController = TextEditingController();
  var _brandTextController = TextEditingController();
  var _productNameTextController = TextEditingController();
  var _lowStockQtyTextController = TextEditingController();
  var _stockQtyTextController = TextEditingController();
  var timeStamp = DateTime.now().millisecondsSinceEpoch;

  File _image;
  bool _visible = false;
  bool _track = false;
  String productName;
  String productDescription;
  double price;
  double comparePrice;
  double tax;
  int stockQuantity;
  String productId;
// list to store multiple images
  List<File> images = [];
  final picker = ImagePicker();

  bool _loading = true;
  int _index = 0;
  int itemIndex = 0;

  Future<void> getVendorDetails() async {
    _services.vendors.doc(user.uid).get().then((DocumentSnapshot document) {
      if (document.exists) {
        setState(() {
          doc = document;
          _shopName = doc['shopName'];
        });
      }
    });
  }

  @override
  void initState() {
    setState(() {
      getVendorDetails();
      productId = timeStamp.toString();
    });
    Timer(Duration(seconds: 2), () {
      setState(() {
        _loading = false;
      });
    });
    // imgRef = FirebaseFirestore.instance.collection(collectionPath)
    super.initState();
  }

// function to select multiple images
  chooseImages() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      images.add(File(pickedFile?.path));
    });
    if (pickedFile.path == null) retrieveLostData();
  }

  Future<void> retrieveLostData() async {
    final LostData response = await picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        images.add(File(response.file.path));
      });
    } else {
      print(response.file);
    }
  }

// gridview to display picked multiple images
  Widget buildGridView() {
    print('My images length is ${images.length}');

    return GridView.builder(
      shrinkWrap: true,
      itemCount: images.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.all(3),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: FileImage(images[index]), fit: BoxFit.cover)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _provider = Provider.of<VendorProductProvider>(context);
    print('My urlList is ${_provider.urlList.length}');

    showConfirmDialog() {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
                child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Confirm!',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Are you sure you want to save this product/service? (Saved products/services are located under your "Unpublished" tab in "My Products/Services" page)',
                    maxLines: 3,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ListTile(
                      leading: Image.network(_provider.productImageUrl,
                          fit: BoxFit.cover),
                      title: _productNameTextController.text != null
                          ? Text(
                              _productNameTextController.text,
                              maxLines: 1,
                            )
                          : SizedBox(),
                      subtitle: Text(
                        'NGN$price',
                        maxLines: 1,
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        RippleButton(
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey,
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
                                Icon(Icons.cancel, color: Colors.white),
                                SizedBox(width: 10),
                                TitleText(
                                  'Cancel',
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Expanded(
                        //     child: FlatButton(
                        //   onPressed: () {
                        //     Navigator.pop(context);
                        //   },
                        //   color: Colors.red,
                        //   child: Text(
                        //     'Cancel',
                        //     textAlign: TextAlign.center,
                        //     style: TextStyle(color: Colors.white),
                        //   ),
                        // )),
                        SizedBox(
                          width: 20,
                        ),
                        RippleButton(
                          onPressed: () async {
                            Navigator.pop(context);

                            _provider.saveProductToDb(
                              context: context,
                              price: price,
                              comparedPrice: comparePrice,
                              brand: _brandTextController.text,
                              collection: dropdownValue,
                              productDescription: productDescription,
                              lowStockQuanity:
                                  int.parse(_lowStockQtyTextController.text),
                              stockQuantity:
                                  int.parse(_stockQtyTextController.text),
                              // tax: tax,
                              productName: productName,
                              productId: productId,
                              shopName: _shopName,
                              // images: _provider.urlList,
                            );

                            setState(() {
                              _formKey.currentState.reset();
                              _comparedPriceTextController.clear();
                              dropdownValue = null;
                              _subCategoryTextController.clear();
                              _categoryTextController.clear();
                              _brandTextController.clear();
                              _productNameTextController.clear();
                              _track = false;
                              _image = null;
                              _visible = false;
                              images.clear();
                              productId = null;
                              // urlList.clear();
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
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
                                Icon(Icons.save, color: Colors.white),
                                SizedBox(width: 10),
                                TitleText(
                                  'Yes, save',
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Expanded(
                        //     child: FlatButton(
                        //   onPressed: () {
                        //     Navigator.pop(context);

                        //     _provider.saveProductToDb(
                        //       context: context,
                        //       price: price,
                        //       comparedPrice: comparePrice,
                        //       brand: _brandTextController.text,
                        //       collection: dropdownValue,
                        //       productDescription: productDescription,
                        //       lowStockQuanity:
                        //           int.parse(_lowStockQtyTextController.text),
                        //       stockQuantity:
                        //           int.parse(_stockQtyTextController.text),
                        //       // tax: tax,
                        //       productName: productName,
                        //       productId: productId,
                        //       shopName: _shopName,
                        //       // images: _provider.urlList,
                        //     );

                        //     setState(() {
                        //       _formKey.currentState.reset();
                        //       _comparedPriceTextController.clear();
                        //       dropdownValue = null;
                        //       _subCategoryTextController.clear();
                        //       _categoryTextController.clear();
                        //       _brandTextController.clear();
                        //       _productNameTextController.clear();
                        //       _track = false;
                        //       _image = null;
                        //       _visible = false;
                        //       images.clear();
                        //       // urlList.clear();
                        //     });
                        //   },
                        //   color: Colors.purple,
                        //   child: Text(
                        //     'Yes, save',
                        //     textAlign: TextAlign.center,
                        //     style: TextStyle(color: Colors.white),
                        //   ),
                        // )),
                      ],
                    ),
                  )
                ],
              ),
            ));
          });
    }

    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        // appBar: AppBar(
        //   iconTheme: IconThemeData(color: Colors.white),
        // ),
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.purple),
          centerTitle: true,
          title: Text(
            'Add New Product/Service',
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Material(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Container(
                          child: Text('Products/Services / Add'),
                        ),
                      ),
                      RippleButton(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            if (_image != null) {
                              EasyLoading.show(status: 'Saving...');
                              _provider
                                  .uploadProductImage(
                                      _image.path, productName, _shopName)
                                  .then((url) {
                                if (url != null) {
                                  // if (images.isNotEmpty) {
                                  //   uploadProductImages(
                                  //     images: images,
                                  //     productName: productName,
                                  //     shopName: _shopName,

                                  //     // productId: productId,
                                  //   );
                                  // }
                                  EasyLoading.dismiss();
                                  showConfirmDialog();
                                } else {
                                  _provider.alertDialog(
                                    context: context,
                                    title: 'Image Upload',
                                    content: 'image upload failed',
                                  );
                                }
                              });
                            } else {
                              _provider.alertDialog(
                                context: context,
                                title: 'Image',
                                content: 'Image not selected',
                              );
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
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
                              Icon(Icons.save,
                                  color: Theme.of(context).primaryColor),
                              SizedBox(width: 10),
                              TitleText(
                                'Save',
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // FlatButton.icon(
                      //   color: Theme.of(context).primaryColor,
                      //   onPressed: () {
                      //     if (_formKey.currentState.validate()) {
                      //       if (_image != null) {
                      //         EasyLoading.show(status: 'Saving...');
                      //         _provider
                      //             .uploadProductImage(
                      //                 _image.path, productName, _shopName)
                      //             .then((url) {
                      //           if (url != null) {
                      //             // if (images.isNotEmpty) {
                      //             //   uploadProductImages(
                      //             //     images: images,
                      //             //     productName: productName,
                      //             //     shopName: _shopName,

                      //             //     // productId: productId,
                      //             //   );
                      //             // }
                      //             EasyLoading.dismiss();
                      //             showConfirmDialog();
                      //           } else {
                      //             _provider.alertDialog(
                      //               context: context,
                      //               title: 'Image Upload',
                      //               content: 'image upload failed',
                      //             );
                      //           }
                      //         });
                      //       } else {
                      //         _provider.alertDialog(
                      //           context: context,
                      //           title: 'Image',
                      //           content: 'Image not selected',
                      //         );
                      //       }
                      //     }
                      //   },
                      //   icon: Icon(Icons.add, color: Colors.white),
                      //   label:
                      //       Text('Save', style: TextStyle(color: Colors.white)),
                      // ),
                    ],
                  ),
                ),
              ),
              TabBar(
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.black54,
                tabs: [
                  Tab(
                    text: 'General',
                  ),
                  Tab(
                    text: 'Inventory',
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: TabBarView(
                      children: [
                        ListView(children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _productNameTextController,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Enter product/service name';
                                    }
                                    setState(() {
                                      productName = value;
                                    });
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Product/Service Name',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 5,
                                  maxLength: 500,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Enter product/service description';
                                    }
                                    setState(() {
                                      productDescription = value;
                                    });
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Description',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      _provider.getProductImage().then((image) {
                                        setState(() {
                                          _image = image;
                                        });
                                      });
                                    },
                                    child: SizedBox(
                                      width: 250,
                                      height: 250,
                                      child: Card(
                                        child: Center(
                                            child: _image == null
                                                ? Text('Select Image')
                                                : Image.file(_image,
                                                    fit: BoxFit.cover)),
                                      ),
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Enter price';
                                    }
                                    setState(() {
                                      price = double.parse(value);
                                    });
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Price NGN',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  controller: _comparedPriceTextController,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      setState(() {
                                        value = (0).toString();
                                      });
                                    }
                                    // if (price > double.parse(value)) {
                                    //   return 'Compared price should be higher than actual price';
                                    // }
                                    setState(() {
                                      comparePrice = double.parse(value);
                                    });

                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Compared price should be higher than your selling price',
                                    labelText: 'Compared Price NGN',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey[300],
                                      ),
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
                                TextFormField(
                                  controller: _brandTextController,
                                  decoration: InputDecoration(
                                    labelText: 'Brand',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey[300],
                                      ),
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
                                                return 'Please select category';
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
                                      IconButton(
                                        icon: Icon(Icons.edit_outlined),
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
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
                                                  return 'Please select sub-category';
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
                                // TextFormField(
                                //   validator: (value) {
                                //     // if (value.isEmpty) {
                                //     //   return 'Enter VAT %';
                                //     // }
                                //     setState(() {
                                //       tax = double.parse(value);
                                //     });
                                //     return null;
                                //   },
                                //   keyboardType: TextInputType.number,
                                //   decoration: InputDecoration(
                                //     hintText: 'Add VAT for item/service',
                                //     labelText: 'VAT %',
                                //     labelStyle: TextStyle(color: Colors.grey),
                                //     enabledBorder: UnderlineInputBorder(
                                //       borderSide: BorderSide(
                                //         color: Colors.grey[300],
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                // FlatButton(
                                //     color: Theme.of(context).primaryColor,
                                //     onPressed: chooseImages,
                                //     child: Text("Add more product images",
                                //         style: TextStyle(color: Colors.white))),

                                // buildGridView(),
                                SizedBox(
                                  height: 20,
                                ),
                                // Container(
                                //     width: MediaQuery.of(context).size.width,
                                //     decoration: BoxDecoration(
                                //       color: Colors.grey.shade300,
                                //       borderRadius: BorderRadius.circular(4),
                                //     ),
                                //     child: _provider.urlList.length == 0
                                //         ? Container(
                                //             height: 50,
                                //             child: Center(
                                //                 child:
                                //                     Text('No image uploaded')))
                                //         : GalleryImage(
                                //             imageUrls: _provider.urlList,
                                //           )),
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
                                              height: 300,
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
                                                            height: 300,
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
                                                        // Positioned(
                                                        //   bottom: 0.0,
                                                        //   child: Container(
                                                        //     height: 80,
                                                        //     width:
                                                        //         MediaQuery.of(
                                                        //                 context)
                                                        //             .size
                                                        //             .width,
                                                        //     child: Padding(
                                                        //       padding:
                                                        //           const EdgeInsets
                                                        //                   .only(
                                                        //               left: 12,
                                                        //               right:
                                                        //                   12),
                                                        //       child: ListView
                                                        //           .builder(
                                                        //         scrollDirection:
                                                        //             Axis.horizontal,
                                                        //         itemCount:
                                                        //             _provider
                                                        //                 .urlList
                                                        //                 .length,
                                                        //         itemBuilder:
                                                        //             (BuildContext
                                                        //                     context,
                                                        //                 int i) {
                                                        //           return InkWell(
                                                        //             onTap: () {
                                                        //               setState(
                                                        //                   () {
                                                        //                 itemIndex =
                                                        //                     i;
                                                        //               });
                                                        //             },
                                                        //             child: Container(
                                                        //                 height: 80,
                                                        //                 width: 80,
                                                        //                 // color: Colors.white,
                                                        //                 child: Image.network(_provider.urlList[i], fit: BoxFit.cover),
                                                        //                 decoration: BoxDecoration(
                                                        //                   border:
                                                        //                       Border.all(color: Theme.of(context).primaryColor),
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
                                      ),

                                SizedBox(
                                  height: 20,
                                ),

                                RippleButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return ImagePickerWidget(
                                            shopName: _shopName,
                                            productName:
                                                _productNameTextController.text,
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

                                // InkWell(
                                //   onTap: () {
                                //     showDialog(
                                //         context: context,
                                //         builder: (BuildContext context) {
                                //           return ImagePickerWidget(
                                //             shopName: _shopName,
                                //             productName:
                                //                 _productNameTextController.text,
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
                              ],
                            ),
                          )
                        ]),
                        SingleChildScrollView(
                          child: Column(children: [
                            SwitchListTile(
                              title: Column(
                                children: [
                                  Text(
                                    'Track Inventory',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('(If posting a service enter 0 (zero))',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      )),
                                ],
                              ),
                              activeColor: Theme.of(context).primaryColor,
                              subtitle: Column(
                                children: [
                                  Text(
                                    'Switch ON to track Inventory',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '(Enter 0 (zero) if you are posting a service)',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                              value: _track,
                              onChanged: (selected) {
                                setState(() {
                                  _track = !_track;
                                });
                              },
                            ),
                            Visibility(
                              visible: _track,
                              child: SizedBox(
                                height: 300,
                                width: double.infinity,
                                child: Card(
                                  elevation: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: _stockQtyTextController,
                                          // validator: (value) {
                                          //   if (_track) {
                                          //     if (value.isEmpty) {
                                          //       return 'Enter stock quantity';
                                          //     }
                                          //     setState(() {
                                          //       stockQuantity =
                                          //           int.parse(value);
                                          //     });
                                          //   }
                                          //   return null;
                                          // },
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: 'Inventory Quanity',
                                            labelStyle:
                                                TextStyle(color: Colors.grey),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.grey[300],
                                              ),
                                            ),
                                          ),
                                        ),
                                        TextFormField(
                                          controller:
                                              _lowStockQtyTextController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText:
                                                'Inventory low stock quanity',
                                            labelStyle:
                                                TextStyle(color: Colors.grey),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.grey[300],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Future uploadProductImages() async {
  //   for (var img in images) {
  //     ref = firebase_storage.FirebaseStorage.instance
  //         .ref()
  //         .child('ProductImages/$productName/${Path.basename(img.path)}');
  //     await ref.putFile(img).whenComplete(() async {
  //       await ref.getDownloadURL().then((value) {
  //         productImages = value;
  //       });
  //     });
  //   }
  // }
}
