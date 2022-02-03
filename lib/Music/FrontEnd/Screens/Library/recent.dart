import 'package:wiwa_app/Music/FrontEnd/CustomWidgets/GradientContainers.dart';
import 'package:wiwa_app/Music/FrontEnd/CustomWidgets/emptyScreen.dart';
import 'package:wiwa_app/Music/FrontEnd/Screens/Player/downloadPlayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wiwa_app/Music/FrontEnd/Screens/Player/audioplayer.dart';
import 'package:wiwa_app/Music/FrontEnd/CustomWidgets/miniplayer.dart';
import 'package:hive/hive.dart';

class RecentlyPlayed extends StatefulWidget {
  @override
  _RecentlyPlayedState createState() => _RecentlyPlayedState();
}

class _RecentlyPlayedState extends State<RecentlyPlayed> {
  List _songs = [];
  bool added = false;

  void getSongs() async {
    await Hive.openBox('recentlyPlayed');
    _songs = Hive.box('recentlyPlayed')?.get('recentSongs') ?? [];
    added = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!added) {
      getSongs();
    }

    return GradientContainer(
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text('Last Session',
                    style: TextStyle(color: Colors.black54)),
                centerTitle: true,
                // backgroundColor: Theme.of(context).brightness == Brightness.dark
                //     ? Colors.transparent
                //     : Theme.of(context).accentColor,
                elevation: 0,
              ),
              body: _songs.isEmpty
                  ? EmptyScreen().emptyScreen(
                      context,
                      3,
                      " ",
                      13,
                      "You haven't played any song on this device",
                      15.0,
                      "Go play a song",
                      18.0)
                  : ListView.builder(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      shrinkWrap: true,
                      itemCount: _songs.length,
                      itemBuilder: (context, index) {
                        return _songs.length == 0
                            ? SizedBox()
                            : SizedBox(
                                child: ListTile(
                                  leading: Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: CachedNetworkImage(
                                      height: 50,
                                      width: 50,
                                      errorWidget: (context, _, __) => Image(
                                        image: AssetImage('assets/cover.jpg'),
                                        fit: BoxFit.cover,
                                      ),
                                      imageUrl: _songs[index]["image"],
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Image(
                                        image: AssetImage('assets/cover.jpg'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                      '${_songs[index]["title"].split("(")[0]}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                      '${_songs[index]["artist"].split("(")[0]}'),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                            opaque: false,
                                            pageBuilder: (_, __, ___) =>
                                                PlayScreen(
                                                  data: {
                                                    'response': _songs,
                                                    'index': index,
                                                    'offline': false,
                                                    'recent': true,
                                                    'onlineFav': false,
                                                  },
                                                  fromMiniplayer: false,
                                                )));
                                  },
                                ),
                              );
                      }),
            ),
          ),
          MiniPlayer(),
        ],
      ),
    );
  }
}

// class RecentlyPlayed extends StatefulWidget {
//   @override
//   _RecentlyPlayedState createState() => _RecentlyPlayedState();
// }

// class _RecentlyPlayedState extends State<RecentlyPlayed> {
//   List _songs = [];
//   bool added = false;

//   void getSongs() async {
//     await Hive.openBox('recentlyPlayed');
//     _songs = Hive.box('recentlyPlayed')?.get('recentSongs') ?? [];

//     added = true;
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!added) {
//       getSongs();
//     }

//     return GradientContainer(
//       child: Column(
//         children: [
//           Expanded(
//             child: Scaffold(
//               backgroundColor: Colors.transparent,
//               appBar: AppBar(
//                 title: Text('Last Session'),
//                 centerTitle: true,
//                 // backgroundColor: Theme.of(context).brightness == Brightness.dark
//                 //     ? Colors.transparent
//                 //     : Theme.of(context).accentColor,
//                 elevation: 0,
//               ),
//               body: _songs.isEmpty
//                   ? EmptyScreen().emptyScreen(context, 3, "", 15,
//                       "Recently played empty", 50.0, "Play a song", 23.0)
//                   : ListView.builder(
//                       physics: BouncingScrollPhysics(),
//                       padding: EdgeInsets.only(top: 10, bottom: 10),
//                       shrinkWrap: true,
//                       itemCount: _songs.length,
//                       itemBuilder: (context, index) {
//                         return _songs.length == 0
//                             ? SizedBox()
//                             : ListTile(
//                                 leading: Container(
//                                   height: 80,
//                                   width: 80,
//                                   child: Card(
//                                     elevation: 5,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(7.0),
//                                     ),
//                                     clipBehavior: Clip.antiAlias,
//                                     child: CachedNetworkImage(
//                                       height: 80,
//                                       width: 80,
//                                       errorWidget: (context, _, __) => Image(
//                                         image: AssetImage('assets/cover.jpg'),
//                                         fit: BoxFit.cover,
//                                       ),
//                                       imageUrl: _songs[index]["image"]
//                                           .replaceAll('http:', 'https:'),
//                                       fit: BoxFit.cover,
//                                       placeholder: (context, url) => Image(
//                                         image: AssetImage('assets/cover.jpg'),
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 title: Text(
//                                     '${_songs[index]["title"].split("(")[0]}'),
//                                 subtitle: Text(
//                                     '${_songs[index]["artist"].split("(")[0]}'),
//                                 onTap: () {
//                                   Navigator.push(
//                                       context,
//                                       PageRouteBuilder(
//                                           opaque: false,
//                                           pageBuilder: (_, __, ___) =>
//                                               PlayScreen(
//                                                 data: {
//                                                   'response': _songs,
//                                                   'index': index,
//                                                   'offline': false,
//                                                   'recent': true,
//                                                 },
//                                                 fromMiniplayer: false,
//                                               )));
//                                 },
//                               );
//                       }),
//             ),
//           ),
//           MiniPlayer(),
//         ],
//       ),
//     );
//   }
// }
