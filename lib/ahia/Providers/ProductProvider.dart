import 'package:wiwa_app/ahia/Services/ProductServices.dart';
import 'package:wiwa_app/ahia/Services/StoreServices.dart';
import 'package:wiwa_app/ahia/Services/UserServices.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class ProductProvider with ChangeNotifier {
  ProductServices _productServices = ProductServices();

  String selectedProduct;
  String selectedProductId;
  DocumentSnapshot productDetails;

  getSelectedProduct(productDetails) {
    this.productDetails = productDetails;
    notifyListeners();
  }
}
