import 'package:wiwa_app/Music/FrontEnd/CustomWidgets/gradientContainers.dart';
import 'package:wiwa_app/Music/FrontEnd/CustomWidgets/miniplayer.dart';
import 'package:wiwa_app/Music/Providers/ArtistProvider.dart';
import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:wiwa_app/Music/Widgets/Albums.dart';
import 'package:wiwa_app/Music/Widgets/ArtistAppBar.dart';
import 'package:wiwa_app/Music/Widgets/ArtistSongs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArtistHomeScreen extends StatelessWidget {
  static const String id = 'artist-home-screen';
  @override
  Widget build(BuildContext context) {
    // StoreProvider _storeData = StoreProvider();
    return GradientContainer(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              ArtistAppBar(),
              // VendorAppBar(),
            ];
          },
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      // Container(
                      //     height: 400,
                      //     child: Expanded(child: ArtistSongListWidget())),
                      Container(height: 400, child: AllSongsOnArtistHome()),
                      Container(height: 330, child: ArtistAlbum()),
                    ],
                  ),
                ),
                MiniPlayer()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
