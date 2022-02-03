import 'package:wiwa_app/Music/Model/songModel.dart';
import 'package:wiwa_app/Music/Providers/ArtistProvider.dart';
import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:wiwa_app/Music/Widgets/AllSongSearch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:search_page/search_page.dart';

class ArtistAppBar extends StatefulWidget {
  @override
  _ArtistAppBarState createState() => _ArtistAppBarState();
}

class _ArtistAppBarState extends State<ArtistAppBar> {
  static List<AllSongs> allSongs = [];
  String artist;
  DocumentSnapshot document;
  MusicServices _musicServices = MusicServices();
  String artistName;
  String artistUid;

  @override
  void initState() {
    _musicServices.songs
        .where('published', isEqualTo: true)
        // .where('artist.artistUid', isEqualTo: artistUid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        document = doc;

        allSongs.add(AllSongs(
          genre: doc['genre']['mainGenre'],
          artist: doc['artist']['artistName'],
          artistUid: doc['artist']['artistUid'],
          songImage: doc['songImage'],
          songTitle: doc['songTitle'],
          album: doc['album'],
          producer: doc['producer'],
          // playCount: doc['playCount'],
          document: doc,
          topSongsList: querySnapshot.docs,
        ));
        setState(() {});
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    // products.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _artistData = Provider.of<ArtistProvider>(context);
    artistName = _artistData.artistDetails['artistName'];
    artistUid = _artistData.artistDetails['artistUid'];
    setState(() {});

    return SliverAppBar(
      floating: true,
      snap: true,
      iconTheme: IconThemeData(
        color: Colors.purple,
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {});
            showSearch(
                context: context,
                delegate: SearchPage<AllSongs>(
                  barTheme: ThemeData(
                      hintColor: Colors.black,
                      primaryColor: Colors.white,
                      iconTheme: IconThemeData(color: Colors.purple)),
                  onQueryUpdate: (s) => print(s),
                  items: allSongs,
                  searchLabel: 'Search songs',
                  suggestion: Center(
                    child: Text(
                      'Filter songs by Song Title, Producer or Genre',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  failure: Center(
                    child: Text('No song found :(',
                        style: TextStyle(fontSize: 20)),
                  ),
                  filter: (songs) => [
                    songs.songTitle,
                    songs.artist,
                    songs.genre,
                    songs.album,
                    songs.producer,
                  ],
                  // builder: (products) => shopName != products.shopName
                  //     ? Container()
                  builder: (allsongs) => artistUid != allsongs.artistUid
                      ? Container()
                      : AllSongSearch(
                          allSongs: allsongs,
                          document: allsongs.document,
                          topSongsList: allsongs.topSongsList,
                        ),
                ));
          },
          icon: Icon(CupertinoIcons.search),
        )
      ],
      title: Text(_artistData.artistDetails['artistName'],
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }
}
