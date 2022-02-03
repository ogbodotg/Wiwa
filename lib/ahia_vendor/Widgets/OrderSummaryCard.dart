import 'package:wiwa_app/ahia/Services/ProductServices.dart';
import 'package:wiwa_app/ahia_vendor/Services/FirebaseServices.dart';
import 'package:wiwa_app/ahia_vendor/Services/OrderServices.dart';
import 'package:wiwa_app/ahia_vendor/Widgets/DeliveryAgentList.dart';
import 'package:wiwa_app/state/authState.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderSummaryCard extends StatefulWidget {
  static const String id = 'order-summary-screen';
  final DocumentSnapshot document;
  OrderSummaryCard(this.document);

  @override
  _OrderSummaryCardState createState() => _OrderSummaryCardState();
}

class _OrderSummaryCardState extends State<OrderSummaryCard> {
  bool isMyProfile = false;
  ProductServices _productServices = ProductServices();
  FirebaseServices _services = FirebaseServices();
  OrderServices _orderServices = OrderServices();
  DocumentSnapshot _customer;

  @override
  void initState() {
    _services.getCustomerDetails(widget.document['userId']).then((value) {
      if (value != null) {
        setState(() {
          _customer = value;
        });
      } else {
        print('no customer');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);

    Color statusColour(DocumentSnapshot document) {
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

    Icon statusIcon(DocumentSnapshot document) {
      if (document['orderStatus'] == 'Accepted') {
        return Icon(Icons.check_circle, color: statusColour(document));
      }

      if (document['orderStatus'] == 'Rejected') {
        return Icon(Icons.cancel, color: statusColour(document));
      }
      if (document['orderStatus'] == 'Picked Up') {
        return Icon(Icons.wallet_giftcard, color: statusColour(document));
      }
      if (document['orderStatus'] == 'Delivered') {
        return Icon(Icons.shopping_bag, color: statusColour(document));
      }
      if (document['orderStatus'] == 'On the way') {
        return Icon(Icons.delivery_dining, color: statusColour(document));
      }
      return Icon(CupertinoIcons.square_list, color: statusColour(document));
    }

    return Container(
        color: Colors.white,
        child: Column(children: [
          // order status
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 14,
              child: statusIcon(widget.document),
            ),
            title: Text(widget.document['orderStatus'],
                style: TextStyle(
                  fontSize: 12,
                  color: statusColour(widget.document),
                  fontWeight: FontWeight.bold,
                )),
            subtitle: Text(
                'On ${DateFormat.yMMMd().format(
                  DateTime.parse(widget.document['timestamp']),
                )}',
                style: TextStyle(fontSize: 12)),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    'Amount: \NGN${_productServices.formatedPrice(widget.document['total'])}',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text(
                    'Payment Method: ${widget.document['cod'] == true ? 'Cash on delivery' : 'Online payment'}',
                    style: TextStyle(
                      fontSize: 12,
                    )),
              ],
            ),
          ),

          // Customer details here
          _customer != null
              ? ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer Details',
                          style: TextStyle(
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.bold)),
                      Text(_customer['name'] ?? "ARYA STARK has 'NO NAME'",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _customer['address'] ?? 'Address',
                        style: TextStyle(fontSize: 12),
                        maxLines: 2,
                      ),
                      Text(
                          '${_customer['city']} - ${_customer['state']}' ??
                              'City & State',
                          style: TextStyle(
                            fontSize: 12,
                          )),
                      Text(
                        _customer['number'] ?? 'Phone Number',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.phone,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          _orderServices
                              .launchCall('tel:${_customer['number']}');
                        },
                      ),
                      // IconButton(
                      //   icon: Icon(
                      //     Icons.email,
                      //     color: Theme.of(context).primaryColor,
                      //   ),
                      //   onPressed: () {
                      //     _orderServices.launchEmail(
                      //         'mailto:${_customer['email']}?subject=Delivery Agent Contact');
                      //   },
                      // ),
                    ],
                  ),
                )
              : Container(),
          // order details
          ExpansionTile(
            title: Text(
              'Order details',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            subtitle: Text(
              'view order details',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Image.network(widget.document['products'][index]
                            ['productImage'])),
                    title:
                        Text(widget.document['products'][index]['productName']),
                    subtitle: Text(
                        'NGN${_productServices.formatedPrice(widget.document['products'][index]['price'])} x qty (${widget.document['products'][index]['quantity']}) = ${_productServices.formatedPrice(widget.document['products'][index]['total'])}',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  );
                },
                itemCount: widget.document['products'].length,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 12, right: 12, top: 8, bottom: 8),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [
                      Row(children: [
                        Text('Seller: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(
                          widget.document['seller']['shopName'],
                          style: (TextStyle(fontSize: 12)),
                        )
                      ]),
                      SizedBox(height: 10),
                      if (int.parse(widget.document['discount']) > 0)
                        Column(children: [
                          Row(children: [
                            Text('Discount: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12)),
                            Text(
                              '\NGN${widget.document['discount']}',
                            )
                          ]),
                          SizedBox(height: 10),
                          Row(children: [
                            Text('Discount Code: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12)),
                            Text('${widget.document['discountCode']}',
                                style: TextStyle(fontSize: 12))
                          ])
                        ]),
                      SizedBox(height: 10),
                      Row(children: [
                        Text('Delivery Fee: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(
                            'NGN${_productServices.formatedPrice(widget.document['deliveryFee'])}',
                            style: TextStyle(fontSize: 12))
                      ])
                    ]),
                  ),
                ),
              )
            ],
          ),

          Divider(thickness: 1, color: Colors.grey),

          statusContainer(widget.document, context),

          Divider(thickness: 2, color: Colors.grey),
        ]));
  }

  showMyDialog(title, status, documentId, context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text('Are you sure ? '),
          actions: [
            FlatButton(
              child: Text(
                'OK',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                EasyLoading.show(status: 'Updating order status...');
                status == 'Accepted'
                    ? _orderServices
                        .updateOrderStatus(documentId, status)
                        .then((value) {
                        ScaffoldMessenger.maybeOf(context).showSnackBar(
                            SnackBar(
                                content: Text("Order updated successfully")));
                        EasyLoading.showSuccess('');
                      })
                    : _orderServices
                        .updateOrderStatus(documentId, status)
                        .then((value) {
                        ScaffoldMessenger.maybeOf(context).showSnackBar(
                            SnackBar(
                                content: Text("Order updated successfully")));
                        EasyLoading.showSuccess('');
                      });
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  Widget statusContainer(DocumentSnapshot document, context) {
    if (document['deliveryBoy']['name'].length > 1) {
      return document['deliveryBoy']['image'] == null
          ? Container()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text('Delivery Agent',
                      style: TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  leading: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Image.network(document['deliveryBoy']['image'])),
                  title: new Text(document['deliveryBoy']['name'],
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(document['deliveryBoy']['phoneNumber']),
                      Text(document['deliveryBoy']['location']),
                    ],
                  ),
                  trailing: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.phone,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          _orderServices.launchCall(
                              'tel:${document['deliveryBoy']['phoneNumber']}');
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.email,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          _orderServices.launchEmail(
                              'mailto:${document['deliveryBoy']['email']}?subject=Delivery Agent Contact');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
    }

    if (document['orderStatus'] == 'Accepted') {
      return Container(
        color: Colors.grey[200],
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 8, 40, 8),
          child: FlatButton(
            color: Colors.orangeAccent,
            child: Text('Assign delivery agent',
                style: TextStyle(color: Colors.white)),
            onPressed: () {
              print('Assign delivery agent');
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DeliveryAgentList(document);
                  });
            },
          ),
        ),
      );
    }

    if (document['orderStatus'] == 'Rejected') {
      return Container(
        color: Colors.grey[200],
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 8, 40, 8),
          child: FlatButton(
            color: Colors.red,
            child: Text('Customer order rejected',
                style: TextStyle(color: Colors.white)),
            onPressed: () {
              print('Customer order rejected');
            },
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey[200],
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                color: Theme.of(context).primaryColor,
                child:
                    Text('Accept Order', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  showMyDialog(
                      'Accept Order', 'Accepted', document.id, context);
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                color: Colors.red,
                child:
                    Text('Reject Order', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  showMyDialog(
                      'Reject Order', 'Rejected', document.id, context);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
