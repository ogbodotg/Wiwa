import 'package:wiwa_app/ahia/Helper/Constant.dart';
import 'package:wiwa_app/ahia/Pages/HomeScreen.dart';
import 'package:wiwa_app/ahia/Pages/MainScreen.dart';
import 'package:wiwa_app/ahia/Providers/Auth_Provider.dart';
import 'package:wiwa_app/widgets/newWidget/rippleButton.dart';
import 'package:wiwa_app/widgets/newWidget/title_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class SetDeliveryLocation extends StatefulWidget {
  static const String id = 'set-delivery-location';
  @override
  _SetDeliveryLocationState createState() => _SetDeliveryLocationState();
}

class _SetDeliveryLocationState extends State<SetDeliveryLocation> {
  final _formKey = GlobalKey<FormState>();
  var _nameTextController = TextEditingController();
  var _addressTextController = TextEditingController();
  var _phoneTextController = TextEditingController();
  var _cityTextController = TextEditingController();
  var _stateTextController = TextEditingController();
  String _address;
  String _phoneNumber;
  String _city;
  String _state;
  bool _loading = false;
  bool _loggedIn = false;
  User user;

  @override
  void initState() {
    //check user authentication before opening map
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() {
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
    if (user != null) {
      setState(() {
        _loggedIn = true;
        // user = FirebaseAuth.instance.currentUser;
      });
    }
    // else{
    //   _loggedIn = false;
    // }
  }

  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Set Delivery Location',
            style: TextStyle(color: Colors.black54)),
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                Icon(Icons.wallet_giftcard, size: 350, color: Colors.red),
                Text('Set your delivery location',
                    style: TextStyle(fontFamily: 'Anton', fontSize: 20)),
                SizedBox(height: 20),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text:
                          'Set location where you would like your order delivered',
                      style: TextStyle(color: Colors.black87)),
                ])),
                SizedBox(height: 20),
                TextFormField(
                    controller: _nameTextController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter order recipient\'s name';
                      }

                      setState(() {
                        _nameTextController.text = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(),
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Name',
                      prefixIcon: Icon(Icons.person),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 2),
                      ),
                      focusColor: Theme.of(context).primaryColor,
                    )),
                TextFormField(
                    keyboardType: TextInputType.phone,
                    controller: _phoneTextController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your phone number';
                      }

                      setState(() {
                        _phoneTextController.text = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(),
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_android),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 2),
                      ),
                      focusColor: Theme.of(context).primaryColor,
                    )),
                TextFormField(
                    controller: _addressTextController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your delivery address';
                      }

                      setState(() {
                        _addressTextController.text = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(),
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Delivery Address',
                      prefixIcon: Icon(Icons.location_city),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 2),
                      ),
                      focusColor: Theme.of(context).primaryColor,
                    )),
                TextFormField(
                    controller: _cityTextController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your delivery city';
                      }

                      setState(() {
                        _cityTextController.text = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(),
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Delivery City',
                      prefixIcon: Icon(Icons.location_city),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 2),
                      ),
                      focusColor: Theme.of(context).primaryColor,
                    )),
                TextFormField(
                    controller: _stateTextController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your delivery state';
                      }

                      setState(() {
                        _stateTextController.text = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(),
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Delivery State',
                      prefixIcon: Icon(Icons.location_city),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 2),
                      ),
                      focusColor: Theme.of(context).primaryColor,
                    )),
                SizedBox(height: 20),
                RippleButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      EasyLoading.show(status: 'Updating Delivery Address...');
                      _authData.updateDeliveryLocation(
                        id: user.uid,
                        name: _nameTextController.text,
                        number: _phoneTextController.text,
                        address: _addressTextController.text,
                        city: _cityTextController.text,
                        state: _stateTextController.text,
                      );
                      EasyLoading.dismiss();
                      pushNewScreenWithRouteSettings(
                        context,
                        settings: RouteSettings(name: HomeScreen.id),
                        screen: HomeScreen(),
                        withNavBar: true,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                      // Navigator.pop(context);
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Color(0xffeeeeee),
                          blurRadius: 15,
                          offset: Offset(5, 5),
                        ),
                      ],
                    ),
                    child: _loading
                        ? CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            backgroundColor: Colors.transparent,
                          )
                        : Wrap(
                            children: <Widget>[
                              Icon(Icons.location_pin, color: Colors.white),
                              SizedBox(width: 10),
                              TitleText(
                                'Set delivery location',
                                color: Colors.white,
                              ),
                            ],
                          ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
