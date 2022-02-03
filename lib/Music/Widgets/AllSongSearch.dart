import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:wiwa_app/Music/FrontEnd/Screens/Player/SearchPlayer.dart';
import 'package:wiwa_app/Music/FrontEnd/Screens/Player/audioplayer.dart';
import 'package:wiwa_app/Music/Model/songModel.dart';
import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:wiwa_app/ahia/Models/ProductModel.dart';
import 'package:wiwa_app/ahia/Pages/ProductDetails.dart';
import 'package:wiwa_app/ahia/Widgets/Cart/Counter.dart';
import 'package:wiwa_app/helper/utility.dart';
import 'package:wiwa_app/ui/theme/custom_icon_icons.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

List playlists = [
  {
    "id": "RecentlyPlayed",
    "title": "RecentlyPlayed",
    "image": DocumentSnapshot,
    "songsList": DocumentSnapshot,
    "song": DocumentSnapshot,
    "songTitle": DocumentSnapshot,
    "genre": DocumentSnapshot,
    "album": DocumentSnapshot,
    "type": "",
    "artist": DocumentSnapshot,
    "likes": <DocumentSnapshot>[],
  }
];

class AllSongSearch extends StatefulWidget {
  final AllSongs allSongs;
  final DocumentSnapshot document;
  final List<DocumentSnapshot> topSongsList;

  AllSongSearch({Key key, this.allSongs, this.document, this.topSongsList})
      : super(key: key);

  @override
  _AllSongSearchState createState() => _AllSongSearchState();
}

class _AllSongSearchState extends State<AllSongSearch> {
  MusicServices _services = MusicServices();
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        scrollDirection: Axis.vertical,
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          playlists[index]["songsList"] = widget.topSongsList;
          playlists[index]["song"] = widget.allSongs.document['song'];
          playlists[index]["image"] = widget.allSongs.document['songImage'];
          playlists[index]["songTitle"] = widget.allSongs.document['songTitle'];
          playlists[index]["artist"] =
              widget.allSongs.document['artist']['artistName'];
          // playlists[index]["genre"] =
          //     widget.allSongs.document.data()['gerne']['mainGenre'];
          playlists[index]["album"] = widget.allSongs.document['album'];
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
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: CachedNetworkImage(
                            height: 120,
                            width: 120,
                            errorWidget: (context, _, __) => Image(
                              image: AssetImage('assets/cover.jpg'),
                            ),
                            imageUrl: widget.allSongs.document['songImage'],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Image(
                              image: AssetImage('assets/cover.jpg'),
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
                        pageBuilder: (_, __, ___) => AudioServiceWidget(
                          child: SearchPlayer(
                            data: {
                              // 'response': playlists[index]["songsList"],
                              'songId': widget.allSongs.document['songId'],
                              'song': widget.allSongs.document['song'],
                              'songImage':
                                  widget.allSongs.document['songImage'],
                              'songTitle':
                                  widget.allSongs.document['songTitle'],
                              'artistName': widget.allSongs.document['artist']
                                  ['artistName'],
                              'producer': widget.allSongs.document['producer'],
                              'album': widget.allSongs.document['album'],
                              'playCount':
                                  widget.allSongs.document['playCount'],
                              'likes': widget.allSongs.document['likes'],
                              'index': 0,
                              'offline': false,
                              'recent': false,
                            },
                            fromMiniplayer: false,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment:
                      //     MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.allSongs.document['songTitle'],
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
                          '${widget.allSongs.document["artist"]["artistName"]}',
                          textAlign: TextAlign.center,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).primaryColor),
                        ),
                        Text(
                          '${widget.allSongs.document['genre']['mainGenre']}',
                          textAlign: TextAlign.center,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).textTheme.caption.color),
                        ),
                        Text(
                          'Producer: ${widget.allSongs.document['producer']}',
                          textAlign: TextAlign.center,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).textTheme.caption.color),
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
                                      widget.allSongs.document["songId"]);
                                },
                                child: widget.allSongs.document['likes']
                                        .contains(_services.user.uid)
                                    ? Icon(
                                        // AppIcon.heartFill,
                                        CustomIcon.thumbs_up_alt,
                                        color: Colors.purple,
                                        size: 25,
                                      )
                                    : Icon(
                                        CustomIcon.thumbs_up_1,
                                        size: 25,
                                        color: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .color,
                                      )
                                // Padding(
                                //     padding:
                                //         const EdgeInsets.only(bottom: 9.0),
                                //     child: Icon(
                                //       // AppIcon.heartFill,
                                //       CustomIcon.thumbs_up_alt,
                                //       color: Colors.purple,
                                //       size: 25,
                                //     ),
                                //   )
                                // : Padding(
                                //     padding:
                                //         const EdgeInsets.only(bottom: 9.0),
                                //     child: Icon(
                                //       CustomIcon.thumbs_up_1,
                                //       size: 25,
                                //     ),
                                //   )
                                ),
                            SizedBox(
                              width: 3,
                            ),
                            Text(_services
                                .formatNumber(
                                    widget.allSongs.document['likes'].length)
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
                              color: widget.allSongs.document["playCount"] > 0
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).textTheme.caption.color,
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Text(_services
                                .formatNumber(
                                    widget.allSongs.document["playCount"])
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
                            var socialMetaTagParameters = SocialMetaTagParameters(
                                description:
                                    "${widget.allSongs.document['songTitle']} by ${widget.allSongs.document["artist"]["artistName"]}" ??
                                        "",
                                title:
                                    "${widget.allSongs.document["artist"]["artistName"]} on Wiwa Music",
                                imageUrl: Uri.parse(widget
                                    .allSongs.document['songImage']
                                    .toString()));
                            // Navigator.pop(
                            //     context);
                            var url = Utility.createLinkToShare(
                              context,
                              "songs/${widget.allSongs.document["songId"]}",
                              socialMetaTagParameters: socialMetaTagParameters,
                            );
                            var uri = await url;
                            Utility.share(uri.toString(),
                                subject:
                                    "${widget.allSongs.document['songTitle']} by ${widget.allSongs.document["artist"]["artistName"]} on Wiwa Music");
                          },
                          iconSize: 25,
                          color: Theme.of(context).textTheme.caption.color,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        });

    // return Container(
    //   height: 160,
    //   width: MediaQuery.of(context).size.width,
    //   decoration: BoxDecoration(
    //     border: Border(bottom: BorderSide(width: 1, color: Colors.grey[300])),
    //   ),
    //   child: Padding(
    //     padding: const EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
    //     child: Row(children: [
    //       Stack(
    //         children: [
    //           Material(
    //             elevation: 5,
    //             borderRadius: BorderRadius.circular(10),
    //             child: InkWell(
    //               onTap: () {
    //                 // pushNewScreenWithRouteSettings(
    //                 //   context,
    //                 //   settings: RouteSettings(name: ProductDetails.id),
    //                 //   screen: ProductDetails(document: allProducts.document),
    //                 //   withNavBar: true,
    //                 //   pageTransitionAnimation:
    //                 //       PageTransitionAnimation.cupertino,
    //                 // );
    //               },
    //               child: SizedBox(
    //                 height: 140,
    //                 width: 130,
    //                 child: ClipRRect(
    //                     borderRadius: BorderRadius.circular(10),
    //                     child: Hero(
    //                         tag: 'song${allSongs.document.data()['songTitle']}',
    //                         child: Image.network(
    //                             allSongs.document.data()['songImage']))),
    //               ),
    //             ),
    //           ),
    //           Container(
    //             decoration: BoxDecoration(
    //               // color: Theme.of(context).primaryColor,
    //               color: Colors.red,
    //               borderRadius: BorderRadius.only(
    //                 topLeft: Radius.circular(10),
    //                 bottomRight: Radius.circular(10),
    //               ),
    //             ),
    //             child: Padding(
    //               padding: const EdgeInsets.only(
    //                   left: 10, right: 10, top: 3, bottom: 3),
    //               child: Text(
    //                 allSongs.document.data()['genre']['mainGenre'],
    //                 style: TextStyle(color: Colors.white),
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //       Padding(
    //         padding: const EdgeInsets.only(left: 8, top: 5),
    //         child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               Container(
    //                 child: Column(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: [
    //                       Text(
    //                         allSongs.document.data()['playCount'].toString(),
    //                         style: TextStyle(fontSize: 10),
    //                       ),
    //                       SizedBox(height: 5),
    //                       Text(
    //                         allSongs.document.data()['songTitle'],
    //                         style: TextStyle(fontWeight: FontWeight.bold),
    //                       ),
    //                       SizedBox(height: 5),
    //                       Column(
    //                         children: [
    //                           Text(
    //                               allSongs.document.data()['artist']
    //                                   ['artistName'],
    //                               style:
    //                                   TextStyle(fontWeight: FontWeight.bold)),
    //                           SizedBox(width: 10),
    //                           Text(
    //                               'Producer: ${allSongs.document.data()['producer']}',
    //                               style: TextStyle(
    //                                   decoration: TextDecoration.lineThrough,
    //                                   fontWeight: FontWeight.bold,
    //                                   color: Colors.grey,
    //                                   fontSize: 12))
    //                         ],
    //                       ),
    //                     ]),
    //               ),
    //             ]),
    //       )
    //     ]),
    //   ),
    // );
  }
}
