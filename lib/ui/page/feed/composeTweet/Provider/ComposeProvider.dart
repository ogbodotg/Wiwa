import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ComposeProvider with ChangeNotifier {
  List<String> urlList = [];

  resetProvider() {
    this.urlList.clear();
    notifyListeners();
  }

  getImages(url) {
    this.urlList.add(url);
    notifyListeners();
  }

  // getData(data) {
  //   this.dataToFirestore = data;
  //   notifyListeners();
  // }

// upload multiple images to cloud storage and get dowload urls
  Future uploadProductImages({images, productName, shopName, productId}) async {
    firebase_storage.Reference ref;
    // CollectionReference _products =
    //     FirebaseFirestore.instance.collection('products');
    for (var img in images) {
      ref = firebase_storage.FirebaseStorage.instance.ref().child(
          'productImages/$shopName/$productName/${Path.basename(img.path)}');
      await ref.putFile(img).whenComplete(() async {
        await ref.getDownloadURL().then((value) {
          urlList.add(value);
        });
      });
    }

    notifyListeners();
    return;
  }

  // upload multiple images to cloud storage and get dowload urls
  // Future uploadImages(List _imgs) async {
  //   for (var img in _imgs) {
  //     UploadTask uploadTask = FirebaseStorage.instance
  //         .ref()
  //         .child('postImages/${Path.basename(img.path)}')
  //         .putFile(img);
  //     TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

  //     await taskSnapshot.ref.getDownloadURL().then((value) {
  //       setState(() {
  //         _urlList.add(value);
  //       });
  //     });
  //   }
  //   return _urlList;
  // }

  alertDialog({context, title, content}) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }
}
