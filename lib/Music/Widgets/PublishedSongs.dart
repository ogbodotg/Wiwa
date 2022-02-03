import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:wiwa_app/ahia_vendor/Pages/EditProduct.dart';
import 'package:wiwa_app/ahia_vendor/Services/FirebaseServices.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PublishedSongs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MusicServices _services = MusicServices();
    User user = FirebaseAuth.instance.currentUser;

    return Container(
      child: StreamBuilder(
        stream: _services.songs
            .where('artist.artistUid', isEqualTo: user.uid)
            .where('published', isEqualTo: true)
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
                    label: Expanded(child: Text('Song')),
                  ),
                  DataColumn(
                    label: Text('Artwork'),
                  ),
                  DataColumn(
                    label: Text('Info'),
                  ),
                  DataColumn(
                    label: Text('Actions'),
                  ),
                ],
                rows: _songDetails(snapshot.data, context),
              ),
            ),
          );
        },
      ),
    );
  }

  List<DataRow> _songDetails(QuerySnapshot snapshot, context) {
    List<DataRow> newList = snapshot.docs.map((DocumentSnapshot document) {
      if (document != null) {
        return DataRow(cells: [
          DataCell(
            Container(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  document['songTitle'],
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 4,
                ),
                subtitle: Text(document['artist']['artistName'],
                    style: TextStyle(fontSize: 12)),
              ),
            ),
          ),
          DataCell(
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Image.network(document['songImage'],
                        fit: BoxFit.cover, width: 50, height: 50),
                  ],
                ),
              ),
            ),
          ),
          DataCell(IconButton(
            onPressed: () {
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => EditViewProduct(
              //               productId: document.data()['songId'],
              //             )));
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
    MusicServices _services = MusicServices();

    return PopupMenuButton<String>(
        onSelected: (String value) {
          if (value == 'unpublish') {
            _services.unPublishSong(
              id: data['songId'],
            );
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'unpublish',
                child: ListTile(
                  leading: Icon(Icons.check),
                  title: Text('UnPublish Song'),
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
