import 'package:wiwa_app/ahia_vendor/Services/FirebaseServices.dart';
import 'package:wiwa_app/widgets/newWidget/rippleButton.dart';
import 'package:wiwa_app/widgets/newWidget/title_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';

class AddEditCoupon extends StatefulWidget {
  static const String id = 'add-update-coupon';
  final DocumentSnapshot document;

  AddEditCoupon({this.document});
  @override
  _AddEditCouponState createState() => _AddEditCouponState();
}

class _AddEditCouponState extends State<AddEditCoupon> {
  FirebaseServices _services = FirebaseServices();
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  var dateText = TextEditingController();
  var titleText = TextEditingController();
  var detailsText = TextEditingController();
  var discountRateText = TextEditingController();

  bool _active = false;

  _selectDate(context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
        _selectedDate = picked;
        dateText.text = formattedDate;
      });
  }

  @override
  void initState() {
    if (widget.document != null)
      setState(() {
        titleText.text = widget.document['title'];
        discountRateText.text = widget.document['discountRate'].toString();
        detailsText.text = widget.document['details'].toString();
        dateText.text = widget.document['expiryDate'].toDate().toString();
        _active = widget.document['active'];
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.purple),
        centerTitle: true,
        title: Text(
          'Add/Edit Coupons',
          style: TextStyle(color: Colors.black54),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            TextFormField(
              controller: titleText,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter Coupon Title';
                }
                return null;
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                labelText: 'Coupon Title',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            TextFormField(
              controller: discountRateText,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter Discount %';
                }
                return null;
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                labelText: 'Discount %',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: dateText,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Expiry Date';
                }
                return null;
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                labelText: 'Expiry Date (yyyy-mm-dd)',
                labelStyle: TextStyle(color: Colors.grey),
                suffixIcon: InkWell(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: Icon(Icons.date_range_outlined),
                ),
              ),
            ),
            TextFormField(
              controller: detailsText,
              // keyboardType: TextInputType.number,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter Coupon Details';
                }
                return null;
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                labelText: 'Coupon Details',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            SwitchListTile(
              activeColor: Theme.of(context).primaryColor,
              contentPadding: EdgeInsets.zero,
              title: Text('Activate Coupon'),
              value: _active,
              onChanged: (bool newValue) {
                setState(() {
                  _active = !_active;
                });
              },
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: RippleButton(
                onPressed: () async {
                  if (_formKey.currentState.validate())
                    EasyLoading.show(status: 'Please wait...');
                  _services
                      .saveCoupon(
                    document: widget.document,
                    title: titleText.text.toUpperCase(),
                    details: detailsText.text,
                    discountRate: int.parse(discountRateText.text),
                    expiryDate: _selectedDate,
                    active: _active,
                  )
                      .then((value) {
                    setState(() {
                      titleText.clear();
                      discountRateText.clear();
                      detailsText.clear();
                      _active = false;
                    });
                    ScaffoldMessenger.maybeOf(context).showSnackBar(
                        SnackBar(content: Text("Coupon saved successfully")));
                    EasyLoading.showSuccess('');
                  });
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
                  child: Wrap(
                    children: <Widget>[
                      Icon(Icons.money, color: Colors.white),
                      SizedBox(width: 10),
                      TitleText(
                        'Submit',
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Row(
            //   children: [
            //     Expanded(
            //       child:
            //       FlatButton(
            //           color: Theme.of(context).primaryColor,
            //           onPressed: () {
            //             if (_formKey.currentState.validate())
            //               EasyLoading.show(status: 'Please wait...');
            //             _services
            //                 .saveCoupon(
            //               document: widget.document,
            //               title: titleText.text.toUpperCase(),
            //               details: detailsText.text,
            //               discountRate: int.parse(discountRateText.text),
            //               expiryDate: _selectedDate,
            //               active: _active,
            //             )
            //                 .then((value) {
            //               setState(() {
            //                 titleText.clear();
            //                 discountRateText.clear();
            //                 detailsText.clear();
            //                 _active = false;
            //               });
            //               EasyLoading.showSuccess('Coupon saved successfully');
            //             });
            //           },
            //           child: Text(
            //             'Submit',
            //             style: TextStyle(
            //                 color: Colors.white, fontWeight: FontWeight.bold),
            //           )),
            //     ),
            //   ],
            // )
          ]),
        ),
      ),
    );
  }
}
