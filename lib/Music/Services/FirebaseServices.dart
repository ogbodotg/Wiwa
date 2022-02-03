import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:wiwa_app/Music/FrontEnd/CustomWidgets/like_button.dart';
import 'package:wiwa_app/helper/constant.dart';
import 'package:wiwa_app/helper/utility.dart';
import 'package:wiwa_app/model/feedModel.dart';
import 'package:wiwa_app/state/authState.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:wiwa_app/widgets/customWidgets.dart';

class MusicServices {
  User user = FirebaseAuth.instance.currentUser;
  CollectionReference songs = FirebaseFirestore.instance.collection('songs');

  CollectionReference artists =
      FirebaseFirestore.instance.collection('artists');

  CollectionReference genre = FirebaseFirestore.instance.collection('genre');

  CollectionReference favouriteSongs =
      FirebaseFirestore.instance.collection('favouriteSongs');

  CollectionReference albums = FirebaseFirestore.instance.collection('albums');

  bool liked = false;
  // LikeButton bookmarkSong = LikeButton(mediaItem: mediaItem);

  Future<void> publishSong({id}) {
    return songs.doc(id).update({
      'published': true,
    });
  }

  Future<void> unPublishSong({id}) {
    return songs.doc(id).update({
      'published': false,
    });
  }

  Future<void> deleteSong({id}) {
    return songs.doc(id).delete();
  }

  getTopPickedArtists() {
    return artists
        .where('accountVerified', isEqualTo: true)
        .where('isTopArtist', isEqualTo: true)
        .snapshots();
  }

  formatNumber(int number) {
    var formatedNumber = NumberFormat.compact().format(number);
    return formatedNumber;
  }

  // play counts and artist total songs play counts

  playCount(String songId) async {
    int playCount;
    int totalPlayCount;

    DocumentSnapshot document = await songs.doc(songId).get();
    if (document.exists) {
      playCount = document['playCount'];

      songs.doc(songId).update({
        'playCount': playCount + 1,
      });
      // totalPlayCounts(document.data()['artist']['artistUid']);
      DocumentSnapshot artistDoc =
          await artists.doc(document['artist']['artistUid']).get();
      if (artistDoc.exists) {
        totalPlayCount = artistDoc['playCount'];
        artists.doc(document['artist']['artistUid']).update({
          'playCount': totalPlayCount + 1,
        });
      }
    } else {}
  }

  // like song
  Future likeSong(String songId) async {
    DocumentSnapshot document = await songs.doc(songId).get();
    if (document['likes'].contains(user.uid)) {
      songs.doc(songId).update({
        'likes': FieldValue.arrayRemove([user.uid]),
      });
    } else {
      songs.doc(songId).update({
        'likes': FieldValue.arrayUnion([user.uid]),
      });
    }
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  final dbRef = FirebaseDatabase.instance.reference().child("Users");

  Future sendAnalytics(name) async {
    // final FirebaseAnalytics analytics = FirebaseAnalytics();

    DatabaseReference pushedPostRef = dbRef.push();
    String postId = pushedPostRef.key;
    pushedPostRef.set({
      "name": name,
      "userID": user.uid,
      "country": "",
      "streamingQuality": "",
      "downloadQuality": "",
      "darkMode": "",
      "themeColor": "",
      "colorHue": "",
    });
    Hive.box('settings').put('userID', postId);

    analytics.logEvent(
      name: 'NewUser',
      parameters: <String, dynamic>{
        'Name': name,
      },
    );
  }

  // Song Bookmark
  Future<void> addToFavourite(DocumentSnapshot document, String docId) {
    User user = FirebaseAuth.instance.currentUser;
    return favouriteSongs.doc(user.uid).collection('songs').doc(docId).set(
          document.data(),
        );
  }

  // Share and Bookmark widget
  Widget iconWidget(BuildContext context,
      {String text,
      IconData icon,
      Function onPressed,
      IconData sysIcon,
      Color iconColor,
      // List song,
      double size = 20}) {
    return Expanded(
      child: Container(
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: () {
                if (onPressed != null) onPressed();
              },
              icon: sysIcon != null
                  ? Icon(sysIcon, color: iconColor, size: size)
                  : customIcon(
                      context,
                      size: size,
                      icon: icon,
                      istwitterIcon: true,
                      iconColor: iconColor,
                    ),
            ),
            customText(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: iconColor,
                fontSize: size - 5,
              ),
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  // share widget
  void shareSong(BuildContext context, String songId) async {
    openShareSongBottomSheet(context, songId);
  }

  // Widget sheet row
  Widget widgetBottomSheetRow(BuildContext context, IconData icon,
      {String text, Function onPressed, bool isEnable = false}) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            customIcon(
              context,
              icon: icon,
              istwitterIcon: true,
              size: 25,
              paddingIcon: 8,
              iconColor:
                  onPressed != null ? AppColor.darkGrey : AppColor.lightGrey,
            ),
            SizedBox(
              width: 15,
            ),
            customText(
              text,
              context: context,
              style: TextStyle(
                color: isEnable ? AppColor.secondary : AppColor.lightGrey,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        ),
      ).ripple(() {
        if (onPressed != null)
          onPressed();
        else {
          Navigator.pop(context);
        }
      }),
    );
  }

  void openShareSongBottomSheet(BuildContext context, String songId) async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
            padding: EdgeInsets.only(top: 5, bottom: 0),
            height: 120,
            width: MediaQuery.of(context).size.width,
            // width: context.width,
            decoration: BoxDecoration(
              color: Theme.of(context).bottomSheetTheme.backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: _shareSong(context, songId));
      },
    );
  }

  _shareSong(BuildContext context, String songId) async {
    // final state = context.watch<AuthState>();
    DocumentSnapshot document = await songs.doc(songId).get();
    var socialMetaTagParameters = SocialMetaTagParameters(
        description: document['songTitle'] ?? "",
        title:
            "${document["artist"]["artistName"]} Published a Song on Wiwa Music.",
        imageUrl: Uri.parse(document['songImage']));
    return Column(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          height: 5,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
        SizedBox(height: 8),
        widgetBottomSheetRow(
          context,
          AppIcon.bookmark,
          isEnable: true,
          text: 'Bookmark Song',
          onPressed: () async {
            addToFavourite(document.data(), songId);
            // var state = Provider.of<FeedState>(context, listen: false);
            // await state.addBookmark(model.key);
            Navigator.pop(context);
            ScaffoldMessenger.maybeOf(context).showSnackBar(
              SnackBar(content: Text("Song Added to Bookmark")),
            );
          },
        ),
        SizedBox(height: 8),
        widgetBottomSheetRow(
          context,
          AppIcon.link,
          isEnable: true,
          text: 'Share Song',
          onPressed: () async {
            Navigator.pop(context);
            var url = Utility.createLinkToShare(
              context,
              // "${model.key}",
              "songs/$songId",
              // "${model.key}",
              socialMetaTagParameters: socialMetaTagParameters,
            );
            var uri = await url;
            Utility.share(uri.toString(), subject: "Song on Wiwa Music");
          },
        ),
      ],
    );
  }
}
