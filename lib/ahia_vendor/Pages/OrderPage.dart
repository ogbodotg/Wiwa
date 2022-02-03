import 'package:wiwa_app/ahia/Services/ProductServices.dart';
import 'package:wiwa_app/ahia_vendor/Providers/VendorOrderProvider.dart';
import 'package:wiwa_app/ahia_vendor/Services/OrderServices.dart';
import 'package:wiwa_app/ahia_vendor/Widgets/OrderSummaryCard.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  User user = FirebaseAuth.instance.currentUser;
  OrderServices _orderServices = OrderServices();
  ProductServices _productServices = ProductServices();

  int tag = 0;
  List<String> options = [
    'All Orders',
    'Ordered',
    'Accepted',
    'Picked Up',
    'On the way',
    'Delivered',
    'Rejected',
  ];

  @override
  Widget build(BuildContext context) {
    var _orderProvider = Provider.of<VendorOrderProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.purple),
        centerTitle: true,
        title: Text(
          'Customers Orders',
          style: TextStyle(color: Colors.black54),
        ),
      ),
      body: Column(
        children: [
          Container(
              height: 40,
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).primaryColor,
              child: Center(
                  child:
                      Text('Orders', style: TextStyle(color: Colors.white)))),
          Container(
            height: 56,
            width: MediaQuery.of(context).size.width,
            child: ChipsChoice<int>.single(
              value: tag,
              onChanged: (val) {
                if (val == 0) {
                  setState(() {
                    _orderProvider.status = null;
                  });
                }
                setState(() {
                  tag = val;
                  _orderProvider.status = options[val];
                  // _orderProvider.filterOrder(options[val]);
                });
              },
              choiceItems: C2Choice.listFrom<int, String>(
                source: options,
                value: (i, v) => i,
                label: (i, v) => v,
              ),
            ),
          ),
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: _orderServices.orders
                  .where('seller.sellerId', isEqualTo: user.uid)
                  .where('orderStatus',
                      isEqualTo: tag > 0 ? _orderProvider.status : null)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.data.size == 0) {
                  return Center(
                    child: Text(tag > 0
                        ? '${options[tag]} category is empty'
                        : 'You have no pending order from customers...'),
                  );
                }

                return Expanded(
                  child: new ListView(
                    padding: EdgeInsets.zero,
                    children:
                        snapshot.data.docs.map((DocumentSnapshot document) {
                      return new OrderSummaryCard(document);
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
