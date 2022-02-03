import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String productName, category, image, brand, shopName, sellerUid;
  final num price;
  final DocumentSnapshot document;

  Product({
    this.productName,
    this.category,
    this.price,
    this.image,
    this.brand,
    this.shopName,
    this.sellerUid,
    this.document,
  });
}

class AllProduct {
  final String productName, category, image, brand;
  final num price;
  final DocumentSnapshot document;

  AllProduct({
    this.productName,
    this.category,
    this.price,
    this.image,
    this.brand,
    this.document,
  });
}
