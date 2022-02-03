import 'package:wiwa_app/ahia/Services/ProductServices.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

ProductServices _services = ProductServices();
User user = FirebaseAuth.instance.currentUser;

class SaveForLater extends StatelessWidget {
  final DocumentSnapshot document;
  bool productBookmarked = false;

  SaveForLater(this.document);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        checkProductBookmark(document['productId']);

        if (!productBookmarked) {
          EasyLoading.show(status: 'Adding to Wish List');
          addToFavourite(document['productId']).then((value) {
            ScaffoldMessenger.maybeOf(context).showSnackBar(
              SnackBar(content: Text("Item bookmarked successfully")),
            );
            EasyLoading.showSuccess('');
          });
        } else {
          ScaffoldMessenger.maybeOf(context).showSnackBar(
            SnackBar(content: Text("Item already in your bookmark")),
          );
        }
      },
      child: Container(
        height: 80,
        color: Colors.red,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.bookmark, color: Colors.white),
                SizedBox(width: 10),
                Text('Add to Wish List',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> addToFavourite(productId) {
    return _services.favourite
        .doc(user.uid)
        .collection('products')
        .doc(productId)
        .set(
          document.data(),
        );
  }

  // Check if product exists in favourite product
  checkProductBookmark(productId) async {
    ProductServices _services = ProductServices();
    _services.favourite
        .doc(user.uid)
        .collection('products')
        .doc(productId)
        .get()
        .then((DocumentSnapshot document) {
      if (document.exists) {
        productBookmarked = true;
      }
    });
  }
}
