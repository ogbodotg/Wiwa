import 'package:wiwa_app/Music/Providers/AlbumProvider.dart';
import 'package:wiwa_app/Music/Providers/ArtistProvider.dart';
import 'package:wiwa_app/Music/Providers/SongProvider.dart';
import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:wiwa_app/Music/Widgets/AlbumSongs.dart';
import 'package:wiwa_app/ahia/Pages/ProductList.dart';
import 'package:wiwa_app/ahia/Widgets/Products/ProductListWidget.dart';
import 'package:wiwa_app/ahia/Providers/StoreProvider.dart';
import 'package:wiwa_app/ahia/Services/ProductServices.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class ArtistAlbum extends StatefulWidget {
  @override
  _ArtistAlbumState createState() => _ArtistAlbumState();
}

class _ArtistAlbumState extends State<ArtistAlbum> {
  // ProductServices _services = ProductServices();
  MusicServices _services = MusicServices();
  List _albumList = [];

  @override
  void didChangeDependencies() {
    var _artist = Provider.of<ArtistProvider>(context);

    _services.songs
        .where('published', isEqualTo: true)
        .where('artist.artistUid',
            isEqualTo: _artist.artistDetails['artistUid'])
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                _albumList.add(doc['album']);

                setState(() {});
              }),
            });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var _albumProvider = Provider.of<AlbumProvider>(context);
    // var _storeProvider = Provider.of<StoreProvider>(context);

    // var _artistProvider = Provider.of<ArtistProvider>(context);
    // var _songsProvider = Provider.of<SongProvider>(context);

    return FutureBuilder(
      future: _services.albums.get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong...'));
        }
        if (_albumList.length == 0) {
          return Center(
              // child: Text('Artist has no album'),
              );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return Center(child: Text('Artist has no album'));
        }
        return SingleChildScrollView(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: FittedBox(
                      child: Text('Albums/EP',
                          style: TextStyle(
                            shadows: <Shadow>[
                              // Shadow(
                              //   offset: Offset(2.0, 2.0),
                              //   blurRadius: 3.0,
                              //   color: Theme.of(context).primaryColor,
                              // )
                            ],
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Theme.of(context).primaryColor,
                          )),
                    ),
                  ),
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
            //   child: Text(
            //     'Albums/EPs',
            //     style: TextStyle(
            //       color: Theme.of(context).accentColor,
            //       fontSize: 24,
            //       fontWeight: FontWeight.w800,
            //     ),
            //   ),
            // ),
            SizedBox(
                height: 300,
                child: ListView(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    children:
                        snapshot.data.docs.map((DocumentSnapshot document) {
                      return _albumList.contains(document['albumName'])
                          ? GestureDetector(
                              child: SizedBox(
                                width: 220,
                                child: Column(
                                  children: [
                                    Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: CachedNetworkImage(
                                        height: 200,
                                        width: 200,
                                        errorWidget: (context, _, __) => Image(
                                          image: AssetImage('assets/cover.jpg'),
                                        ),
                                        imageUrl: document['albumImage'],
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Image(
                                          image: AssetImage('assets/cover.jpg'),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      document['albumName'],
                                      textAlign: TextAlign.center,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        // color: Colors.black87
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                        '(${DateFormat.y().format(
                                          DateTime.parse(document['timestamp']
                                              .toDate()
                                              .toString()),
                                        )})',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54)),
                                  ],
                                ),
                              ),
                              onTap: () {
                                _albumProvider
                                    .selectedAlbum(document['albumName']);
                                // _storeProvider.selectedCategorySub(null);
                                pushNewScreenWithRouteSettings(
                                  context,
                                  settings: RouteSettings(name: AlbumSongs.id),
                                  screen: AlbumSongs(),
                                  withNavBar: true,
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              },
                            )
                          : SizedBox();
                    }).toList()))
          ],
        )
            // : SizedBox(),
            );
      },
    );
  }
}
