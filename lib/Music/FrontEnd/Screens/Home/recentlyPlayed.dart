import 'package:wiwa_app/Music/FrontEnd/Screens/Player/audioplayer.dart';
import 'package:wiwa_app/Music/FrontEnd/Screens/Player/downloadPlayer.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

List playlists = [
  {
    "id": "RecentlyPlayed",
    "title": "RecentlyPlayed",
    "image": <DocumentSnapshot>[],
    "songsList": <DocumentSnapshot>[],
    "type": "",
    "artist": <DocumentSnapshot>[],
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

class RecentlyPlayedSongs extends StatefulWidget {
  @override
  _RecentlyPlayedSongsState createState() => _RecentlyPlayedSongsState();
}

class _RecentlyPlayedSongsState extends State<RecentlyPlayedSongs> {
  var recentList = Hive.box('recentlyPlayed').get('recentSongs') ?? [];
  var temp = Hive.box('cache').get('trendingList');

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
  Widget build(BuildContext context) {
    if (!fetched) {
      getCachedPlaylists();
      getPlaylistSongs();
      fetched = true;
    }
    List plst = showCached == true ? cachedPlaylists : null;

    return ListView.builder(
        physics: BouncingScrollPhysics(), //NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        scrollDirection: Axis.vertical,
        itemCount: plst.length,
        // itemCount: cachedPlaylists.length,zz
        // ignore: missing_return
        itemBuilder: (context, idx) {
          if (idx == 0) {
            return (recentList == null)
                ? SizedBox()
                : Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
                            child: Text(
                              'Your Last Session',
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
                        height: 100,
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          itemCount: recentList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  children: [
                                    Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: CachedNetworkImage(
                                        height: 90,
                                        width: 90,
                                        imageUrl: recentList[index]["image"],
                                        fit: BoxFit.cover,
                                        // .replaceAll('http:', 'https:'),
                                        placeholder: (context, url) => Image(
                                          image: AssetImage('assets/cover.jpg'),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${recentList[index]["title"]}',
                                          textAlign: TextAlign.center,
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${recentList[index]["artist"]}',
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
                                                  'response': recentList,
                                                  'index': index,
                                                  'offline': false,
                                                  'recent': true,
                                                  'onlineFav': false,
                                                },
                                                fromMiniplayer: false,
                                              ),
                                            )));
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
          }
        });
  }
}
