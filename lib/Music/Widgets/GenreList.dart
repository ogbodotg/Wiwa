import 'package:wiwa_app/Music/Providers/SongProvider.dart';
import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GenreList extends StatefulWidget {
  @override
  _GenreListState createState() => _GenreListState();
}

class _GenreListState extends State<GenreList> {
  MusicServices _services = MusicServices();
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
                  Text('Select Genre',
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
            stream: _services.genre.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
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
                      backgroundImage: NetworkImage(document['genreImage']),
                    ),
                    title: Text(document['genreName']),
                    onTap: () {
                      _provider.selectGenre(
                          document['genreName'], document['genreImage']);
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

class SubGenreList extends StatefulWidget {
  @override
  _SubGenreListState createState() => _SubGenreListState();
}

class _SubGenreListState extends State<SubGenreList> {
  MusicServices _services = MusicServices();

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
                  Text('Select Sub-Genre',
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
          FutureBuilder<DocumentSnapshot>(
            future: _services.genre.doc(_provider.selectedGenre).get(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }
              if (snapshot.connectionState == ConnectionState.done) {
                // return Center(
                //   child: CircularProgressIndicator(),
                // );
                Map<String, dynamic> data = snapshot.data.data();
                return data != null
                    ? Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    child: Row(children: [
                                  Text('Genre: '),
                                  FittedBox(
                                    child: Text(
                                      _provider.selectedGenre,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ])),
                              ),
                              Divider(
                                thickness: 3,
                              ),
                              Container(
                                  child: Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: ListView.builder(
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: CircleAvatar(
                                          child: Text('${index + 1}'),
                                        ),
                                        title: Text(data['subGenre'][index]
                                            ['genreName']),
                                        onTap: () {
                                          _provider.selectSubGenre(
                                              data['subGenre'][index]
                                                  ['genreName']);
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                    itemCount: data['subGenre'] == null
                                        ? 0
                                        : data['subGenre'].length,
                                  ),
                                ),
                              ))
                            ]),
                        // child: ListView(
                        //     children:
                        //         snapshot.data.docs.map((DocumentSnapshot document) {
                        //   return ListTile(
                        //     leading: CircleAvatar(
                        //       backgroundImage:
                        //           NetworkImage(document.data()['productImage']),
                        //     ),
                        //     title: Text(document.data()['categoryName']),
                        //     onTap: () {
                        //       _provider.selectCategory(document.data()['categoryName']);
                        //       Navigator.pop(context);
                        //     },
                        //   );
                        // }).toList()),
                      )
                    : Text('No genre selected');
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }
}
