import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:wiwa_app/Music/FrontEnd/Screens/Player/audioplayer.dart';
import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
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

class TrendingPage extends StatefulWidget {
  @override
  _TrendingPageState createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  List<DocumentSnapshot> topSongsList;
  MusicServices _services = MusicServices();
  ScrollController _rightController = ScrollController();
  final _width = 50.0;
  _animateToIndex(i) => _rightController.animateTo(_width * i,
      duration: Duration(seconds: 2), curve: Curves.fastOutSlowIn);

  var temp = Hive.box('cache').get('trendingList');
  List preferredLanguage =
      Hive.box('settings').get('preferredLanguage') ?? ['English'];

  getPlaylists() async {
    final dbRef = FirebaseDatabase.instance.reference().child("Playlists");
    for (int a = 0; a < preferredLanguage.length; a++) {
      await dbRef
          .child(preferredLanguage[a])
          .once()
          .then((DataSnapshot snapshot) {
        playlists.addAll(snapshot.value);
        Hive.box('cache').put(preferredLanguage[a], snapshot.value);
      });
    }
  }

  getPlaylistSongs() async {
    await getPlaylists();
    for (int i = 1; i < playlists.length; i++) {
      try {
        // playlists[i] = await Playlist().fetchPlaylistSongs(playlists[i]);
        if (playlists[i]["songsList"].isNotEmpty) {
          Hive.box('cache').put(playlists[i]["id"], playlists[i]);
        }
      } catch (e) {
        print("Error in Index $i in TrendingList: $e");
      }
    }
    setState(() {
      cachedPlaylists = playlists;
      showCached = false;
    });
  }

  getCachedPlaylists() async {
    for (int a = 0; a < preferredLanguage.length; a++) {
      Iterable value = await Hive.box('cache').get(preferredLanguage[a]);
      if (value == null) return;
      cachedPlaylists.addAll(value);
    }
    if (cachedPlaylists.length <= 1) return;
    for (int i = 1; i < cachedPlaylists.length; i++) {
      try {
        cachedPlaylists[i] =
            await Hive.box('cache').get(cachedPlaylists[i]["id"]);
      } catch (e) {
        print("Error in Index $i in CachedTrendingList: $e");
      }
    }
    setState(() {});
  }

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
          .where('isTopPicked', isEqualTo: true)
          .where('published', isEqualTo: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
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
              playlists[idx]["likes"] = topSongsList[idx]['likes'];
              // playlists[idx]["title"] = topSongsList[idx]['songTitle'];
              // playlists[idx]["artist"] =
              //     topSongsList[idx]['artist']['artistName'];
              return Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
                        child: Text(
                          'Top Picked Songs',
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
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
                                      ),
                            body: CupertinoScrollbar(
                              // controller: _rightController,
                              thickness: 3.0,
                              thicknessWhileDragging: 5,
                              // isAlwaysShown: true,
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                controller: _rightController,
                                // reverse: true,
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                itemCount: playlists[idx]["songsList"].length,
                                itemBuilder: (context, index) {
                                  return SafeArea(
                                    child: Column(
                                      // mainAxisAlignment:
                                      //     MainAxisAlignment.spaceEvenly,
                                      children: [
                                        GestureDetector(
                                          child: SizedBox(
                                            width: 220,
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
                                                    height: 200,
                                                    width: 200,
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
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
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
                                          // mainAxisAlignment:
                                          //     MainAxisAlignment.spaceEvenly,
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
                                                          .contains(_services
                                                              .user.uid)
                                                      ? Icon(
                                                          // AppIcon.heartFill,
                                                          CustomIcon
                                                              .thumbs_up_alt,
                                                          color: Colors.purple,
                                                          size: 25,
                                                        )
                                                      : Icon(
                                                          CustomIcon
                                                              .thumbs_up_1,
                                                          size: 25,
                                                          color:
                                                              Theme.of(context)
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
                                            SizedBox(width: 15),
                                            Row(
                                              children: [
                                                Icon(
                                                  // CustomIcon.play_1,
                                                  // Icon(
                                                  //   Icons.play_circle_fill_sharp,
                                                  CustomIcon.headphones_alt,
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
