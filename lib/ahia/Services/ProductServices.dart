import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProductServices {
  CollectionReference category =
      FirebaseFirestore.instance.collection('category');
  CollectionReference product =
      FirebaseFirestore.instance.collection('products');
  CollectionReference favourite =
      FirebaseFirestore.instance.collection('favourites');

  formatPrice(int price) {
    var formatedPrice = NumberFormat.compactCurrency(
      decimalDigits: 2,
      symbol:
          'NGN', // if you want to add currency symbol then pass that in this else leave it empty.
    ).format(price);
    return formatedPrice;
  }

  formatedPrice(double price) {
    var formated = NumberFormat('##,##,###,##0');
    var formatedPrice = formated.format(price);
    return formatedPrice;
  }
}
