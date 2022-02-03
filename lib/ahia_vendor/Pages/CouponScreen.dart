import 'package:wiwa_app/ahia_vendor/Pages/AddEditCoupon.dart';
import 'package:wiwa_app/ahia_vendor/Services/FirebaseServices.dart';
import 'package:wiwa_app/widgets/newWidget/rippleButton.dart';
import 'package:wiwa_app/widgets/newWidget/title_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CouponScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseServices _services = FirebaseServices();
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.purple),
        centerTitle: true,
        title: Text(
          'Coupons',
          style: TextStyle(color: Colors.black54),
        ),
      ),
      body: Container(
        child: StreamBuilder(
          stream: _services.coupons
              .where('sellerId', isEqualTo: _services.user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            // if (!snapshot.hasData) {
            //   return Center(
            //     child: Text('No discount coupons added yet'),
            //   );
            // }

            return new Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RippleButton(
                        onPressed: () async {
                          Navigator.pushNamed(context, AddEditCoupon.id);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
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
                              Icon(Icons.add,
                                  color: Theme.of(context).primaryColor),
                              SizedBox(width: 10),
                              TitleText(
                                'Add New Coupon',
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // FlatButton(
                      //   color: Theme.of(context).primaryColor,
                      //   onPressed: () {
                      //     Navigator.pushNamed(context, AddEditCoupon.id);
                      //   },
                      //   child: Text(
                      //     'Add New Coupon',
                      //     style: TextStyle(color: Colors.white),
                      //   ),
                      // ),
                    ),
                  ],
                ),
                FittedBox(
                  child: DataTable(
                    columns: <DataColumn>[
                      DataColumn(label: Text('Title')),
                      DataColumn(label: Text('Discount Rate')),
                      DataColumn(label: Text('Expiry Date')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Details')),
                    ],
                    rows: _couponList(snapshot.data, context),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  List<DataRow> _couponList(QuerySnapshot snapshot, context) {
    List<DataRow> newList = snapshot.docs.map((DocumentSnapshot document) {
      if (document != null) {
        var date = document['expiryDate'];
        var expiry = DateFormat.yMMMd().add_jm().format(date.toDate());
        return DataRow(cells: [
          DataCell(Text(document['title'])),
          DataCell(Text(document['discountRate'].toString())),
          DataCell(Text(expiry.toString())),
          DataCell(Text(document['active'] ? 'Active' : 'Inactive')),
          DataCell(IconButton(
            icon: Icon(Icons.info_outline_rounded),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddEditCoupon(document: document)));
            },
          )),
        ]);
      }
    }).toList();
    return newList;
  }
}
