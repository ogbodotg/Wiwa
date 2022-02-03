import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:wiwa_app/Music/FrontEnd/Screens/Player/audioplayer.dart';
import 'package:wiwa_app/Music/Providers/ArtistProvider.dart';
import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:wiwa_app/helper/utility.dart';
import 'package:wiwa_app/ui/theme/custom_icon_icons.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

List playlists = [
  {
    "id": "RecentlyPlayed",
    "title": "RecentlyPlayed",
    "image": <DocumentSnapshot>[],
    "songsList": <DocumentSnapshot>[],
    "type": "",
    "artist": <DocumentSnapshot>[],
    "likes": <DocumentSnapshot>[],
  }
];

class AllSongsOnArtistHome extends StatefulWidget {
  @override
  _AllSongsOnArtistHomeState createState() => _AllSongsOnArtistHomeState();
}

class _AllSongsOnArtistHomeState extends State<AllSongsOnArtistHome> {
  MusicServices _services = MusicServices();
  List<DocumentSnapshot> topSongsList;
  ScrollController _rightController = ScrollController();
  final _width = 50.0;
  _animateToIndex(i) => _rightController.animateTo(_width * i,
      duration: Duration(seconds: 2), curve: Curves.fastOutSlowIn);

  // DocumentSnapshot songDoc;

  // Future<void> getSongDoc(String songId) async {
  //   _services.songs.doc(songId).get().then((DocumentSnapshot document) {
  //     if (document.exists) {
  //       setState(() {
  //         songDoc = document;
  //       });
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var _artist = Provider.of<ArtistProvider>(context);

    return StreamBuilder<QuerySnapshot>(
      stream: _services.songs
          .where('published', isEqualTo: true)
          .where('artist.artistUid',
              isEqualTo: _artist.artistDetails['artistUid'])
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return Center(
            child: Center(child: Text('Artist has no song')),
          );
        }

        topSongsList = snapshot.data.docs;

        return ListView.builder(
            physics: BouncingScrollPhysics(), //NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            scrollDirection: Axis.vertical,
            itemCount: playlists.length,
            itemBuilder: (context, idx) {
              playlists[idx]["songsList"] = topSongsList;
              // playlists[idx]["image"] = topSongsList[idx]['songImage'];
              // playlists[idx]["title"] = topSongsList[idx]['songTitle'];
              // playlists[idx]["artist"] =
              //     topSongsList[idx]['artist']['artistName'];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: FittedBox(
                              child: Text('All Songs',
                                  style: TextStyle(
                                    shadows: <Shadow>[],
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
                    //     'All Songs',
                    //     style: TextStyle(
                    //       color: Theme.of(context).accentColor,
                    //       fontSize: 24,
                    //       fontWeight: FontWeight.w800,
                    //     ),
                    //   ),
                    // ),
                  ),
                  playlists[idx]["songsList"] == null
                      ? SizedBox(
                          height: 200,
                          child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              itemCount: 10,
                              itemBuilder: (context, index) {
                                return SizedBox(
                                  width: 150,
                                  child: Column(
                                    children: [
                                      Card(
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Image(
                                          image: AssetImage('assets/cover.jpg'),
                                        ),
                                      ),
                                      Text(
                                        'Loading ...',
                                        textAlign: TextAlign.center,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        // style: TextStyle(
                                        //     color: Theme.of(context).accentColor),
                                      ),
                                      Text(
                                        'Please Wait',
                                        textAlign: TextAlign.center,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .caption
                                                .color),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        )
                      : SizedBox(
                          height: 350,
                          child: Scaffold(
                            floatingActionButton:
                                playlists[idx]["songsList"].length < 4
                                    ? SizedBox()
                                    : FloatingActionButton(
                                        onPressed: () => _animateToIndex(10),
                                        child: Icon(Icons.arrow_forward),
                                        // focusColor: Colors.transparent,
                                        // hoverColor: Colors.purple,
                                        // backgroundColor: Colors.purple[400],
                                      ),
                            body: CupertinoScrollbar(
                              thickness: 3,
                              thicknessWhileDragging: 5,
                              child: ListView.builder(
                                controller: _rightController,
                                // physics: BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                itemCount: playlists[idx]["songsList"].length,
                                itemBuilder: (context, index) {
                                  return SafeArea(
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          child: SizedBox(
                                            width: 250,
                                            child: Column(
                                              children: [
                                                Card(
                                                  elevation: 5,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  clipBehavior: Clip.antiAlias,
                                                  child: CachedNetworkImage(
                                                    height: 190,
                                                    width: 190,
                                                    errorWidget:
                                                        (context, _, __) =>
                                                            Image(
                                                      image: AssetImage(
                                                          'assets/cover.jpg'),
                                                    ),
                                                    imageUrl: playlists[idx]
                                                            ["songsList"][index]
                                                        ['songImage'],
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (context, url) => Image(
                                                      image: AssetImage(
                                                          'assets/cover.jpg'),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  playlists[idx]["songsList"]
                                                      [index]['songTitle'],
                                                  textAlign: TextAlign.center,
                                                  softWrap: false,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 22,
                                                    // color: Colors.black87
                                                  ),
                                                ),
                                                Text(
                                                  '${playlists[idx]["songsList"][index]["artist"]["artistName"]}',
                                                  textAlign: TextAlign.center,
                                                  softWrap: false,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  'Producer: ${playlists[idx]["songsList"][index]["producer"]}',
                                                  textAlign: TextAlign.center,
                                                  softWrap: false,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .caption
                                                          .color),
                                                ),
                                              ],
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                opaque: false,
                                                pageBuilder: (_, __, ___) =>
                                                    AudioServiceWidget(
                                                  child: PlayScreen(
                                                    data: {
                                                      'response': playlists[idx]
                                                          ["songsList"],
                                                      'index': index,
                                                      'offline': false,
                                                      'recent': false,
                                                      'onlineFav': false,
                                                    },
                                                    fromMiniplayer: false,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Row(
                                              children: [
                                                InkWell(
                                                    onTap: () {
                                                      _services.likeSong(
                                                          playlists[idx]
                                                                  ["songsList"][
                                                              index]["songId"]);
                                                    },
                                                    child: playlists[idx][
                                                                    "songsList"]
                                                                [index]["likes"]
                                                            .contains(_services
                                                                .user.uid)
                                                        ? Icon(
                                                            // AppIcon.heartFill,
                                                            CustomIcon
                                                                .thumbs_up_alt,
                                                            color:
                                                                Colors.purple,
                                                            size: 25,
                                                          )
                                                        : Icon(
                                                            CustomIcon
                                                                .thumbs_up_1,
                                                            size: 25,
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .caption
                                                                .color,
                                                          )
                                                    // Padding(
                                                    //     padding:
                                                    //         const EdgeInsets
                                                    //                 .only(
                                                    //             bottom:
                                                    //                 9.0),
                                                    //     child: Icon(
                                                    //       // AppIcon.heartFill,
                                                    //       // color: TwitterColor
                                                    //       //     .ceriseRed,
                                                    //       CustomIcon
                                                    //           .thumbs_up_alt,
                                                    //       color:
                                                    //           Colors.purple,
                                                    //       size: 25,
                                                    //     ),
                                                    //   )
                                                    // : Padding(
                                                    //     padding:
                                                    //         const EdgeInsets
                                                    //                 .only(
                                                    //             bottom:
                                                    //                 9.0),
                                                    //     child: Icon(
                                                    //       CustomIcon
                                                    //           .thumbs_up_1,
                                                    //       size: 25,
                                                    //     ),
                                                    //   )
                                                    ),
                                                SizedBox(
                                                  width: 3,
                                                ),
                                                Text(_services
                                                    .formatNumber(playlists[idx]
                                                                ["songsList"]
                                                            [index]["likes"]
                                                        .length)
                                                    .toString())
                                              ],
                                            ),
                                            SizedBox(width: 15),
                                            Row(
                                              children: [
                                                Icon(
                                                  CustomIcon.headphones_alt,
                                                  // Icons.play_circle_fill_sharp,
                                                  size: 25,
                                                  color:
                                                      playlists[idx]["songsList"]
                                                                      [index]
                                                                  [
                                                                  "playCount"] >
                                                              0
                                                          ? Theme.of(context)
                                                              .primaryColor
                                                          : Theme.of(context)
                                                              .textTheme
                                                              .caption
                                                              .color,
                                                ),
                                                SizedBox(
                                                  width: 3,
                                                ),
                                                Text(_services.formatNumber(
                                                    playlists[idx]["songsList"]
                                                        [index]["playCount"])),
                                                // Text(playlists[idx]["songsList"]
                                                //     [index]["playCount"])
                                              ],
                                            ),
                                            SizedBox(width: 15),
                                            IconButton(
                                              icon: Icon(Icons.share
                                                  // CustomIcon
                                                  //     .share_1,
                                                  ),
                                              onPressed: () async {
                                                var socialMetaTagParameters =
                                                    SocialMetaTagParameters(
                                                        description:
                                                            "${playlists[idx]["songsList"][index]['songTitle']} by ${playlists[idx]["songsList"][index]["artist"]["artistName"]}" ??
                                                                "",
                                                        title:
                                                            "${playlists[idx]["songsList"][index]["artist"]["artistName"]} on Wiwa Music",
                                                        imageUrl: Uri.parse(
                                                            playlists[idx][
                                                                            "songsList"]
                                                                        [index][
                                                                    'songImage']
                                                                .toString()));
                                                // Navigator.pop(
                                                //     context);
                                                var url =
                                                    Utility.createLinkToShare(
                                                  context,
                                                  "songs/${playlists[idx]["songsList"][index]["songId"]}",
                                                  socialMetaTagParameters:
                                                      socialMetaTagParameters,
                                                );
                                                var uri = await url;
                                                Utility.share(uri.toString(),
                                                    subject:
                                                        "${playlists[idx]["songsList"][index]['songTitle']} by ${playlists[idx]["songsList"][index]["artist"]["artistName"]} on Wiwa Music");
                                              },
                                              iconSize: 25,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .color,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                ],
              );
            });
      },
    );
  }
}
