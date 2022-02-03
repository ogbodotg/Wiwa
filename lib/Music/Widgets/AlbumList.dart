import 'package:wiwa_app/Music/Providers/AlbumProvider.dart';
import 'package:wiwa_app/Music/Providers/ArtistProvider.dart';
import 'package:wiwa_app/Music/Providers/SongProvider.dart';
import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlbumList extends StatefulWidget {
  @override
  _AlbumListState createState() => _AlbumListState();
}

class _AlbumListState extends State<AlbumList> {
  MusicServices _services = MusicServices();
  User user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    var _provider = Provider.of<SongProvider>(context);

    return Dialog(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).primaryColor,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select Album',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _services.albums
                .where('artistUid', isEqualTo: user.uid)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }
              if (!snapshot.hasData) {
                return Text('You have not created any album');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              return Expanded(
                child: ListView(
                    children:
                        snapshot.data.docs.map((DocumentSnapshot document) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(document['albumImage']),
                    ),
                    title: Text(document['albumName']),
                    onTap: () {
                      _provider.selectAlbum(
                          document['albumName'], document['albumImage']);
                      Navigator.pop(context);
                    },
                  );
                }).toList()),
              );
            },
          ),
        ],
      ),
    );
  }
}
