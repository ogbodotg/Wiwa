import 'package:wiwa_app/Music/FrontEnd/Helpers/countrycodes.dart';
import 'package:wiwa_app/Music/FrontEnd/CustomWidgets/gradientContainers.dart';
import 'package:wiwa_app/Music/FrontEnd/Screens/Home/recentlyPlayed.dart';
import 'package:wiwa_app/Music/FrontEnd/Screens/Library/downloaded.dart';
import 'package:wiwa_app/Music/FrontEnd/Screens/Library/library.dart';
import 'package:wiwa_app/Music/FrontEnd/Screens/Settings/setting.dart';
import 'package:wiwa_app/Music/Model/songModel.dart';
import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:wiwa_app/Music/SongDashboard.dart';
import 'package:wiwa_app/Music/Widgets/AllSongSearch.dart';
import 'package:wiwa_app/Music/Widgets/FavouriteSongs.dart';
import 'package:wiwa_app/Music/Widgets/Genres.dart';
import 'package:wiwa_app/Music/Widgets/TopArtists.dart';
import 'package:wiwa_app/state/authState.dart';
import 'package:wiwa_app/state/profile_state.dart';
import 'package:wiwa_app/ui/page/common/sidebar.dart';
import 'package:wiwa_app/widgets/bottomMenuBar/bottomMenuBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:device_info/device_info.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wiwa_app/Music/FrontEnd/CustomWidgets/miniplayer.dart';
import 'package:search_page/search_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import 'trending.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter/cupertino.dart';

class MusicFront extends StatefulWidget {
  static const String id = 'front-end-music';
  const MusicFront({Key key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _MusicFrontState createState() => _MusicFrontState();
}

class _MusicFrontState extends State<MusicFront> {
  static List<AllSongs> allSongs = [];
  String artist;
  DocumentSnapshot document;
  MusicServices _musicServices = MusicServices();

  var recentList = Hive.box('recentlyPlayed').get('recentSongs');
  int _selectedIndex = 0;
  Box settingsBox;
  double appVersion;
  bool checked = false;
  bool update = false;
  bool status = false;

  String capitalize(String msg) {
    return "${msg[0].toUpperCase()}${msg.substring(1)}";
  }

  void callback() {
    setState(() {});
  }

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //     pageController.animateToPage(index,
  //         duration: Duration(milliseconds: 400), curve: Curves.ease);
  //     // duration: Duration(milliseconds: 500), curve: Curves.linear);
  //   });
  // }

  updateUserDetails(String key, dynamic value) {
    final userID = Hive.box('settings').get('userID');
    final dbRef = FirebaseDatabase.instance.reference().child("RhythmUsers");
    dbRef.child(userID).update({"$key": "$value"});
  }

  // Widget checkVersion() {
  //   if (!checked && Theme.of(context).platform == TargetPlatform.android) {
  //     print('checking for update..');
  //     checked = true;
  //     DateTime now = DateTime.now();
  //     // updateUserDetails('lastLogin',
  //     //     '${now.toUtc().add(Duration(hours: 5, minutes: 30)).toString().split('.').first} IST');
  //     // updateUserDetails('timeZone',
  //     //     'Zone: ${now.timeZoneName}, Offset: ${now.timeZoneOffset.toString().split('.').first}');
  //     final tpStatus = FirebaseDatabase.instance.reference().child("TopStatus");
  //     tpStatus.once().then((DataSnapshot snapshot) {
  //       status = snapshot.value;
  //       status ??= true;
  //     });
  //     final dbRef =
  //         FirebaseDatabase.instance.reference().child("LatestVersion");

  //     PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
  //       List temp = packageInfo.version.split('.');
  //       temp.removeLast();
  //       appVersion = double.parse(temp.join('.'));
  //       updateUserDetails('version', appVersion);
  //     });
  //     DeviceInfoPlugin info = DeviceInfoPlugin();
  //     info.androidInfo.then((AndroidDeviceInfo androidInfo) {
  //       Map deviceInfo = {
  //         'Brand': androidInfo.brand,
  //         'Device': androidInfo.device,
  //         'isPhysicalDevice': androidInfo.isPhysicalDevice,
  //         'Model': androidInfo.model,
  //         'Product': androidInfo.product,
  //         'androidVersion': androidInfo.version.release,
  //       };
  //       updateUserDetails('deviceInfo', deviceInfo);
  //     });

  //     dbRef.once().then((DataSnapshot snapshot) {
  //       if (double.parse(snapshot.value) > appVersion) {
  //         print('UPDATE IS AVAILABLE');
  //         return showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return AlertDialog(
  //               title: Text('Update Available',
  //                   style: TextStyle(
  //                       color: Theme.of(context).accentColor,
  //                       fontWeight: FontWeight.w600)),
  //               content: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   SizedBox(
  //                     height: 10,
  //                   ),
  //                   Text(
  //                     'A new update is available. Would you like to update now?',
  //                     // textAlign: TextAlign.center,
  //                   ),
  //                 ],
  //               ),
  //               actions: [
  //                 TextButton(
  //                     style: TextButton.styleFrom(
  //                       primary: Colors.white,
  //                     ),
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                     },
  //                     child: Text('Maybe later')),
  //                 TextButton(
  //                     style: TextButton.styleFrom(
  //                       primary: Colors.white,
  //                       backgroundColor: Theme.of(context).accentColor,
  //                     ),
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                       final dLink = FirebaseDatabase.instance
  //                           .reference()
  //                           .child("LatestLink");
  //                       dLink.once().then((DataSnapshot linkSnapshot) {
  //                         launch(linkSnapshot.value);
  //                       });
  //                     },
  //                     child: Text('Update')),
  //                 SizedBox(
  //                   width: 5,
  //                 ),
  //               ],
  //             );
  //           },
  //         );
  //       }
  //     });
  //     return SizedBox();
  //   } else {
  //     // print('platform not android or already checked');
  //     return SizedBox();
  //   }
  // }

  // ScrollController _scrollController;
  // double _size = 0.0;

  // void _scrollListener() {
  //   setState(() {
  //     _size = _scrollController.offset;
  //   });
  // }

  @override
  void initState() {
    // _scrollController = ScrollController();
    // _scrollController.addListener(_scrollListener);
    _musicServices.songs
        .where('published', isEqualTo: true)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          document = doc;

          allSongs.add(AllSongs(
            genre: doc['genre']['mainGenre'],
            artist: doc['artist']['artistName'],
            songImage: doc['songImage'],
            songTitle: doc['songTitle'],
            album: doc['album'],
            producer: doc['producer'],
            // playCount: doc['playCount'],
            document: doc,
            topSongsList: querySnapshot.docs,
          ));
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    // _scrollController.removeListener(_scrollListener);
    allSongs.clear();

    super.dispose();
  }

  // PageController pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    // var authstate = Provider.of<ProfileState>(context);
    // var state = Provider.of<AuthState>(context);

    return GradientContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.purple),
          centerTitle: true,
          title: Text('Wiwa Music',
              style: TextStyle(
                fontFamily: 'Signatra',
                color: Theme.of(context).primaryColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              )),
          actions: <Widget>[
            IconButton(
                tooltip: 'Upload and publish song or album',
                icon: Icon(Icons.cloud_upload, color: Colors.purple, size: 20),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SongDashBoard()));
                }),
            IconButton(
                tooltip: 'Song dashboard',
                icon:
                    Icon(Icons.dashboard_sharp, color: Colors.purple, size: 20),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LibraryPage()));
                }),
            IconButton(
              tooltip: 'Search for song',
              icon: Icon(Icons.search, color: Colors.purple, size: 20),
              onPressed: () {
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
                          'Filter songs by Song Title, Artist, Producer or Genre',
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
                      builder: (allsongs) => AllSongSearch(
                        allSongs: allsongs,
                        document: allsongs.document,
                        topSongsList: allsongs.topSongsList,
                      ),
                    ));
              },
            ),
          ],
        ),
        // sidewide drawer
        drawer: SidebarMenu(),
        body: SingleChildScrollView(
          child: Container(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(height: 150, child: TopArtists()),
                  recentList == null
                      ? SizedBox()
                      : Container(
                          // height: 150,
                          child: RecentlyPlayedSongs()),
                  // FavouriteSongs(),
                  Container(
                    // height: 220,
                    child: FavouriteSongs(),
                  ),
                  Container(
                      // height: 360,
                      child: TrendingPage()),
                  Container(child: Genres()),
                  MiniPlayer()
                ],
              ),
            ),
          ),
        ),
        // SafeArea(
        //   child: Column(
        //     children: [
        //       Expanded(
        //         child: PageView(
        //           // onPageChanged: (indx) {
        //           //   setState(() {
        //           //     _selectedIndex = indx;
        //           //     if (indx == 0) {
        //           //       try {
        //           //         _size = _scrollController.offset;
        //           //       } catch (e) {}
        //           //     }
        //           //   });
        //           // },
        //           // controller: pageController,
        //           children: [
        //             Stack(
        //               children: [
        //                 // checkVersion(),
        //                 NotificationListener<OverscrollIndicatorNotification>(
        //                   onNotification: (overScroll) {
        //                     overScroll.disallowGlow();
        //                     return;
        //                   },
        //                   child: NestedScrollView(
        //                     physics:
        //                         BouncingScrollPhysics(), //NeverScrollableScrollPhysics(),
        //                     // controller: _scrollController,
        //                     headerSliverBuilder:
        //                         (BuildContext context, bool innerBoxScrolled) {
        //                       // final controller = TextEditingController();
        //                       return <Widget>[
        //                         SliverAppBar(
        //                           expandedHeight: 135,
        //                           backgroundColor: Colors.transparent,
        //                           elevation: 0,
        //                           // pinned: true,
        //                           toolbarHeight: 65,
        //                           // floating: true,
        //                           automaticallyImplyLeading: false,
        //                           flexibleSpace: LayoutBuilder(
        //                             builder: (BuildContext context,
        //                                 BoxConstraints constraints) {
        //                               return FlexibleSpaceBar(
        //                                   background: TopArtists());
        //                             },
        //                           ),
        //                         ),
        //                       ];
        //                     },
        //                     body: PageView(
        //                       children: [
        //                         TopArtists(),
        //                         recentList == null
        //                             ? SizedBox()
        //                             : Container(
        //                                 height: 150,
        //                                 child: Expanded(
        //                                     child: RecentlyPlayedSongs())),
        //                         FavouriteSongs(),
        //                         // Container(
        //                         //   height: 220,
        //                         //   child: FavouriteSongs(),
        //                         // ),
        //                         Container(
        //                             height: 360,
        //                             child: Expanded(child: TrendingPage())),
        //                         Container(height: 250, child: Genres())
        //                       ],
        //                     ),
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           ],
        //         ),
        //       ),
        //       MiniPlayer()
        //     ],
        //   ),
        // ),
        // bottomNavigationBar: BottomMenubar(),
      ),
    );
  }
}
