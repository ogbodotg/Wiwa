import 'dart:async';
import 'dart:io';

import 'package:wiwa_app/ahia_vendor/Providers/VendorProductProvider.dart';
import 'package:wiwa_app/widgets/newWidget/rippleButton.dart';
import 'package:wiwa_app/widgets/newWidget/title_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:galleryimage/galleryimage.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class ImagePickerWidget extends StatefulWidget {
  final String shopName;
  final String productName;

  const ImagePickerWidget({Key key, this.shopName, this.productName})
      : super(key: key);

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File _image;
  bool _uploading = false;
  final picker = ImagePicker();
  bool _loading = true;
  int _index = 0;
  int itemIndex = 0;

  @override
  void initState() {
    Timer(Duration(seconds: 2), () {
      setState(() {
        _loading = false;
      });
    });
    // imgRef = FirebaseFirestore.instance.collection(collectionPath)
    super.initState();
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _provider = Provider.of<VendorProductProvider>(context);

    Future<String> uploadFile() async {
      FirebaseStorage _storage = FirebaseStorage.instance;
      var timeStamp = Timestamp.now().millisecondsSinceEpoch;
      File file = File(_image.path);
      try {
        await _storage
            .ref(
                'productImages/${widget.shopName}/${widget.productName}/$timeStamp')
            .putFile(file);
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cancelled"),
          ),
        );
        // return 'cancelled';
      }
      String downloadURL = await _storage
          .ref(
              'productImages/${widget.shopName}/${widget.productName}/$timeStamp')
          .getDownloadURL();
      if (downloadURL != null) {
        setState(() {
          _image = null;
          _provider.getImages(downloadURL);
        });
      }
      return downloadURL;
    }

    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            elevation: 1,
            backgroundColor: Colors.white,
            title: Text(_provider.urlList.length > 0
                ? 'Upload Images'
                : 'Upload Image'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    if (_image != null)
                      Positioned(
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _image = null;
                              });
                            },
                          )),
                    Container(
                      height: 120,
                      width: MediaQuery.of(context).size.width,
                      child: FittedBox(
                        child: _image == null
                            ? Icon(
                                CupertinoIcons.photo_on_rectangle,
                                color: Colors.grey,
                              )
                            : Image.file(_image, fit: BoxFit.cover),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                // if (_provider.urlList.length > 0)
                //   Container(
                //       decoration: BoxDecoration(
                //         color: Colors.grey.shade300,
                //         borderRadius: BorderRadius.circular(4),
                //       ),
                //       child: GalleryImage(
                //         imageUrls: _provider.urlList,
                //       )),
                _provider.urlList.length == 0
                    ? Container(
                        height: 50,
                        child: Center(child: Text('No image uploaded')))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width,
                              height: 300,
                              color: Colors.grey.shade300,
                              child: _loading
                                  ? Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<
                                                    Color>(
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
                                          itemCount: _provider.urlList.length,
                                          itemBuilder: (BuildContext context,
                                                  int itemIndex,
                                                  int pageViewIndex) =>
                                              Container(
                                            child: Image.network(
                                                _provider.urlList[itemIndex],
                                                fit: BoxFit.cover),
                                          ),
                                          options: CarouselOptions(
                                            height: 300,
                                            aspectRatio: 16 / 9,
                                            viewportFraction: 0.8,
                                            initialPage: 0,
                                            enableInfiniteScroll: true,
                                            reverse: false,
                                            autoPlay: true,
                                            autoPlayInterval:
                                                Duration(seconds: 3),
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
                                        //     width: MediaQuery.of(context)
                                        //         .size
                                        //         .width,
                                        //     child: Padding(
                                        //       padding: const EdgeInsets.only(
                                        //           left: 12, right: 12),
                                        //       child: ListView.builder(
                                        //         scrollDirection:
                                        //             Axis.horizontal,
                                        //         itemCount:
                                        //             _provider.urlList.length,
                                        //         itemBuilder:
                                        //             (BuildContext context,
                                        //                 int i) {
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
                                        //                     _provider
                                        //                         .urlList[i],
                                        //                     fit: BoxFit.cover),
                                        //                 decoration:
                                        //                     BoxDecoration(
                                        //                   border: Border.all(
                                        //                       color: Theme.of(
                                        //                               context)
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
                      ),
                // : Column(
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     children: [
                //       Container(
                //           width: MediaQuery.of(context).size.width,
                //           height: 250,
                //           color: Colors.grey.shade300,
                //           child: _loading
                //               ? Center(
                //                   child: Column(
                //                     mainAxisSize: MainAxisSize.min,
                //                     children: [
                //                       CircularProgressIndicator(
                //                         valueColor: AlwaysStoppedAnimation<
                //                                 Color>(
                //                             Theme.of(context).primaryColor),
                //                       ),
                //                       SizedBox(height: 10),
                //                       Text('Loading'),
                //                     ],
                //                   ),
                //                 )
                //               : Stack(
                //                   children: [
                //                     Center(
                //                       child: PhotoView(
                //                         backgroundDecoration: BoxDecoration(
                //                             color: Colors.grey.shade300),
                //                         imageProvider: NetworkImage(
                //                             _provider.urlList[_index]),
                //                       ),
                //                     ),
                //                     Positioned(
                //                       bottom: 0.0,
                //                       child: Container(
                //                         height: 50,
                //                         width: MediaQuery.of(context)
                //                             .size
                //                             .width,
                //                         child: Padding(
                //                           padding: const EdgeInsets.only(
                //                               left: 12, right: 12),
                //                           child: ListView.builder(
                //                             scrollDirection:
                //                                 Axis.horizontal,
                //                             itemCount:
                //                                 _provider.urlList.length,
                //                             itemBuilder:
                //                                 (BuildContext context,
                //                                     int i) {
                //                               return InkWell(
                //                                 onTap: () {
                //                                   setState(() {
                //                                     _index = i;
                //                                   });
                //                                 },
                //                                 child: Container(
                //                                     height: 50,
                //                                     width: 50,
                //                                     // color: Colors.white,
                //                                     child: Image.network(
                //                                         _provider
                //                                             .urlList[i],
                //                                         fit: BoxFit.cover),
                //                                     decoration:
                //                                         BoxDecoration(
                //                                       border: Border.all(
                //                                           color: Theme.of(
                //                                                   context)
                //                                               .primaryColor),
                //                                     )),
                //                               );
                //                             },
                //                           ),
                //                         ),
                //                       ),
                //                     ),
                //                   ],
                //                 )),
                //     ],
                //   ),
                SizedBox(
                  height: 20,
                ),
                if (_image != null)
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        RippleButton(
                          onPressed: () {
                            setState(() {
                              _uploading = true;
                              uploadFile().then((url) => {
                                    if (url != null)
                                      {
                                        setState(() {
                                          _uploading = false;
                                        })
                                      }
                                  });
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
                                Icon(Icons.upload_file, color: Colors.white),
                                SizedBox(width: 10),
                                TitleText(
                                  'Upload',
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        RippleButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            // width: 50,
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
                      ],
                    ),
                  ),
                SizedBox(
                  height: 20,
                ),
                RippleButton(
                  onPressed: () {
                    getImage();
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                          'Select image',
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
                // Row(
                //   children: [
                //     Expanded(
                //       child: Container(
                //         color: Theme.of(context).primaryColor,
                //         height: 50,
                //         child: TextButton(
                //           onPressed: getImage,
                //           child: Text('Select Image',
                //               textAlign: TextAlign.center,
                //               style: TextStyle(color: Colors.white)),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                SizedBox(
                  height: 20,
                ),
                if (_uploading)
                  CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor))
              ],
            ),
          )
        ],
      ),
    );
  }
}
