import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:wiwa_app/Music/FrontEnd/Screens/Player/audioplayer.dart';
import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:wiwa_app/ahia/Providers/StoreProvider.dart';
import 'package:wiwa_app/ahia/Services/ProductServices.dart';
import 'package:wiwa_app/ahia/Widgets/Cart/CartNotification.dart';
import 'package:wiwa_app/ahia/Widgets/Products/FavouriteProductCard.dart';
import 'package:wiwa_app/ahia/Widgets/Products/ProductCardWidget.dart';
import 'package:wiwa_app/ahia/Widgets/Products/ProductFilterWidget.dart';
import 'package:wiwa_app/helper/utility.dart';
import 'package:wiwa_app/ui/theme/custom_icon_icons.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiwa_app/widgets/newWidget/emptyList.dart';

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

class BookMarkedSongs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MusicServices _services = MusicServices();
    User user = FirebaseAuth.instance.currentUser;
    List<DocumentSnapshot> albumSongsList;
    return StreamBuilder<QuerySnapshot>(
      stream: _services.favouriteSongs
          .doc(user.uid)
          .collection('songs')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return SingleChildScrollView(
            child: SizedBox(
              height: 3,
              child: LinearProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData) {
          return SingleChildScrollView(
            child: SizedBox(
              height: 3,
              child: LinearProgressIndicator(),
            ),
          );
        }
        if (snapshot.data.docs.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: EmptyList(
              'You have not bookmarked any song yet',
              subTitle: 'Bookmarked songs appear here.',
            ),
          );
          // Center(
          //     child: Text('You have not bookmarked any song',
          //         style: TextStyle(fontSize: 16)));
        }

        albumSongsList = snapshot.data.docs;

        return SingleChildScrollView(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListView.builder(
                  physics:
                      BouncingScrollPhysics(), //NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  scrollDirection: Axis.vertical,
                  itemCount: playlists.length,
                  itemBuilder: (context, idx) {
                    playlists[idx]["songsList"] = albumSongsList;

                    return playlists[idx]["songsList"] == null
                        ? SizedBox(
                            height: 200,
                            child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                itemCount: 10,
                                itemBuilder: (context, index) {
                                  return SizedBox(
                                    // height: 150,
                                    child: Column(
                                      children: [
                                        Card(
                                          elevation: 1,
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
                        : Container(
                            color: Colors.white,
                            child: SizedBox(
                              // height: 150,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                itemCount: playlists[idx]["songsList"].length,
                                itemBuilder: (context, index) {
                                  return SafeArea(
                                    child: Row(
                                      // mainAxisSize: MainAxisSize.min,
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
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  clipBehavior: Clip.antiAlias,
                                                  child: CachedNetworkImage(
                                                    height: 120,
                                                    width: 120,
                                                    errorWidget:
                                                        (context, _, __) =>
                                                            Image(
                                                      image: AssetImage(
                                                          'assets/cover.jpg'),
                                                    ),
                                                    imageUrl: playlists[idx]
                                                            ["songsList"][index]
                                                        ['artUri'],
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (context, url) => Image(
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
                                                      'onlineFav': true,
                                                    },
                                                    fromMiniplayer: false,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
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
                                                  playlists[idx]["songsList"]
                                                      [index]['title'],
                                                  textAlign: TextAlign.center,
                                                  softWrap: false,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    // color: Theme.of(context).accentColor
                                                  ),
                                                ),
                                                Text(
                                                  '${playlists[idx]["songsList"][index]["artist"]}',
                                                  textAlign: TextAlign.center,
                                                  softWrap: false,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .caption
                                                          .color),
                                                ),
                                                Text(
                                                  'Producer: ${playlists[idx]["songsList"][index]['extras']["producer"]}',
                                                  textAlign: TextAlign.center,
                                                  softWrap: false,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .caption
                                                          .color),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: 15),
                                            Row(
                                              children: [
                                                Icon(
                                                  // Icons.play_circle_fill_sharp,
                                                  CustomIcon.headphones_alt,
                                                  size: 25,
                                                  color:
                                                      playlists[idx]["songsList"]
                                                                          [
                                                                          index]
                                                                      [
                                                                      'extras']
                                                                  [
                                                                  "playCount"] >
                                                              0
                                                          ? Theme.of(
                                                                  context)
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
                                                        ['extras']["playCount"])
                                                    .toString()),
                                                SizedBox(width: 15),
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
                                                                            [
                                                                            index]
                                                                        [
                                                                        'songImage']
                                                                    .toString()));
                                                    // Navigator.pop(
                                                    //     context);
                                                    var url = Utility
                                                        .createLinkToShare(
                                                      context,
                                                      "songs/${playlists[idx]["songsList"][index]["songId"]}",
                                                      socialMetaTagParameters:
                                                          socialMetaTagParameters,
                                                    );
                                                    var uri = await url;
                                                    Utility.share(
                                                        uri.toString(),
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
                            ),
                          );
                  })
            ],
          ),
        );
      },
    );
  }
}
