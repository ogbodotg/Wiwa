import 'package:wiwa_app/Music/Providers/AlbumProvider.dart';
import 'package:wiwa_app/Music/Providers/ArtistProvider.dart';
import 'package:wiwa_app/Music/Providers/SongProvider.dart';
import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:wiwa_app/Music/Widgets/AlbumSongs.dart';
import 'package:wiwa_app/Music/Widgets/GenreSongs.dart';
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

class Genres extends StatefulWidget {
  @override
  _GenresState createState() => _GenresState();
}

class _GenresState extends State<Genres> {
  // ProductServices _services = ProductServices();
  MusicServices _services = MusicServices();
  List _genreList = [];

  @override
  void didChangeDependencies() {
    var _artist = Provider.of<ArtistProvider>(context);

    _services.songs
        .where('published', isEqualTo: true)
        .where('isFeatured', isEqualTo: true)
        // .where('artist.artistUid',
        //     isEqualTo: _artist.artistDetails['artistUid'])
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                _genreList.add(doc['genre']['mainGenre']);

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
      future: _services.genre.get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong...'));
        }
        if (_genreList.length == 0) {
          return Center(
              // child: Text('Artist has no album'),
              );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return Center();
        }
        return !snapshot.hasData
            ? SizedBox()
            : Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
                        child: Text(
                          'Featured Songs by Genres',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                      height: 150,
                      child: ListView(
                          // physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          children: snapshot.data.docs
                              .map((DocumentSnapshot document) {
                            return _genreList.contains(document['genreName'])
                                ? GestureDetector(
                                    child: SizedBox(
                                      width: 130,
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
                                              height: 100,
                                              width: 100,
                                              errorWidget: (context, _, __) =>
                                                  Image(
                                                image: AssetImage(
                                                    'assets/cover.jpg'),
                                              ),
                                              imageUrl: document['genreImage'],
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Image(
                                                image: AssetImage(
                                                    'assets/cover.jpg'),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            document['genreName'],
                                            textAlign: TextAlign.center,
                                            softWrap: false,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              // color: Colors.black87
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      _albumProvider
                                          .selectedGenre(document['genreName']);
                                      _albumProvider.selectedGenreSub(null);
                                      pushNewScreenWithRouteSettings(
                                        context,
                                        settings:
                                            RouteSettings(name: GenreSongs.id),
                                        screen: GenreSongs(),
                                        withNavBar: true,
                                        pageTransitionAnimation:
                                            PageTransitionAnimation.cupertino,
                                      );
                                    },
                                  )
                                : SizedBox();
                          }).toList()))
                  // Wrap(
                  //   direction: Axis.horizontal,
                  //   children:
                  //       snapshot.data.docs.map((DocumentSnapshot document) {
                  //     return _albumList.contains(document.data()['albumName'])
                  //         ? InkWell(
                  //             onTap: () {
                  //               _albumProvider.selectedAlbum(
                  //                   document.data()['albumName']);
                  //               // _storeProvider.selectedCategorySub(null);
                  //               // pushNewScreenWithRouteSettings(
                  //               //   context,
                  //               //   settings: RouteSettings(name: ProductList.id),
                  //               //   screen: ProductList(),
                  //               //   withNavBar: true,
                  //               //   pageTransitionAnimation:
                  //               //       PageTransitionAnimation.cupertino,
                  //               // );
                  //             },
                  //             child: Container(
                  //               width: 200,
                  //               height: 200,
                  //               child: Container(
                  //                 decoration: BoxDecoration(
                  //                     color: Colors.white,
                  //                     border: Border.all(
                  //                       color: Colors.grey,
                  //                       width: .3,
                  //                     )),
                  //                 child: Column(
                  //                   children: [
                  //                     Center(
                  //                         child: Image.network(
                  //                       document.data()['albumImage'],
                  //                       fit: BoxFit.cover,
                  //                       height: 150,
                  //                       width: 150,
                  //                     )),
                  //                     Padding(
                  //                       padding: const EdgeInsets.only(
                  //                           left: 8, right: 8),
                  //                       child: Text(
                  //                         document.data()['albumName'],
                  //                         textAlign: TextAlign.center,
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 ),
                  //               ),
                  //             ),
                  //           )
                  //         : Text('');
                  //   }).toList(),
                  // ),
                ],
              );
      },
    );
  }
}
