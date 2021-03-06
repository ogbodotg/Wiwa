import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OrderServices {
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');

  Future<DocumentReference> saveOrder(Map<String, dynamic> data) {
    var result = orders.add(data);
    return result;
  }

  Color statusColour(DocumentSnapshot document, context) {
    if (document['orderStatus'] == 'Accepted') {
      return Theme.of(context).primaryColor;
    }
    if (document['orderStatus'] == 'Rejected') {
      return Colors.red;
    }
    if (document['orderStatus'] == 'Picked Up') {
      return Colors.pink;
    }
    if (document['orderStatus'] == 'Delivered') {
      return Colors.purple;
    }
    if (document['orderStatus'] == 'On the way') {
      return Colors.green;
    }
    return Colors.orange;
  }

  Icon statusIcon(DocumentSnapshot document, context) {
    if (document['orderStatus'] == 'Accepted') {
      return Icon(Icons.check_circle, color: statusColour(document, context));
    }

    if (document['orderStatus'] == 'Rejected') {
      return Icon(Icons.cancel, color: statusColour(document, context));
    }
    if (document['orderStatus'] == 'Picked Up') {
      return Icon(Icons.wallet_giftcard,
          color: statusColour(document, context));
    }
    if (document['orderStatus'] == 'Delivered') {
      return Icon(Icons.shopping_bag, color: statusColour(document, context));
    }
    if (document['orderStatus'] == 'On the way') {
      return Icon(Icons.delivery_dining,
          color: statusColour(document, context));
    }
    return Icon(CupertinoIcons.square_list,
        color: statusColour(document, context));
  }

  String statusComment(document) {
    if (document['orderStatus'] == 'Picked Up') {
      return 'Your order has been Picked by ${document['deliveryBoy']['name']}';
    }
    if (document['orderStatus'] == 'On the way') {
      return 'Your order is on the way, being shipped by ${document['deliveryBoy']['name']}';
    }
    if (document['orderStatus'] == 'Delivered') {
      return 'Your order is marked (completed). Delivered by ${document['deliveryBoy']['name']}';
    }

    return 'Your order has been accepted by ${document['seller']['shopName']}. Delivery agent, ${document['deliveryBoy']['name']}, is on the way to pick it up';
  }
}
