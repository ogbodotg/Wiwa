import 'package:wiwa_app/ahia_vendor/Pages/EditProduct.dart';
import 'package:wiwa_app/ahia_vendor/Services/FirebaseServices.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UnPublishedProducts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseServices _services = FirebaseServices();
    User user = FirebaseAuth.instance.currentUser;

    return Container(
      child: StreamBuilder(
        stream: _services.products
            .where('seller.sellerUid', isEqualTo: user.uid)
            .where('published', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong...');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return SingleChildScrollView(
            child: FittedBox(
              child: DataTable(
                showBottomBorder: true,
                dataRowHeight: 60,
                headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                columns: <DataColumn>[
                  DataColumn(
                    label: Expanded(child: Text('Product/Services')),
                  ),
                  DataColumn(
                    label: Text('Image'),
                  ),
                  DataColumn(
                    label: Text('Info'),
                  ),
                  DataColumn(
                    label: Text('Actions'),
                  ),
                ],
                rows: _productDetails(snapshot.data, context),
              ),
            ),
          );
        },
      ),
    );
  }

  List<DataRow> _productDetails(QuerySnapshot snapshot, context) {
    List<DataRow> newList = snapshot.docs.map((DocumentSnapshot document) {
      if (document != null) {
        return DataRow(cells: [
          DataCell(
            Container(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  document['productName'],
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 4,
                ),
                subtitle:
                    Text(document['brand'], style: TextStyle(fontSize: 12)),
              ),
            ),
          ),
          DataCell(
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Image.network(document['productImage'],
                        fit: BoxFit.cover, width: 50, height: 50),
                  ],
                ),
              ),
            ),
          ),
          DataCell(IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditViewProduct(
                            productId: document['productId'],
                          )));
            },
            icon: Icon(Icons.info_outline),
          )),
          DataCell(
            Container(
              child: popUpButton(document.data()),
            ),
          ),
        ]);
      }
    }).toList();
    return newList;
  }

  Widget popUpButton(data, {BuildContext context}) {
    FirebaseServices _services = FirebaseServices();
    return PopupMenuButton<String>(
        onSelected: (String value) {
          if (value == 'publish') {
            _services.publishProduct(
              id: data['productId'],
            );
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'publish',
                child: ListTile(
                  leading: Icon(Icons.check),
                  title: Text('Publish'),
                ),
              ),
              // const PopupMenuItem<String>(
              //   value: 'preview',
              //   child: ListTile(
              //     leading: Icon(Icons.info),
              //     title: Text('Preview'),
              //   ),
              // ),
            ]);
  }
}
