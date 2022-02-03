import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:provider/provider.dart';
import 'package:wiwa_app/Music/FrontEnd/Screens/Player/audioplayer.dart';
import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:wiwa_app/helper/customRoute.dart';
import 'package:wiwa_app/helper/utility.dart';
import 'package:wiwa_app/model/feedModel.dart';
import 'package:wiwa_app/ui/theme/custom_icon_icons.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'dart:convert';

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
List cachedPlaylists = [
  {
    "id": "RecentlyPlayed",
    "title": "RecentlyPlayed",
    "image": "",
    "songsList": [],
    "type": ""
  }
];

bool fetched = false;
bool showCached = true;

List preferredLanguage =
    Hive.box('settings').get('preferredLanguage') ?? ['English'];

class SongShareRoute extends StatefulWidget {
  SongShareRoute({Key key, this.songId}) : super(key: key);
  final String songId;

  // static getRoute(String songId) {
  //   return SongShareRoute(
  //     songId: songId,
  //   );
  // }

  static Route<Null> getRoute(String songId) {
    return SlideLeftRoute<Null>(
      builder: (BuildContext context) => SongShareRoute(
        songId: songId,
      ),
    );
  }

  // @override
  _SongShareRouteState createState() => _SongShareRouteState();
}

class _SongShareRouteState extends State<SongShareRoute> {
  List<DocumentSnapshot> topSongsList;
  MusicServices _services = MusicServices();
  ScrollController _rightController = ScrollController();
  final _width = 50.0;
  _animateToIndex(i) => _rightController.animateTo(_width * i,
      duration: Duration(seconds: 2), curve: Curves.fastOutSlowIn);

  @override
  void initState() {
    // trendingSongs(index);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('songs')
          // .doc(widget.songId)
          // .get(),
          .where('songId', isEqualTo: widget.songId)
          .where('published', isEqualTo: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        topSongsList = snapshot.data.docs;

        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Theme.of(context).primaryColor,
            ),
          ),
          body: ListView.builder(
              physics:
                  BouncingScrollPhysics(), //NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              scrollDirection: Axis.vertical,
              itemCount: playlists.length,
              itemBuilder: (context, idx) {
                playlists[idx]["songsList"] = topSongsList;
                playlists[idx]["likes"] = topSongsList[idx]['likes'];
                // playlists[idx]["title"] = topSongsList[idx]['songTitle'];
                // playlists[idx]["artist"] =
                //     topSongsList[idx]['artist']['artistName'];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                                            image:
                                                AssetImage('assets/cover.jpg'),
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
                            height: 600,
                            child: ListView.builder(
                              // physics: BouncingScrollPhysics(),
                              // controller: _rightController,
                              // reverse: true,
                              // scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              itemCount: playlists[idx]["songsList"].length,
                              itemBuilder: (context, index) {
                                return SafeArea(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        child: SizedBox(
                                          width: 420,
                                          child: Column(
                                            children: [
                                              Stack(
                                                children: [
                                                  Card(
                                                    elevation: 5,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    child: CachedNetworkImage(
                                                      height: 400,
                                                      width: 400,
                                                      errorWidget:
                                                          (context, _, __) =>
                                                              Image(
                                                        image: AssetImage(
                                                            'assets/cover.jpg'),
                                                      ),
                                                      imageUrl: playlists[idx]
                                                              ["songsList"]
                                                          [index]['songImage'],
                                                      fit: BoxFit.cover,
                                                      placeholder:
                                                          (context, url) =>
                                                              Image(
                                                        image: AssetImage(
                                                            'assets/cover.jpg'),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(150),
                                                        child: Icon(
                                                          Icons.play_circle,
                                                          size: 100,
                                                          color:
                                                              Colors.grey[100],
                                                        )),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                playlists[idx]["songsList"]
                                                    [index]['songTitle'],
                                                textAlign: TextAlign.center,
                                                softWrap: false,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 28,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                '${playlists[idx]["songsList"][index]["artist"]["artistName"]}',
                                                textAlign: TextAlign.center,
                                                softWrap: false,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 24,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                'Producer: ${playlists[idx]["songsList"][index]["producer"]}',
                                                textAlign: TextAlign.center,
                                                softWrap: false,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 22,
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
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  _services.likeSong(
                                                      playlists[idx]
                                                              ["songsList"]
                                                          [index]["songId"]);
                                                },
                                                child: playlists[idx]
                                                                ["songsList"]
                                                            [index]["likes"]
                                                        .contains(
                                                            _services.user.uid)
                                                    ? Icon(
                                                        CustomIcon
                                                            .thumbs_up_alt,
                                                        color: Colors.purple,
                                                        size: 45,
                                                      )
                                                    : Icon(
                                                        CustomIcon.thumbs_up_1,
                                                        size: 45,
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .caption
                                                            .color,
                                                      ),
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
                                          SizedBox(width: 30),
                                          Row(
                                            children: [
                                              Icon(
                                                CustomIcon.headphones_alt,
                                                size: 45,
                                                color:
                                                    playlists[idx]["songsList"]
                                                                    [index]
                                                                ["playCount"] >
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
                                                      [index]["playCount"]))
                                            ],
                                          ),
                                          SizedBox(width: 10),
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
                                                          playlists[idx]["songsList"]
                                                                      [index]
                                                                  ['songImage']
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
                                            iconSize: 45,
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
                  ],
                );
              }),
        );
      },
    );
  }
}
