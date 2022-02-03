import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:wiwa_app/Music/FrontEnd/Screens/Player/audioplayer.dart';
import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:wiwa_app/helper/customRoute.dart';

List playlists = [
  {
    // "id": "RecentlyPlayed",
    // "title": "RecentlyPlayed",
    // "image": <DocumentSnapshot>[],
    "songsList": <DocumentSnapshot>[],
    // "type": "",
    // "artist": <DocumentSnapshot>[],
    // "likes": <DocumentSnapshot>[],
  }
];
// List cachedPlaylists = [
//   {
//     "id": "RecentlyPlayed",
//     "title": "RecentlyPlayed",
//     "image": "",
//     "songsList": [],
//     "type": ""
//   }
// ];

bool fetched = false;
bool showCached = true;

List preferredLanguage =
    Hive.box('settings').get('preferredLanguage') ?? ['English'];

class HandleRoute {
  Route handleRoute(String songId) {
    // final List<String> paths = url?.replaceAll('?', '/').split('/') ?? [];
    if (songId != null) {
      return PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => SongShareWidget(
          songId: songId,
        ),
      );
    }

    return null;
  }
}

class SongShareWidget extends StatelessWidget {
  final String songId;
  const SongShareWidget({Key key, this.songId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<DocumentSnapshot> topSongsList;

    StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('songs')
            // .doc(widget.songId)
            // .get(),
            .where('songId', isEqualTo: songId)
            .where('published', isEqualTo: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          topSongsList = snapshot.data.docs;
          return null;
        });

    if (topSongsList != null) {
      playlists[0]["songsList"] = topSongsList;
      Navigator.push(
        context,
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => AudioServiceWidget(
            child: PlayScreen(
              data: {
                'response': playlists[0]["songsList"],
                'index': 0,
                'offline': false,
                'recent': false,
                'onlineFav': false,
              },
              fromMiniplayer: false,
            ),
          ),
        ),
      );
    }

    return Container();
  }
}
