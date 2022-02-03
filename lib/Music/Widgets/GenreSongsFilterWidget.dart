import 'package:wiwa_app/Music/Providers/AlbumProvider.dart';
import 'package:wiwa_app/Music/Providers/ArtistProvider.dart';
import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:wiwa_app/ahia/Providers/StoreProvider.dart';
import 'package:wiwa_app/ahia/Services/ProductServices.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GenreSongFilterWidget extends StatefulWidget {
  @override
  _GenreSongFilterWidgetState createState() => _GenreSongFilterWidgetState();
}

class _GenreSongFilterWidgetState extends State<GenreSongFilterWidget> {
  List _subGenreList = [];
  MusicServices _services = MusicServices();

  @override
  void didChangeDependencies() {
    var _artist = Provider.of<ArtistProvider>(context);
    var _albumProvider = Provider.of<AlbumProvider>(context);

    _services.songs
        .where('genre.mainGenre', isEqualTo: _albumProvider.selectedSongGenre)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          _subGenreList.add(doc['genre']['subGenre']);
        });
      });
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // var _storeData = Provider.of<StoreProvider>(context);
    var _albumProvider = Provider.of<AlbumProvider>(context);

    return FutureBuilder<DocumentSnapshot>(
      future: _services.genre.doc(_albumProvider.selectedSongGenre).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (!snapshot.hasData) {
          return Container();
        }

        Map<String, dynamic> data = snapshot.data.data();
        return Container(
          height: 50,
          color: Colors.grey,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SizedBox(width: 10),
              ActionChip(
                elevation: 4,
                label: Text('All ${_albumProvider.selectedSongGenre}'),
                onPressed: () {
                  _albumProvider.selectedGenreSub(null);
                },
                backgroundColor: Colors.white,
              ),
              ListView.builder(
                // itemCount: data.length,
                itemCount: data != null ? data.length : 0,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                physics: ScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: _subGenreList
                            .contains(data['subGenre'][index]['genreName'])
                        ? ActionChip(
                            elevation: 4,
                            label: Text(data['subGenre'][index]['genreName']),
                            onPressed: () {
                              _albumProvider.selectedGenreSub(
                                  data['subGenre'][index]['genreName']);
                            },
                            backgroundColor: Colors.white,
                          )
                        : Container(),
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }
}
