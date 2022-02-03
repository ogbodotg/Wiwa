import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class VendorOrderProvider with ChangeNotifier {
  String status;
  filterOrder(status) {
    this.status = status;
    notifyListeners();
  }
}
