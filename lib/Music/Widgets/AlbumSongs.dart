import 'package:wiwa_app/Music/FrontEnd/CustomWidgets/gradientContainers.dart';
import 'package:wiwa_app/Music/FrontEnd/CustomWidgets/miniplayer.dart';
import 'package:wiwa_app/Music/Providers/AlbumProvider.dart';
import 'package:wiwa_app/Music/Widgets/AlbumSongsList.dart';
import 'package:wiwa_app/ahia/Providers/StoreProvider.dart';
import 'package:wiwa_app/ahia/Widgets/Products/ProductFilterWidget.dart';
import 'package:wiwa_app/ahia/Widgets/Products/ProductListWidget.dart';
import 'package:wiwa_app/ahia/Widgets/VendorAppBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlbumSongs extends StatelessWidget {
  static const String id = 'album-songs';
  @override
  Widget build(BuildContext context) {
    // var _storeProvider = Provider.of<StoreProvider>(context);
    var _albumProvider = Provider.of<AlbumProvider>(context);
    return GradientContainer(
      child: Scaffold(
          body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              snap: true,
              title: Text(
                _albumProvider.selectedSongAlbum,
                // style: TextStyle(color: Colors.black87)
              ),
              iconTheme: IconThemeData(
                color: Colors.purple,
              ),
              // expandedHeight: 110,
              // flexibleSpace: Padding(
              //   padding: EdgeInsets.only(top: 88),
              //   child: Container(
              //     height: 56,
              //     color: Colors.grey,
              //     // child: ProductFilterWidget(),
              //   ),
              // ),
            ),
          ];
        },
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: [
                    AlbumSongsList(),
                  ],
                ),
              ),
              MiniPlayer()
            ],
          ),
        ),
      )),
    );
  }
}
