import 'package:wiwa_app/ahia/Pages/ProfileScreen.dart';
import 'package:wiwa_app/ahia/Pages/SetDeliveryAddress.dart';
import 'package:wiwa_app/ahia/Providers/Auth_Provider.dart';
import 'package:wiwa_app/ahia/Providers/CartProvider.dart';
import 'package:wiwa_app/ahia/Providers/CouponProvider.dart';
import 'package:wiwa_app/ahia/Providers/StoreProvider.dart';
import 'package:wiwa_app/ahia/Services/CartServices.dart';
import 'package:wiwa_app/ahia/Services/OnlinePayment.dart';
import 'package:wiwa_app/ahia/Services/OrderServices.dart';
import 'package:wiwa_app/ahia/Services/ProductServices.dart';
import 'package:wiwa_app/ahia/Services/StoreServices.dart';
import 'package:wiwa_app/ahia/Services/UserServices.dart';
import 'package:wiwa_app/ahia/Widgets/Cart/CartList.dart';
import 'package:wiwa_app/ahia/Widgets/Cart/CodToggle.dart';
import 'package:wiwa_app/ahia/Widgets/Cart/CouponWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  static const String id = 'cart-page';
  final DocumentSnapshot document;
  // final User user;
  CartPage({this.document});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  StoreServices _store = StoreServices();
  UserServices _ahiaUser = UserServices();
  OrderServices _orderServices = OrderServices();
  CartServices _cartServices = CartServices();
  var user = FirebaseAuth.instance.currentUser;
  DocumentSnapshot doc;
  DocumentSnapshot userDoc;

  double deliveryFee = 0.00;
  var textstyle = TextStyle(color: Colors.grey);
  String _address;
  String _city;
  String _state;
  bool _checkingUser = false;
  double discount = 0;

  @override
  void initState() {
    getDeliveryAddress();
    _store.getShopDetails(widget.document['sellerUid']).then((value) {
      setState(() {
        doc = value;
      });
    });
    super.initState();
  }

  getDeliveryAddress() {
    _ahiaUser.getUserById(user.uid).then((value) {
      setState(() {
        userDoc = value;
        _address = userDoc['address'];
        _city = userDoc['city'];
        _state = userDoc['state'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ProductServices _services = ProductServices();
    var _cartProvider = Provider.of<CartProvider>(context);
    var userDetails = Provider.of<AuthProvider>(context);
    var _coupon = Provider.of<CouponProvider>(context);
    userDetails.getUserDetails().then((value) {
      double subTotal = _cartProvider.subTotal;
      double discountRate = _coupon.discountRate / 100;
      setState(() {
        discount = subTotal * discountRate;
      });
    });
    var _total = _cartProvider.subTotal + deliveryFee - discount;
    var _formatedTotal = _services.formatedPrice(_total);
    var _formatedSubTotal = _services.formatedPrice(_cartProvider.subTotal);
    var _formatedTotalSavings = _services.formatedPrice(_cartProvider.saving);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.grey[300],
      bottomSheet: userDetails.snapshot == null
          ? Container()
          : Container(
              height: 170,
              color: Theme.of(context).primaryColor.withOpacity(.3),
              child: Column(
                children: [
                  Container(
                    // padding: EdgeInsets.only(bottom: 60),
                    height: 110,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Delivery Address:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                                FlatButton(
                                  child: Text('Set Delivery Address',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  onPressed: () {
                                    pushNewScreenWithRouteSettings(
                                      context,
                                      settings: RouteSettings(
                                          name: SetDeliveryLocation.id),
                                      screen: SetDeliveryLocation(),
                                      withNavBar: true,
                                      pageTransitionAnimation:
                                          PageTransitionAnimation.cupertino,
                                    );
                                    // Navigator.pushNamed(
                                    //     context, SetDeliveryLocation.id);
                                  },
                                )
                              ],
                            ),
                            if (_address != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_address, maxLines: 3, style: textstyle),
                                  Row(
                                    children: [
                                      Text('${_city} - ', style: textstyle),
                                      Text(_state, style: textstyle),
                                    ],
                                  ),
                                ],
                              ),
                          ]),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Total: NGN$_formatedTotal',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                              // Text('(VAT included)',
                              //     style: TextStyle(color: Colors.grey, fontSize: 10)),
                            ],
                          ),
                          RaisedButton(
                            child: _checkingUser
                                ? CircularProgressIndicator()
                                : Text(
                                    'Check Out',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              // EasyLoading.show(status: 'Please wait...');

                              _ahiaUser.getUserById(user.uid).then((value) {
                                // if (value['number'] == null) {
                                if (!value.exists) {
                                  // might want to replace username with may be phone number
                                  EasyLoading.dismiss();
                                  pushNewScreenWithRouteSettings(
                                    context,
                                    settings: RouteSettings(
                                        name: SetDeliveryLocation.id),
                                    screen: SetDeliveryLocation(),
                                    withNavBar: false,
                                    pageTransitionAnimation:
                                        PageTransitionAnimation.cupertino,
                                  );
                                } else {
                                  // payment method goes here. We'll integrate Paystack and flutterwave
                                  if (_cartProvider.cod == false) {
                                    // online payment option
                                    Navigator.pushReplacementNamed(
                                        context, OnlinePayment.id);
                                  } else {
                                    EasyLoading.show(
                                        status:
                                            'Please wait... We are processing your order');
                                    // cash on delivery option
                                    _saveOrder(_cartProvider, _total, _coupon);
                                  }
                                }
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.document['shopName'],
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    children: [
                      Text(
                        '${_cartProvider.cartQty} ${_cartProvider.cartQty > 1 ? ' items in cart' : ' item in cart'}',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text(
                        ' | Total: NGN$_formatedTotal',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ];
        },
        body: doc == null
            ? Center(child: CircularProgressIndicator())
            : _cartProvider.cartQty > 0
                ? SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 80),
                    child: Container(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Column(children: [
                        Column(
                          children: [
                            ListTile(
                              tileColor: Colors.white,
                              leading: Container(
                                height: 60,
                                width: 60,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(doc['shopImage'],
                                        fit: BoxFit.cover)),
                              ),
                              title: Text(doc['shopName']),
                              subtitle: Text(
                                doc['shopAddress'],
                                maxLines: 1,
                              ),
                            ),
                            CodToggleSwitch(),
                            Divider(color: Colors.grey),
                          ],
                        ),

                        CartList(
                          document: widget.document,
                        ),

                        // coupon area
                        // if (userDoc != null)
                        CouponWidget(doc['uid']),

                        // bill details card
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 4, left: 4, top: 4, bottom: 80),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Bill Details',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(child: Text('Sub Total ')),
                                          Text('NGN$_formatedSubTotal',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      if (discount >
                                          0) // only display when discount is greater than zero
                                        Row(
                                          children: [
                                            Expanded(child: Text('Discount ')),
                                            Text(
                                                'NGN${discount.toStringAsFixed(0)}')
                                          ],
                                        ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                                  'Delivery Fee (vendor-customer decides)')),
                                          Text(
                                              'NGN${deliveryFee.toStringAsFixed(0)}')
                                        ],
                                      ),
                                      Divider(
                                        color: Colors.grey,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            'Total Amount',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )),
                                          Text(
                                            'NGN$_formatedTotal',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(.3),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(children: [
                                            Expanded(
                                              child: Text(
                                                'Total Saving',
                                                style: TextStyle(
                                                    color: Colors.green),
                                              ),
                                            ),
                                            Text(
                                              'NGN$_formatedTotalSavings',
                                              style: TextStyle(
                                                  color: Colors.green),
                                            ),
                                          ]),
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Your cart is empty...',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Shop now... buy from your favourite vendor',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  _saveOrder(CartProvider cartProvider, total, CouponProvider coupon) {
    _orderServices.saveOrder({
      'products': cartProvider.cartList,
      'userId': user.uid,
      'deliveryFee': deliveryFee,
      'total': total,
      'discount': discount.toStringAsFixed(0),
      'cod': cartProvider.cod,
      'discountCode': coupon.document == null ? null : coupon.document['title'],
      'seller': {
        'shopName': widget.document['shopName'],
        'sellerId': widget.document['sellerUid'],
      },
      'timestamp': DateTime.now().toString(),
      'orderStatus': 'Ordered',
      'deliveryBoy': {
        'name': '',
        'phoneNumber': '',
        'location': '',
      },
    }).then((value) {
      _cartServices.deleteCart().then((value) {
        _cartServices.checkCartData().then((value) {
          ScaffoldMessenger.maybeOf(context).showSnackBar(
            SnackBar(
                content: Text("Your order has been submitted to the vendor")),
          );
          EasyLoading.showSuccess('');
          Navigator.pop(context);
        });
      });
    });
  }
}
