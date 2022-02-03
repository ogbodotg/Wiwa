import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:wiwa_app/Music/FrontEnd/Screens/Player/audioplayer.dart';
import 'package:wiwa_app/Music/Providers/AlbumProvider.dart';
import 'package:wiwa_app/Music/Providers/ArtistProvider.dart';
import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:wiwa_app/Services/SocialMediaServices.dart';
import 'package:wiwa_app/ahia/Providers/StoreProvider.dart';
import 'package:wiwa_app/ahia/Services/ProductServices.dart';
import 'package:wiwa_app/ahia/Widgets/Products/ProductCardWidget.dart';
import 'package:wiwa_app/ahia/Widgets/Products/ProductFilterWidget.dart';
import 'package:wiwa_app/helper/utility.dart';
import 'package:wiwa_app/ui/theme/custom_icon_icons.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

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

class AlbumSongsList extends StatefulWidget {
  @override
  _AlbumSongsListState createState() => _AlbumSongsListState();
}

class _AlbumSongsListState extends State<AlbumSongsList> {
  SocialMediaServices _smServices = SocialMediaServices();

  @override
  void initState() {
    _smServices.mySmallBanner.load();
    super.initState();
  }

  @override
  void dispose() {
    _smServices.mySmallBanner.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _artist = Provider.of<ArtistProvider>(context);
    MusicServices _services = MusicServices();
    var _albumProvider = Provider.of<AlbumProvider>(context);
    List<DocumentSnapshot> albumSongsList;
    return StreamBuilder<QuerySnapshot>(
      stream: _services.songs
          .where('published', isEqualTo: true)
          .where('album', isEqualTo: _albumProvider.selectedSongAlbum)
          // .where('category.subCategory',
          //     isEqualTo: _storeProvider.selectedSubCategory)
          .where('artist.artistUid',
              isEqualTo: _artist.artistDetails['artistUid'])
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data.docs.isEmpty) {
          return Container();
        }
        albumSongsList = snapshot.data.docs;

        return Column(
          children: [
            Container(
                width: _smServices.mySmallBanner.size.width.toDouble(),
                height: _smServices.mySmallBanner.size.height.toDouble(),
                child: AdWidget(ad: _smServices.mySmallBanner)),
            Material(
              elevation: 0,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                height: 25,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: FittedBox(
                      child: Row(
                    children: [
                      snapshot.data.docs.length <= 1
                          ? Text('${snapshot.data.docs.length} Song',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold))
                          : Text('${snapshot.data.docs.length} Songs',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  )),
                ),
              ),
            ),
            ListView.builder(
                physics:
                    BouncingScrollPhysics(), //NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                scrollDirection: Axis.vertical,
                itemCount: playlists.length,
                itemBuilder: (context, idx) {
                  playlists[idx]["songsList"] = albumSongsList;

                  return playlists[idx]["songsList"] == null
                      ? SizedBox(
                          height: 200,
                          child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              itemCount: 10,
                              itemBuilder: (context, index) {
                                return SizedBox(
                                  // height: 150,
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
                          height: MediaQuery.of(context).size.height,
                          child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            itemCount: playlists[idx]["songsList"].length,
                            itemBuilder: (context, index) {
                              return SafeArea(
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      child: SizedBox(
                                        // width:
                                        //     MediaQuery.of(context).size.width,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Card(
                                              elevation: 5,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              child: CachedNetworkImage(
                                                height: 120,
                                                width: 120,
                                                errorWidget: (context, _, __) =>
                                                    Image(
                                                  image: AssetImage(
                                                      'assets/cover.jpg'),
                                                ),
                                                imageUrl: playlists[idx]
                                                        ["songsList"][index]
                                                    ['songImage'],
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Image(
                                                  image: AssetImage(
                                                      'assets/cover.jpg'),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
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
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          // mainAxisAlignment:
                                          //     MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              playlists[idx]["songsList"][index]
                                                  ['songTitle'],
                                              textAlign: TextAlign.center,
                                              softWrap: false,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                // color: Theme.of(context).accentColor
                                              ),
                                            ),
                                            Text(
                                              '${playlists[idx]["songsList"][index]["artist"]["artistName"]}',
                                              textAlign: TextAlign.center,
                                              softWrap: false,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .caption
                                                      .color),
                                            ),
                                            Text(
                                              'Producer: ${playlists[idx]["songsList"][index]["producer"]}',
                                              textAlign: TextAlign.center,
                                              softWrap: false,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .caption
                                                      .color),
                                            ),
                                          ],
                                        ),
                                        Row(
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
                                                        // Padding(
                                                        //     padding:
                                                        //         const EdgeInsets
                                                        //                 .only(
                                                        //             bottom:
                                                        //                 9.0),
                                                        //     child: Icon(
                                                        //       // AppIcon.heartFill,
                                                        //       CustomIcon
                                                        //           .thumbs_up_alt,
                                                        //       color:
                                                        //           Colors.purple,
                                                        //       size: 25,
                                                        //     ),
                                                        //   )
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
                                                    //       CustomIcon
                                                    //           .thumbs_up_alt,
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
                                                Text(_services
                                                    .formatNumber(playlists[idx]
                                                            ["songsList"][index]
                                                        ["playCount"])
                                                    .toString())
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
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                })
          ],
        );
      },
    );
  }
}
