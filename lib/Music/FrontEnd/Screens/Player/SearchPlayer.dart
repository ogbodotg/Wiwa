import 'dart:async';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:wiwa_app/Music/FrontEnd/CustomWidgets/add_playlist.dart';
import 'package:wiwa_app/Music/FrontEnd/CustomWidgets/downloadButton.dart';
import 'package:wiwa_app/Music/FrontEnd/CustomWidgets/gradientContainers.dart';
import 'package:wiwa_app/Music/FrontEnd/CustomWidgets/likeSong.dart';
import 'package:wiwa_app/Music/FrontEnd/CustomWidgets/like_button.dart';
import 'package:wiwa_app/Music/FrontEnd/Helpers/playlist.dart';
import 'package:wiwa_app/Music/FrontEnd/Services/audioService.dart';
import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:wiwa_app/helper/utility.dart';
import 'package:wiwa_app/ui/theme/custom_icon_icons.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:wiwa_app/Music/FrontEnd/CustomWidgets/emptyScreen.dart';
import 'package:wiwa_app/Music/FrontEnd/CustomWidgets/seekBar.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SearchPlayer extends StatefulWidget {
  final Map data;
  final controller;
  final bool fromMiniplayer;
  SearchPlayer(
      {Key key,
      @required this.data,
      @required this.fromMiniplayer,
      this.controller})
      : super(key: key);
  @override
  _SearchPlayerState createState() => _SearchPlayerState();
}

class _SearchPlayerState extends State<SearchPlayer> {
  MusicServices _services = MusicServices();
  bool fromMiniplayer = false;
  String preferredQuality =
      Hive.box('settings').get('streamingQuality') ?? '96 kbps';
  String preferredDownloadQuality =
      Hive.box('settings').get('downloadQuality') ?? '320 kbps';
  String repeatMode = Hive.box('settings').get('repeatMode') ?? 'None';
  bool stopServiceOnPause =
      Hive.box('settings').get('stopServiceOnPause') ?? true;
  bool shuffle = Hive.box('settings').get('shuffle') ?? false;
  List<MediaItem> globalQueue = [];
  int globalIndex = 0;
  bool same = true;
  // List response = [];
  String song;
  String songTitle;
  String songImage;
  String artist;
  String producer;
  String album;
  int playCount;
  String songId;
  List<DocumentSnapshot> songLikes;
  bool fetched = false;
  bool offline = false;
  bool recent = false;
  MediaItem playItem;
  List likes = [];
  // User user;

  final CarouselController _carouselController = CarouselController();
  // sleepTimer(0) cancels the timer
  void sleepTimer(int time) {
    AudioService.customAction('sleepTimer', time);
  }

  Duration _time;

  void main() async {
    await Hive.openBox('Favorite Songs');
  }

  @override
  void initState() {
    // user = FirebaseAuth.instance.currentUser;
    super.initState();
    main();
  }

  // setTags(Map response, Directory tempDir) async {
  //   String playTitle = response['title'];
  //   playTitle == ''
  //       ? playTitle = response['id']
  //           .split('/')
  //           .last
  //           .replaceAll('.m4a', '')
  //           .replaceAll('.mp3', '')
  //       : playTitle = response['title'];
  //   String playArtist = response['artist'];
  //   playArtist == ''
  //       ? playArtist = response['id']
  //           .split('/')
  //           .last
  //           .replaceAll('.m4a', '')
  //           .replaceAll('.mp3', '')
  //       : playArtist = response['artist'];

  //   String playAlbum = response['album'];
  //   final playDuration = response['duration'] ?? 180;
  //   File file;
  //   if (response['image'] != null) {
  //     try {
  //       file = await File(
  //               '${tempDir.path}/${playTitle.toString().replaceAll('/', '')}-${playArtist.toString().replaceAll('/', '')}.jpg')
  //           .create();
  //       file.writeAsBytesSync(response['image']);
  //     } catch (e) {
  //       file = null;
  //     }
  //   } else {
  //     file = null;
  //   }

  //   MediaItem tempDict = MediaItem(
  //       id: response['id'],
  //       album: playAlbum,
  //       duration: Duration(seconds: playDuration),
  //       title: playTitle != null ? playTitle.split("(")[0] : 'Unknown',
  //       artist: playArtist ?? 'Unknown',
  //       artUri: file == null
  //           ? Uri.file('${(await getTemporaryDirectory()).path}/cover.jpg')
  //               .toString()
  //           : Uri.file('${file.path}'),
  //       extras: {'url': response['id']});
  //   globalQueue.add(tempDict);
  //   setState(() {});
  // }

  // setOffValues(List response) {
  //   getTemporaryDirectory().then((tempDir) async {
  //     final File file =
  //         File('${(await getTemporaryDirectory()).path}/cover.jpg');
  //     if (!await file.exists()) {
  //       final byteData = await rootBundle.load('assets/cover.jpg');
  //       await file.writeAsBytes(byteData.buffer
  //           .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  //     }
  //     for (int i = 0; i < response.length; i++) {
  //       await setTags(response[i], tempDir);
  //     }
  //   });
  // }

  setValues(
    String songId,
    String song,
    String songTitle,
    String songImage,
    String artist,
    String producer,
    String album,
    int playCount,
    // List likes,
    // List response
  ) {
    Map data = widget.data;
    // recent = data['recent'];
    likes.addAll(data['likes']);
    MediaItem tempDict = MediaItem(
        id: song,
        album: album,
        duration: Duration(seconds: 180),
        title: songTitle,
        artist: artist,
        artUri: Uri.parse(songImage),
        genre: artist,
        extras: {
          "url": song,
          "producer": producer,
          "playCount": playCount,
          "songId": songId,
          // "year": response[i]["year"],
          // "language": response[i]["language"],
          // "320kbps": response[i]["320kbps"],
          // "has_lyrics": response[i]["has_lyrics"],
          // "release_date": response[i]["release_date"],
          // "album_id": response[i]["album_id"],
          // "subtitle": response[i]['subtitle']
        });

    globalQueue.add(tempDict);

    fetched = true;
  }

  @override
  Widget build(BuildContext context) {
    print('This is my song ${song}');
    BuildContext scaffoldContext;
    Map data = widget.data;
    // if (songId == data['songId'] && globalIndex == data['index']) {
    //   same = true;
    // }

    // if (response == data['response'] && globalIndex == data['index']) {
    //   same = true;
    // }
    // response = data['response'];
    songId = data['songId'];
    song = data['song'];
    songImage = data['songImage'];
    songTitle = data['songTitle'];
    artist = data['artistName'];
    producer = data['producer'];
    album = data['album'];
    playCount = data['playCount'];
    globalIndex = data['index'];

    if (data['offline'] == null) {
      offline = AudioService.currentMediaItem?.extras['url'].startsWith('http')
          ? false
          : true;
    } else {
      offline = data['offline'];
    }
    fromMiniplayer = false;
    repeatMode = 'None';
    shuffle = false;
    Hive.box('settings').put('repeatMode', repeatMode);
    Hive.box('settings').put('shuffle', shuffle);
    AudioService.stop();
    setValues(
      songId,
      song,
      songTitle,
      songImage,
      artist,
      producer,
      album,
      playCount,
    );
    // if (!fetched) {
    //   if (songId == null) {
    //     fromMiniplayer = true;
    //   } else {
    //     fromMiniplayer = false;
    //     repeatMode = 'None';
    //     shuffle = false;
    //     Hive.box('settings').put('repeatMode', repeatMode);
    //     Hive.box('settings').put('shuffle', shuffle);
    //     AudioService.stop();
    //     setValues(
    //       songId,
    //       song,
    //       songTitle,
    //       songImage,
    //       artist,
    //       producer,
    //       album,
    //       playCount,
    //     );
    //     // if (offline) {
    //     //   // setOffValues(response);
    //     // } else {
    //     //   setValues(
    //     //     songId,
    //     //     song,
    //     //     songTitle,
    //     //     songImage,
    //     //     artist,
    //     //     producer,
    //     //     album,
    //     //     playCount,
    //     //   );
    //     // }
    //   }
    // }
    Widget container = GradientContainer(
      child: SafeArea(
        child: StreamBuilder<QueueState>(
            stream: _queueStateStream,
            builder: (context, snapshot) {
              final queueState = snapshot.data;
              final queue = queueState?.queue ?? [];
              final mediaItem = queueState?.mediaItem;
              return Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  toolbarHeight: 40.0,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  leading: IconButton(
                      icon: Icon(Icons.expand_more_rounded),
                      onPressed: () {
                        if (widget.fromMiniplayer) {
                          widget.controller
                              .animateToHeight(state: PanelState.MIN);
                        } else {
                          Navigator.pop(context);
                        }
                      }),
                  actions: [
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert_rounded),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7.0))),
                      onSelected: (value) {
                        // if (value == 2) {
                        //   showModalBottomSheet(
                        //     isDismissible: true,
                        //     backgroundColor: Colors.transparent,
                        //     context: context,
                        //     builder: (BuildContext context) {
                        //       String lyrics;
                        //       final queueState = snapshot.data;
                        //       final mediaItem = queueState?.mediaItem;

                        //       Future<dynamic> fetchLyrics() {
                        //         Uri lyricsUrl = Uri.https(
                        //             "www.jiosaavn.com",
                        //             "/api.php?__call=lyrics.getLyrics&lyrics_id=" +
                        //                 mediaItem.id +
                        //                 "&ctx=web6dot0&api_version=4&_format=json");
                        //         return get(lyricsUrl,
                        //             headers: {"Accept": "application/json"});
                        //       }

                        //       return mediaItem == null
                        //           ? SizedBox()
                        //           : BottomGradientContainer(
                        //               child: Center(
                        //                 child: SingleChildScrollView(
                        //                   physics: BouncingScrollPhysics(),
                        //                   padding:
                        //                       EdgeInsets.fromLTRB(0, 20, 0, 20),
                        //                   child: mediaItem
                        //                               .extras["has_lyrics"] ==
                        //                           "true"
                        //                       ? FutureBuilder(
                        //                           future: fetchLyrics(),
                        //                           builder: (BuildContext
                        //                                   context,
                        //                               AsyncSnapshot snapshot) {
                        //                             if (snapshot
                        //                                     .connectionState ==
                        //                                 ConnectionState.done) {
                        //                               if (mediaItem.extras[
                        //                                       "has_lyrics"] ==
                        //                                   "true") {
                        //                                 List lyricsEdited =
                        //                                     (snapshot.data.body)
                        //                                         .split("-->");
                        //                                 final fetchedLyrics =
                        //                                     json.decode(
                        //                                         lyricsEdited[
                        //                                             1]);
                        //                                 lyrics = fetchedLyrics[
                        //                                         "lyrics"]
                        //                                     .toString()
                        //                                     .replaceAll(
                        //                                         "<br>", "\n");
                        //                                 return Text(lyrics);
                        //                               }
                        //                             }
                        //                             return CircularProgressIndicator(
                        //                               valueColor:
                        //                                   AlwaysStoppedAnimation<
                        //                                           Color>(
                        //                                       Theme.of(context)
                        //                                           .accentColor),
                        //                             );
                        //                           })
                        //                       : EmptyScreen().emptyScreen(
                        //                           context,
                        //                           0,
                        //                           ":( ",
                        //                           100.0,
                        //                           "Lyrics",
                        //                           60.0,
                        //                           "Not Available",
                        //                           20.0),
                        //                 ),
                        //               ),
                        //             );
                        //     },
                        //   );
                        // }
                        if (value == 1) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return SimpleDialog(
                                title: Center(
                                    child: Text(
                                  'Select a Duration',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).accentColor),
                                )),
                                children: [
                                  Center(
                                      child: SizedBox(
                                    height: 200,
                                    width: 200,
                                    child: CupertinoTheme(
                                      data: CupertinoThemeData(
                                        primaryColor:
                                            Theme.of(context).accentColor,
                                        textTheme: CupertinoTextThemeData(
                                          dateTimePickerTextStyle: TextStyle(
                                            fontSize: 16,
                                            color:
                                                Theme.of(context).accentColor,
                                          ),
                                        ),
                                      ),
                                      child: CupertinoTimerPicker(
                                        mode: CupertinoTimerPickerMode.hm,
                                        onTimerDurationChanged: (value) {
                                          setState(() {
                                            _time = value;
                                          });
                                        },
                                      ),
                                    ),
                                  )),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          primary:
                                              Theme.of(context).accentColor,
                                        ),
                                        child: Text('Cancel'),
                                        onPressed: () {
                                          sleepTimer(0);
                                          Navigator.pop(context);
                                        },
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          primary: Colors.white,
                                          backgroundColor:
                                              Theme.of(context).accentColor,
                                        ),
                                        child: Text('Ok'),
                                        onPressed: () {
                                          sleepTimer(_time.inMinutes);
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(scaffoldContext)
                                              .showSnackBar(
                                            SnackBar(
                                              duration: Duration(seconds: 2),
                                              elevation: 6,
                                              backgroundColor: Colors.grey[900],
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              content: Text(
                                                'Sleep timer set for ${_time.inMinutes} minutes',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              action: SnackBarAction(
                                                textColor: Theme.of(context)
                                                    .accentColor,
                                                label: 'Ok',
                                                onPressed: () {},
                                              ),
                                            ),
                                          );
                                          debugPrint(
                                              'Sleep after ${_time.inMinutes}');
                                        },
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        // if (value == 0) {
                        //   showModalBottomSheet(
                        //       isDismissible: true,
                        //       backgroundColor: Colors.transparent,
                        //       context: context,
                        //       builder: (BuildContext context) {
                        //         final settingsBox = Hive.box('settings');
                        //         List playlistNames =
                        //             settingsBox.get('playlistNames') ?? [];

                        //         return BottomGradientContainer(
                        //           child: SingleChildScrollView(
                        //             child: Column(
                        //               mainAxisSize: MainAxisSize.min,
                        //               children: [
                        //                 ListTile(
                        //                   title: Text('Create Playlist'),
                        //                   leading: Icon(Icons.add_rounded),
                        //                   onTap: () {
                        //                     showDialog(
                        //                       context: context,
                        //                       builder: (BuildContext context) {
                        //                         final controller =
                        //                             TextEditingController();
                        //                         return AlertDialog(
                        //                           content: Column(
                        //                             mainAxisSize:
                        //                                 MainAxisSize.min,
                        //                             children: [
                        //                               Row(
                        //                                 children: [
                        //                                   Text(
                        //                                     'Create new playlist',
                        //                                     style: TextStyle(
                        //                                         color: Theme.of(
                        //                                                 context)
                        //                                             .accentColor),
                        //                                   ),
                        //                                 ],
                        //                               ),
                        //                               SizedBox(
                        //                                 height: 10,
                        //                               ),
                        //                               TextField(
                        //                                   cursorColor:
                        //                                       Theme.of(context)
                        //                                           .accentColor,
                        //                                   controller:
                        //                                       controller,
                        //                                   autofocus: true,
                        //                                   onSubmitted:
                        //                                       (String value) {
                        //                                     if (value.trim() ==
                        //                                         '') {
                        //                                       value =
                        //                                           'Playlist ${playlistNames.length}';
                        //                                     }
                        //                                     if (playlistNames
                        //                                         .contains(
                        //                                             value))
                        //                                       value = value +
                        //                                           ' (1)';
                        //                                     playlistNames
                        //                                         .add(value);
                        //                                     settingsBox.put(
                        //                                         'playlistNames',
                        //                                         playlistNames);
                        //                                     Navigator.pop(
                        //                                         context);
                        //                                   }),
                        //                             ],
                        //                           ),
                        //                           actions: [
                        //                             TextButton(
                        //                               style:
                        //                                   TextButton.styleFrom(
                        //                                 primary: Theme.of(
                        //                                                 context)
                        //                                             .brightness ==
                        //                                         Brightness.dark
                        //                                     ? Colors.white
                        //                                     : Colors.grey[700],
                        //                                 //       backgroundColor: Theme.of(context).accentColor,
                        //                               ),
                        //                               child: Text("Cancel"),
                        //                               onPressed: () {
                        //                                 Navigator.pop(context);
                        //                               },
                        //                             ),
                        //                             TextButton(
                        //                               style:
                        //                                   TextButton.styleFrom(
                        //                                 primary: Colors.white,
                        //                                 backgroundColor:
                        //                                     Theme.of(context)
                        //                                         .accentColor,
                        //                               ),
                        //                               child: Text(
                        //                                 "Ok",
                        //                                 style: TextStyle(
                        //                                     color:
                        //                                         Colors.white),
                        //                               ),
                        //                               onPressed: () {
                        //                                 if (controller.text
                        //                                         .trim() ==
                        //                                     '') {
                        //                                   controller.text =
                        //                                       'Playlist ${playlistNames.length}';
                        //                                 }
                        //                                 if (playlistNames
                        //                                     .contains(controller
                        //                                         .text))
                        //                                   controller.text =
                        //                                       controller.text +
                        //                                           ' (1)';
                        //                                 playlistNames.add(
                        //                                     controller.text);

                        //                                 settingsBox.put(
                        //                                     'playlistNames',
                        //                                     playlistNames);
                        //                                 Navigator.pop(context);
                        //                               },
                        //                             ),
                        //                             SizedBox(
                        //                               width: 5,
                        //                             ),
                        //                           ],
                        //                         );
                        //                       },
                        //                     );
                        //                   },
                        //                 ),
                        //                 playlistNames.isEmpty
                        //                     ? SizedBox()
                        //                     : ListView.builder(
                        //                         physics:
                        //                             NeverScrollableScrollPhysics(),
                        //                         shrinkWrap: true,
                        //                         itemCount: playlistNames.length,
                        //                         itemBuilder: (context, index) {
                        //                           return ListTile(
                        //                               leading: Icon(Icons
                        //                                   .queue_music_rounded),
                        //                               title: Text(
                        //                                   '${playlistNames[index]}'),
                        //                               onTap: () {
                        //                                 Navigator.pop(context);
                        //                                 // checkPlaylist(playlistNames[index],
                        //                                 // mediaItem.id.toString())

                        //                                 // addPlaylist(
                        //                                 //     playlistNames[
                        //                                 //         index],
                        //                                 //     mediaItem
                        //                                 //     );
                        //                                 setState(() {});
                        //                                 ScaffoldMessenger.of(
                        //                                         scaffoldContext)
                        //                                     .showSnackBar(
                        //                                   SnackBar(
                        //                                     duration: Duration(
                        //                                         seconds: 2),
                        //                                     elevation: 6,
                        //                                     backgroundColor:
                        //                                         Colors
                        //                                             .grey[900],
                        //                                     behavior:
                        //                                         SnackBarBehavior
                        //                                             .floating,
                        //                                     content: Text(
                        //                                       'Added to ${playlistNames[index]}',
                        //                                       style: TextStyle(
                        //                                           color: Colors
                        //                                               .white),
                        //                                     ),
                        //                                     action:
                        //                                         SnackBarAction(
                        //                                       textColor: Theme.of(
                        //                                               context)
                        //                                           .accentColor,
                        //                                       label: 'Ok',
                        //                                       onPressed: () {},
                        //                                     ),
                        //                                   ),
                        //                                 );
                        //                               });
                        //                         }),
                        //               ],
                        //             ),
                        //           ),
                        //         );
                        //       });
                        // }
                        if (value == 0) {
                          AddToPlaylist().addToPlaylist(context, mediaItem);
                        }
                      },
                      itemBuilder: (context) => offline
                          ? [
                              PopupMenuItem(
                                  value: 1,
                                  child: Row(
                                    children: [
                                      Icon(CupertinoIcons.timer),
                                      Spacer(),
                                      Text('Sleep Timer'),
                                      Spacer(),
                                    ],
                                  )),
                            ]
                          : [
                              PopupMenuItem(
                                  value: 0,
                                  child: Row(
                                    children: [
                                      Icon(Icons.playlist_add_rounded),
                                      Spacer(),
                                      Text('Add to playlist'),
                                      Spacer(),
                                    ],
                                  )),
                              PopupMenuItem(
                                  value: 1,
                                  child: Row(
                                    children: [
                                      Icon(CupertinoIcons.timer),
                                      Spacer(),
                                      Text('Sleep Timer'),
                                      Spacer(),
                                    ],
                                  )),
                              // PopupMenuItem(
                              //     value: 2,
                              //     child: Row(
                              //       children: [
                              //         Icon(CupertinoIcons.textformat),
                              //         Spacer(),
                              //         Text('Show Lyrics'),
                              //         Spacer(),
                              //       ],
                              //     )),
                            ],
                    )
                  ],
                ),
                body: Builder(builder: (BuildContext context) {
                  scaffoldContext = context;
                  return StreamBuilder<bool>(
                      stream: AudioService.runningStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState !=
                            ConnectionState.active) {
                          return SizedBox();
                        }
                        final running = snapshot.data ?? false;
                        if (running &&
                            AudioService.playbackState?.playing == true &&
                            mediaItem != null) {
                          _services.playCount(mediaItem?.extras['songId']);
                        }

                        return (!running)
                            ? FutureBuilder(
                                future: audioPlayerButton(),
                                builder: (context, AsyncSnapshot spshot) {
                                  if (spshot.hasData) {
                                    return SizedBox();
                                  } else {
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Card(
                                          elevation: 10,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          clipBehavior: Clip.antiAlias,
                                          child: Stack(
                                            children: [
                                              Image(
                                                  fit: BoxFit.cover,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.85,
                                                  image: AssetImage(
                                                      'assets/cover.jpg')),
                                              globalQueue.length <= globalIndex
                                                  ? Image(
                                                      fit: BoxFit.cover,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.85,
                                                      image: AssetImage(
                                                          'assets/cover.jpg'))
                                                  : offline
                                                      ? Image(
                                                          fit: BoxFit.cover,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.85,
                                                          image: FileImage(File(
                                                            globalQueue[
                                                                    globalIndex]
                                                                .artUri
                                                                .toFilePath(),
                                                          )))
                                                      : CachedNetworkImage(
                                                          fit: BoxFit.cover,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.85,
                                                          errorWidget:
                                                              (BuildContext
                                                                          context,
                                                                      _,
                                                                      __) =>
                                                                  Image(
                                                            image: AssetImage(
                                                                'assets/cover.jpg'),
                                                          ),
                                                          placeholder:
                                                              (BuildContext
                                                                          context,
                                                                      _) =>
                                                                  Image(
                                                            image: AssetImage(
                                                                'assets/cover.jpg'),
                                                          ),
                                                          imageUrl: globalQueue[
                                                                  globalIndex]
                                                              .artUri
                                                              .toString(),
                                                        ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              15, 25, 15, 0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                height: (MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.875 -
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.925) *
                                                    2 /
                                                    14.0,
                                                child: FittedBox(
                                                    child: Text(
                                                  globalQueue.length <=
                                                          globalIndex
                                                      ? 'Unknown'
                                                      : globalQueue[globalIndex]
                                                          .title,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 50,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .accentColor),
                                                )),
                                              ),
                                              Text(
                                                globalQueue.length <=
                                                        globalIndex
                                                    ? 'Unknown'
                                                    : globalQueue[globalIndex]
                                                        .artist,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SeekBar(
                                          duration: Duration.zero,
                                          position: Duration.zero,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                SizedBox(height: 6.0),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.shuffle_rounded,
                                                  ),
                                                  iconSize: 25.0,
                                                  onPressed: null,
                                                ),
                                                // if (!offline)
                                                //   IconButton(
                                                //     icon: Icon(
                                                //       Icons
                                                //           .favorite_border_rounded,
                                                //     ),
                                                //     iconSize: 25.0,
                                                //     onPressed: null,
                                                //   ),
                                              ],
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                  Icons.skip_previous_rounded),
                                              iconSize: 45.0,
                                              onPressed: null,
                                            ),
                                            Stack(
                                              children: [
                                                Center(
                                                    child: SizedBox(
                                                  height: 65,
                                                  width: 65,
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Theme.of(context)
                                                                .accentColor),
                                                  ),
                                                )),
                                                Center(
                                                  child: Container(
                                                    height: 65,
                                                    width: 65,
                                                    child: Center(
                                                      child: SizedBox(
                                                        height: 59,
                                                        width: 59,
                                                        child: playButton(),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            IconButton(
                                              icon:
                                                  Icon(Icons.skip_next_rounded),
                                              iconSize: 45.0,
                                              onPressed: null,
                                            ),
                                            Column(
                                              children: [
                                                SizedBox(height: 6.0),
                                                IconButton(
                                                  icon: Icon(
                                                      Icons.repeat_rounded),
                                                  iconSize: 25.0,
                                                  onPressed: null,
                                                ),
                                                // if (!offline)
                                                //   IconButton(
                                                //       icon:
                                                //           Icon(Icons.save_alt),
                                                //       iconSize: 25.0,
                                                //       onPressed: null),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }
                                })
                            : Stack(
                                children: [
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (AudioService
                                                  .playbackState.playing ==
                                              true) {
                                            AudioService.pause();
                                          } else {
                                            AudioService.play();
                                          }
                                        },
                                        child:
                                            (mediaItem != null &&
                                                    queue.isNotEmpty)
                                                ? CarouselSlider(
                                                    carouselController:
                                                        _carouselController,
                                                    options: CarouselOptions(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      autoPlay: false,
                                                      scrollPhysics:
                                                          BouncingScrollPhysics(),
                                                      enableInfiniteScroll:
                                                          repeatMode == 'All',
                                                      enlargeCenterPage: true,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.85,
                                                      initialPage:
                                                          queue.indexWhere(
                                                              (element) =>
                                                                  element ==
                                                                  mediaItem),
                                                      enlargeStrategy:
                                                          CenterPageEnlargeStrategy
                                                              .scale,
                                                      onPageChanged:
                                                          (index, reason) {
                                                        AudioService
                                                            .skipToQueueItem(
                                                                queue[index]
                                                                    .id);
                                                      },
                                                    ),
                                                    items: queue
                                                        .map(
                                                          (item) => Card(
                                                            elevation: 10,
                                                            margin:
                                                                EdgeInsets.zero,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15)),
                                                            clipBehavior:
                                                                Clip.antiAlias,
                                                            // color: Colors.red,
                                                            child: Center(
                                                              child: Stack(
                                                                children: [
                                                                  SizedBox
                                                                      .expand(
                                                                    child:
                                                                        Image(
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      image: AssetImage(
                                                                          'assets/cover.jpg'),
                                                                    ),
                                                                  ),
                                                                  SizedBox
                                                                      .expand(
                                                                    child: offline
                                                                        ? Image(fit: BoxFit.cover, image: FileImage(File(item.artUri.toFilePath())))
                                                                        : CachedNetworkImage(
                                                                            fit: BoxFit.cover,
                                                                            errorWidget: (BuildContext context, _, __) => Image(
                                                                                  image: AssetImage('assets/cover.jpg'),
                                                                                ),
                                                                            placeholder: (BuildContext context, _) => Image(
                                                                                  image: AssetImage('assets/cover.jpg'),
                                                                                ),
                                                                            imageUrl: item.artUri.toString()),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                        .toList())
                                                : Card(
                                                    elevation: 10,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15)),
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    child: Stack(
                                                      children: [
                                                        Image(
                                                            fit: BoxFit.cover,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.85,
                                                            image: AssetImage(
                                                                'assets/cover.jpg')),
                                                        if (globalQueue.length >
                                                            globalIndex)
                                                          offline
                                                              ? Image(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.85,
                                                                  image:
                                                                      FileImage(
                                                                          File(
                                                                    globalQueue[
                                                                            globalIndex]
                                                                        .artUri
                                                                        .toFilePath(),
                                                                  )))
                                                              : CachedNetworkImage(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  errorWidget:
                                                                      (BuildContext context,
                                                                              _,
                                                                              __) =>
                                                                          Image(
                                                                    image: AssetImage(
                                                                        'assets/cover.jpg'),
                                                                  ),
                                                                  placeholder:
                                                                      (BuildContext context,
                                                                              _) =>
                                                                          Image(
                                                                    image: AssetImage(
                                                                        'assets/cover.jpg'),
                                                                  ),
                                                                  imageUrl: globalQueue[
                                                                          globalIndex]
                                                                      .artUri
                                                                      .toString(),
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.85,
                                                                ),
                                                      ],
                                                    ),
                                                  ),
                                      ),
                                      // Likes, playCount, bookmark
                                      (recent == true)
                                          ? SizedBox()
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    mediaItem == null
                                                        ? IconButton(
                                                            icon: Icon(
                                                              CustomIcon
                                                                  .thumbs_up_alt,
                                                              // size: 25,
                                                            ),
                                                            iconSize: 40,
                                                            color: Colors.grey,
                                                            onPressed: null)
                                                        : Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              InkWell(
                                                                onTap: () {
                                                                  _services.likeSong(
                                                                      mediaItem
                                                                              .extras[
                                                                          "songId"]);
                                                                },
                                                                child: likes.contains(
                                                                        _services
                                                                            .user
                                                                            .uid)
                                                                    ? Icon(
                                                                        CustomIcon
                                                                            .thumbs_up_alt,
                                                                        color: Colors
                                                                            .purple,
                                                                        size:
                                                                            40,
                                                                      )
                                                                    : Icon(
                                                                        CustomIcon
                                                                            .thumbs_up_alt,
                                                                        size:
                                                                            40,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                              ),

                                                              // LikeSong(
                                                              //     mediaItem:
                                                              //         mediaItem,
                                                              //     likes: likes,
                                                              //     size: 34),
                                                              SizedBox(
                                                                  width: 3),
                                                              Text(_services
                                                                  .formatNumber(
                                                                      likes
                                                                          .length)
                                                                  .toString())
                                                            ],
                                                          ),
                                                    SizedBox(
                                                      width: 20,
                                                    ),
                                                    mediaItem == null ||
                                                            mediaItem?.extras[
                                                                    'playCount'] ==
                                                                null
                                                        ? IconButton(
                                                            icon: Icon(
                                                              CustomIcon
                                                                  .headphones_alt,
                                                              // Icons
                                                              //   .play_circle_fill_sharp
                                                            ),
                                                            onPressed: () {},
                                                            iconSize: 40,
                                                            color: Colors.grey,
                                                          )
                                                        : Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              IconButton(
                                                                icon: Icon(
                                                                  CustomIcon
                                                                      .headphones_alt,
                                                                  // Icons
                                                                  //   .play_circle_fill_sharp
                                                                ),
                                                                onPressed:
                                                                    () {},
                                                                iconSize: 40,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                              ),
                                                              SizedBox(
                                                                  width: 2),
                                                              Text(_services
                                                                  .formatNumber(
                                                                      mediaItem
                                                                              ?.extras[
                                                                          'playCount'])
                                                                  .toString())
                                                            ],
                                                          ),
                                                  ],
                                                ),
                                                SizedBox(width: 20),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    mediaItem == null
                                                        ? Row(
                                                            children: [
                                                              IconButton(
                                                                  icon: Icon(Icons
                                                                      .bookmark_border),
                                                                  iconSize: 40,
                                                                  color: Colors
                                                                      .grey,
                                                                  onPressed:
                                                                      null),
                                                              IconButton(
                                                                  icon: Icon(Icons
                                                                      .share),
                                                                  iconSize: 40,
                                                                  color: Colors
                                                                      .grey,
                                                                  onPressed:
                                                                      null),
                                                            ],
                                                          )
                                                        : Row(
                                                            children: [
                                                              LikeButton(
                                                                  mediaItem:
                                                                      mediaItem,
                                                                  size: 40),
                                                              IconButton(
                                                                icon: Icon(
                                                                    Icons.share
                                                                    // CustomIcon.share_1,
                                                                    ),
                                                                onPressed:
                                                                    () async {
                                                                  var socialMetaTagParameters = SocialMetaTagParameters(
                                                                      description:
                                                                          "${mediaItem.title} by ${mediaItem.artist}" ??
                                                                              "",
                                                                      title:
                                                                          "${mediaItem.artist} on Wiwa Music",
                                                                      imageUrl: Uri.parse(mediaItem
                                                                          .artUri
                                                                          .toString()));
                                                                  // Navigator.pop(context);
                                                                  var url = Utility
                                                                      .createLinkToShare(
                                                                    context,
                                                                    "songs/${mediaItem.extras["songId"]}",
                                                                    socialMetaTagParameters:
                                                                        socialMetaTagParameters,
                                                                  );
                                                                  var uri =
                                                                      await url;
                                                                  Utility.share(
                                                                      uri
                                                                          .toString(),
                                                                      subject:
                                                                          "${mediaItem.title} by ${mediaItem.artist} on Wiwa Music");
                                                                },
                                                                iconSize: 40,
                                                                color: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .caption
                                                                    .color,
                                                              ),
                                                            ],
                                                          ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                      (recent)
                                          ? mediaItem == null
                                              ? Row(
                                                  children: [
                                                    IconButton(
                                                        icon: Icon(Icons
                                                            .bookmark_border),
                                                        iconSize: 40,
                                                        color: Colors.grey,
                                                        onPressed: null),
                                                    IconButton(
                                                        icon: Icon(Icons.share),
                                                        iconSize: 40,
                                                        color: Colors.grey,
                                                        onPressed: null),
                                                  ],
                                                )
                                              : Row(
                                                  children: [
                                                    LikeButton(
                                                        mediaItem: mediaItem,
                                                        size: 40),
                                                    IconButton(
                                                      icon: Icon(Icons.share
                                                          // CustomIcon.share_1,
                                                          ),
                                                      onPressed: () async {
                                                        var socialMetaTagParameters =
                                                            SocialMetaTagParameters(
                                                                description:
                                                                    "${mediaItem.title} by ${mediaItem.artist}" ??
                                                                        "",
                                                                title:
                                                                    "${mediaItem.artist} on Wiwa Music",
                                                                imageUrl: Uri.parse(
                                                                    mediaItem
                                                                        .artUri
                                                                        .toString()));
                                                        // Navigator.pop(context);
                                                        var url = Utility
                                                            .createLinkToShare(
                                                          context,
                                                          "songs/${mediaItem.extras["songId"]}",
                                                          socialMetaTagParameters:
                                                              socialMetaTagParameters,
                                                        );
                                                        var uri = await url;
                                                        Utility.share(
                                                            uri.toString(),
                                                            subject:
                                                                "${mediaItem.title} by ${mediaItem.artist} on Wiwa Music");
                                                      },
                                                      iconSize: 40,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .caption
                                                          .color,
                                                    ),
                                                  ],
                                                )
                                          : SizedBox(),

                                      /// Like, Bookmark, Title and subtitle
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            15, 0, 15, 0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            /// Title container
                                            Container(
                                              height: (MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.875 -
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.925) *
                                                  2 /
                                                  14.0,
                                              child: FittedBox(
                                                  child: Text(
                                                (mediaItem?.title != null)
                                                    ? (mediaItem.title)
                                                    : ((globalQueue.length <=
                                                            globalIndex)
                                                        ? 'Title'
                                                        : globalQueue[
                                                                globalIndex]
                                                            .title),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 50,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .accentColor),
                                              )),
                                            ),

                                            /// Subtitle container
                                            Column(
                                              children: [
                                                Container(
                                                  height: (MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.875 -
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.925) *
                                                      1 /
                                                      12.0,
                                                  child: Text(
                                                    (mediaItem?.artist != null)
                                                        ? (mediaItem.artist)
                                                        : ((globalQueue
                                                                    .length <=
                                                                globalIndex)
                                                            ? ''
                                                            : globalQueue[
                                                                    globalIndex]
                                                                .artist),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 19,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                mediaItem == null ||
                                                        mediaItem.extras[
                                                                'producer'] ==
                                                            null
                                                    ? SizedBox()
                                                    : Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text('Producer: ',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      18)),
                                                          Text(
                                                            (mediaItem?.extras[
                                                                        'producer'] !=
                                                                    null)
                                                                ? (mediaItem
                                                                        ?.extras[
                                                                    'producer'])
                                                                : ((globalQueue
                                                                            .length <=
                                                                        globalIndex)
                                                                    ? ''
                                                                    : globalQueue[globalIndex]
                                                                            .extras[
                                                                        'producer']),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      /// Seekbar starts from here
                                      StreamBuilder<MediaState>(
                                        stream: _mediaStateStream,
                                        builder: (context, snapshot) {
                                          final mediaState = snapshot.data;
                                          return SeekBar(
                                            duration: mediaState
                                                    ?.mediaItem?.duration ??
                                                Duration.zero,
                                            position: mediaState?.position ??
                                                Duration.zero,
                                            onChangeEnd: (newPosition) {
                                              AudioService.seekTo(newPosition);
                                            },
                                          );
                                        },
                                      ),

                                      /// Final row starts from here
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            children: [
                                              SizedBox(height: 6.0),
                                              IconButton(
                                                icon:
                                                    Icon(Icons.shuffle_rounded),
                                                iconSize: 25.0,
                                                color: shuffle
                                                    ? Theme.of(context)
                                                        .accentColor
                                                    : null,
                                                onPressed: () {
                                                  shuffle = !shuffle;
                                                  Hive.box('settings')
                                                      .put('shuffle', shuffle);
                                                  AudioService.customAction(
                                                      'shuffle', shuffle);
                                                  setState(() {});
                                                },
                                              ),
                                              // if (!offline)
                                              //   mediaItem == null
                                              //       ? IconButton(
                                              //           icon: Icon(Icons
                                              //               .favorite_border_rounded),
                                              //           iconSize: 25.0,
                                              //           onPressed: null)
                                              //       : LikeButton(
                                              //           mediaItem: mediaItem,
                                              //           size: 25.0)
                                            ],
                                          ),
                                          (queue.isNotEmpty)
                                              ? IconButton(
                                                  icon: Icon(Icons
                                                      .skip_previous_rounded),
                                                  iconSize: 45.0,
                                                  onPressed: (mediaItem ==
                                                              queue.first ||
                                                          mediaItem == null)
                                                      ? null
                                                      : () {
                                                          AudioService
                                                              .skipToPrevious();
                                                          _carouselController
                                                              .previousPage();
                                                        })
                                              : IconButton(
                                                  icon: Icon(Icons
                                                      .skip_previous_rounded),
                                                  iconSize: 45.0,
                                                  onPressed: null),

                                          /// Play button
                                          Stack(
                                            children: [
                                              Center(
                                                child: StreamBuilder<
                                                    AudioProcessingState>(
                                                  stream: AudioService
                                                      .playbackStateStream
                                                      .map((state) =>
                                                          state.processingState)
                                                      .distinct(),
                                                  builder: (context, snapshot) {
                                                    final processingState =
                                                        snapshot.data ??
                                                            AudioProcessingState
                                                                .none;
                                                    return describeEnum(
                                                                processingState) !=
                                                            'ready'
                                                        ? SizedBox(
                                                            height: 65,
                                                            width: 65,
                                                            child:
                                                                CircularProgressIndicator(
                                                              valueColor: AlwaysStoppedAnimation<
                                                                  Color>(Theme.of(
                                                                      context)
                                                                  .accentColor),
                                                            ),
                                                          )
                                                        : SizedBox();
                                                  },
                                                ),
                                              ),
                                              Center(
                                                child: StreamBuilder<bool>(
                                                  stream: AudioService
                                                      .playbackStateStream
                                                      .map((state) =>
                                                          state.playing)
                                                      .distinct(),
                                                  builder: (context, snapshot) {
                                                    final playing =
                                                        snapshot.data ?? false;
                                                    return Container(
                                                      height: 65,
                                                      width: 65,
                                                      child: Center(
                                                        child: SizedBox(
                                                          height: 59,
                                                          width: 59,
                                                          child: playing
                                                              ? pauseButton()
                                                              : playButton(),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),

                                          (queue.isNotEmpty)
                                              ? IconButton(
                                                  icon: Icon(
                                                      Icons.skip_next_rounded),
                                                  iconSize: 45.0,
                                                  onPressed: (mediaItem ==
                                                              queue.last ||
                                                          mediaItem == null)
                                                      ? null
                                                      : () {
                                                          AudioService
                                                              .skipToNext();
                                                          _carouselController
                                                              .nextPage();
                                                        })
                                              : IconButton(
                                                  icon: Icon(
                                                      Icons.skip_next_rounded),
                                                  iconSize: 45.0,
                                                  onPressed: null),

                                          Column(
                                            children: [
                                              SizedBox(height: 6.0),
                                              IconButton(
                                                icon: repeatMode == 'One'
                                                    ? Icon(Icons
                                                        .repeat_one_rounded)
                                                    : Icon(
                                                        Icons.repeat_rounded),
                                                iconSize: 25.0,
                                                color: repeatMode == 'None'
                                                    ? null
                                                    : Theme.of(context)
                                                        .accentColor,
                                                // Icons.repeat_one_rounded
                                                onPressed: () {
                                                  if (repeatMode == 'None') {
                                                    repeatMode = 'All';
                                                  } else {
                                                    if (repeatMode == 'All') {
                                                      repeatMode = 'One';
                                                    } else {
                                                      repeatMode = 'None';
                                                    }
                                                  }
                                                  Hive.box('settings').put(
                                                      'repeatMode', repeatMode);
                                                  AudioService.customAction(
                                                      'repeatMode', repeatMode);
                                                  setState(() {});
                                                },
                                              ),
                                              // if (!offline)
                                              //   (mediaItem != null &&
                                              //           queue.isNotEmpty)
                                              //       ? DownloadButton(data: {
                                              //           'id': mediaItem.id
                                              //               .toString(),
                                              //           'artist': mediaItem
                                              //               .artist
                                              //               .toString(),
                                              //           'album': mediaItem.album
                                              //               .toString(),
                                              //           'image': mediaItem
                                              //               .artUri
                                              //               .toString(),
                                              //           'duration': mediaItem
                                              //               .duration.inSeconds
                                              //               .toString(),
                                              //           'title': mediaItem.title
                                              //               .toString(),
                                              //           'url': mediaItem
                                              //               .extras['url']
                                              //               .toString(),
                                              //           "year": mediaItem
                                              //               .extras["year"]
                                              //               .toString(),
                                              //           "language": mediaItem
                                              //               .extras["language"]
                                              //               .toString(),
                                              //           "genre": mediaItem.genre
                                              //               .toString(),
                                              //           "320kbps": mediaItem
                                              //               .extras["320kbps"],
                                              //           "has_lyrics":
                                              //               mediaItem.extras[
                                              //                   "has_lyrics"],
                                              //           "release_date":
                                              //               mediaItem.extras[
                                              //                   "release_date"],
                                              //           "album_id": mediaItem
                                              //               .extras["album_id"],
                                              //           "subtitle": mediaItem
                                              //               .extras["subtitle"]
                                              //         })
                                              //       // : IconButton(
                                              //     icon: Icon(
                                              //       Icons.save_alt,
                                              //     ),
                                              //     iconSize: 25.0,
                                              //     onPressed: null),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 45,
                                      ),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: SizedBox(
                                      height: 500,
                                      child: DraggableScrollableSheet(
                                          initialChildSize: 0.1,
                                          minChildSize: 0.1,
                                          maxChildSize: 1,
                                          builder: (BuildContext context,
                                              ScrollController
                                                  scrollController) {
                                            return BottomGradientContainer(
                                              padding: EdgeInsets.zero,
                                              margin: EdgeInsets.only(
                                                  left: 20, right: 20),
                                              borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(15.0),
                                                  topRight:
                                                      Radius.circular(15.0)),
                                              child: (mediaItem == null ||
                                                      queue.isEmpty)
                                                  ? SizedBox()
                                                  : ReorderableListView.builder(
                                                      header: SizedBox(
                                                        key: Key('head'),
                                                        height: 50,
                                                        child: Center(
                                                          child: Text(
                                                            'Now Playing',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      scrollController:
                                                          scrollController,
                                                      onReorder: (int oldIndex,
                                                          int newIndex) {
                                                        setState(() {
                                                          if (newIndex >
                                                              oldIndex) {
                                                            newIndex -= 1;
                                                          }
                                                          final items =
                                                              queue.removeAt(
                                                                  oldIndex);
                                                          queue.insert(
                                                              newIndex, items);
                                                          AudioService
                                                              .updateQueue(
                                                                  queue);
                                                          int newMediaIndex =
                                                              queue.indexWhere(
                                                                  (element) =>
                                                                      element ==
                                                                      mediaItem);
                                                          AudioService
                                                              .customAction(
                                                                  'changeIndex',
                                                                  newMediaIndex);
                                                          _carouselController
                                                              .jumpToPage(
                                                                  newMediaIndex);
                                                        });
                                                      },
                                                      physics:
                                                          BouncingScrollPhysics(),
                                                      padding: EdgeInsets.only(
                                                          top: 0, bottom: 10),
                                                      shrinkWrap: true,
                                                      itemCount: queue.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Dismissible(
                                                          key: Key(
                                                              queue[index].id),
                                                          direction: queue[
                                                                      index] ==
                                                                  mediaItem
                                                              ? DismissDirection
                                                                  .none
                                                              : DismissDirection
                                                                  .horizontal,
                                                          onDismissed: (dir) {
                                                            setState(() {
                                                              queue.remove(
                                                                  queue[index]);
                                                              AudioService
                                                                  .updateQueue(
                                                                      queue);
                                                              int newIndex = queue
                                                                  .indexWhere((element) =>
                                                                      element ==
                                                                      mediaItem);
                                                              AudioService
                                                                  .customAction(
                                                                      'changeIndex',
                                                                      newIndex);
                                                              _carouselController
                                                                  .jumpToPage(
                                                                      newIndex);
                                                            });
                                                          },
                                                          child: ListTileTheme(
                                                            selectedColor: Theme
                                                                    .of(context)
                                                                .accentColor,
                                                            child: ListTile(
                                                              contentPadding:
                                                                  EdgeInsets.only(
                                                                      left:
                                                                          16.0,
                                                                      right:
                                                                          10.0),
                                                              selected: queue[
                                                                      index] ==
                                                                  mediaItem,
                                                              trailing: queue[
                                                                          index] ==
                                                                      mediaItem
                                                                  ? IconButton(
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .bar_chart_rounded,
                                                                      ),
                                                                      onPressed:
                                                                          () {},
                                                                    )
                                                                  : offline
                                                                      ? SizedBox()
                                                                      : Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            // mediaItem == null
                                                                            //     ? IconButton(icon: Icon(Icons.favorite_border), iconSize: 34.0, onPressed: null)
                                                                            // : Row(
                                                                            //     children: [
                                                                            //       InkWell(
                                                                            //           onTap: () {
                                                                            //             _services.likeSong(mediaItem.extras["songId"]);
                                                                            //           },
                                                                            //           child: likes.contains(_services.user.uid) ? Icon(Icons.favorite, color: Colors.redAccent, size: 40) : Icon(Icons.favorite_border, size: 40)),

                                                                            //       // LikeSong(
                                                                            //       //     mediaItem:
                                                                            //       //         mediaItem,
                                                                            //       //     likes: likes,
                                                                            //       //     size: 34),
                                                                            //       SizedBox(width: 5),
                                                                            //       Text(_services.formatNumber(likes.length).toString())
                                                                            //     ],
                                                                            //   ),
                                                                            LikeButton(
                                                                              mediaItem: queue[index],
                                                                            ),

                                                                            // DownloadButton(icon: 'download', data: {
                                                                            //   'id': queue[index].id.toString(),
                                                                            //   'artist': queue[index].artist.toString(),
                                                                            //   'album': queue[index].album.toString(),
                                                                            //   'image': queue[index].artUri.toString(),
                                                                            //   'duration': queue[index].duration.inSeconds.toString(),
                                                                            //   'title': queue[index].title.toString(),
                                                                            //   'url': queue[index].extras['url'].toString(),
                                                                            //   "year": queue[index].extras["year"].toString(),
                                                                            //   "language": queue[index].extras["language"].toString(),
                                                                            //   "genre": queue[index].genre.toString(),
                                                                            //   "320kbps": queue[index].extras["320kbps"],
                                                                            //   "has_lyrics": queue[index].extras["has_lyrics"],
                                                                            //   "release_date": queue[index].extras["release_date"],
                                                                            //   "album_id": queue[index].extras["album_id"],
                                                                            //   "subtitle": queue[index].extras["subtitle"]
                                                                            // })
                                                                          ],
                                                                        ),
                                                              leading: Card(
                                                                elevation: 5,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              7.0),
                                                                ),
                                                                clipBehavior: Clip
                                                                    .antiAlias,
                                                                child: Stack(
                                                                  children: [
                                                                    Image(
                                                                        image: AssetImage(
                                                                            'assets/cover.jpg'),
                                                                        fit: BoxFit
                                                                            .cover),
                                                                    queue[index].artUri ==
                                                                            null
                                                                        ? SizedBox()
                                                                        : queue[index].artUri.toString().startsWith(
                                                                                'file:')
                                                                            ? Image(
                                                                                image: FileImage(File(queue[index].artUri.toFilePath())),
                                                                                fit: BoxFit.cover)
                                                                            : CachedNetworkImage(
                                                                                height: 50,
                                                                                width: 50,
                                                                                errorWidget: (BuildContext context, _, __) => Image(image: AssetImage('assets/cover.jpg'), fit: BoxFit.cover),
                                                                                placeholder: (BuildContext context, _) => Image(image: AssetImage('assets/cover.jpg'), fit: BoxFit.cover),
                                                                                imageUrl: queue[index].artUri.toString(),
                                                                                fit: BoxFit.cover,
                                                                              )
                                                                  ],
                                                                ),
                                                              ),
                                                              title: Text(
                                                                '${queue[index].title}',
                                                                style: TextStyle(
                                                                    fontWeight: queue[index] ==
                                                                            mediaItem
                                                                        ? FontWeight
                                                                            .w600
                                                                        : FontWeight
                                                                            .normal),
                                                              ),
                                                              subtitle: Text(
                                                                '${queue[index].artist}',
                                                              ),
                                                              onTap: () {
                                                                AudioService
                                                                    .skipToQueueItem(
                                                                        queue[index]
                                                                            .id);
                                                                _carouselController
                                                                    .jumpToPage(
                                                                        index);
                                                              },
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                            );
                                          }),
                                    ),
                                  ),
                                ],
                              );
                      });
                }),
              );
            }),
      ),
      // ),
    );
    return widget.fromMiniplayer
        ? container
        : Dismissible(
            direction: DismissDirection.down,
            background: Container(color: Colors.transparent),
            key: Key('PlayScreen'),
            onDismissed: (direction) {
              Navigator.pop(context);
            },
            child: container);
  }

  /// A stream reporting the combined state of the current media item and its
  /// current position.
  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem, Duration, MediaState>(
          AudioService.currentMediaItemStream,
          AudioService.positionStream,
          (mediaItem, position) => MediaState(mediaItem, position));

  /// A stream reporting the combined state of the current queue and the current
  /// media item within that queue.
  Stream<QueueState> get _queueStateStream =>
      Rx.combineLatest2<List<MediaItem>, MediaItem, QueueState>(
          AudioService.queueStream,
          AudioService.currentMediaItemStream,
          (queue, mediaItem) => QueueState(queue, mediaItem));

  audioPlayerButton() async {
    await AudioService.start(
      backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
      params: {
        'index': globalIndex,
        'offline': offline,
        'quality': preferredQuality
      },
      androidNotificationChannelName: 'Wiwa Music',
      androidNotificationColor: 0xFF9C27B0,
      androidNotificationIcon: 'drawable/wiwaicon',
      androidEnableQueue: true,
      androidStopForegroundOnPause: stopServiceOnPause,
    );

    await AudioService.updateQueue(globalQueue);
    // AudioService.setRepeatMode(AudioServiceRepeatMode.all);
    // await AudioService.setShuffleMode(AudioServiceShuffleMode.all);
    await AudioService.play();
  }

  IconButton playButton() => IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: 50.0,
        onPressed: AudioService.play,
      );

  IconButton pauseButton() => IconButton(
        icon: Icon(Icons.pause),
        iconSize: 50.0,
        onPressed: AudioService.pause,
      );

  IconButton stopButton() => IconButton(
        icon: Icon(Icons.stop),
        iconSize: 50.0,
        onPressed: AudioService.stop,
      );
}

class QueueState {
  final List<MediaItem> queue;
  final MediaItem mediaItem;

  QueueState(this.queue, this.mediaItem);
}

class MediaState {
  final MediaItem mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}

void _audioPlayerTaskEntrypoint() async {
  // AudioServiceBackground.run(() => AudioPlayerTask());
}
