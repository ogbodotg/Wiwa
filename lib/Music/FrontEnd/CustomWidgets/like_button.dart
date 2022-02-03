import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:audio_service/audio_service.dart';
import 'package:wiwa_app/Music/FrontEnd/Helpers/playlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LikeButton extends StatefulWidget {
  final MediaItem mediaItem;
  final double size;
  const LikeButton({Key key, @required this.mediaItem, this.size})
      : super(key: key);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool liked = false;
  User user = FirebaseAuth.instance.currentUser;
  MusicServices musicServices = MusicServices();

  // Add song to favourite
  Future<void> addSongToFavourite(docId) {
    return musicServices.favouriteSongs
        .doc(user.uid)
        .collection('songs')
        .doc(docId)
        .set(
          widget.mediaItem.toJson(),
        );
    // .collection('favourites')
    // .add(
    //   widget.mediaItem.toJson(),
    // );
  }

  // From song to favourite
  Future<void> removeFromFavourite(docId) async {
    musicServices.favouriteSongs
        .doc(user.uid)
        .collection('songs')
        .doc(docId)
        .delete();
  }

  // Check if song exists in favouriteSong collection
  checkSongInFavourite(docId) async {
    musicServices.favouriteSongs
        .doc(user.uid)
        .collection('songs')
        .doc(docId)
        .get()
        .then((DocumentSnapshot document) {
      if (document.exists) {
        liked = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaItem != null) {
      try {
        liked = checkSongInFavourite(widget.mediaItem.extras['songId']) ||
            checkPlaylist('Favorite Songs', widget.mediaItem.id);
        // checkSongInFavourite(widget.mediaItem.id).then((value) {
        //   if (value != null) {
        //     checkPlaylist('Favorite Songs', widget.mediaItem.id);
        //   }
        // });
      } catch (e) {}
    }
    return IconButton(
        icon: Icon(
          liked ? Icons.bookmark : Icons.bookmark_border,
          color: liked ? Colors.purple : Colors.grey,
        ),
        iconSize: widget.size ?? 24.0,
        tooltip: liked ? 'Unlike' : 'Like',
        onPressed: () {
          liked
              ? removeFromFavourite(widget.mediaItem.extras['songId'])
                  .then((value) {
                  removeLiked(widget.mediaItem.id);
                })
              : EasyLoading.show(status: 'Adding song to Bookmark Playlist');

          addSongToFavourite(widget.mediaItem.extras['songId']).then((value) {
            ScaffoldMessenger.maybeOf(context).showSnackBar(
                SnackBar(content: Text("Bookmarked playlist updated")));
            EasyLoading.showSuccess('');
          });
          addItemToPlaylist('Favorite Songs', widget.mediaItem);

          setState(() {
            liked = !liked;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 2),
              action: SnackBarAction(
                  textColor: Theme.of(context).accentColor,
                  label: 'Undo',
                  onPressed: () {
                    liked
                        ? removeFromFavourite(widget.mediaItem.extras['songId'])
                            .then((value) {
                            removeLiked(widget.mediaItem.id);
                          })
                        : EasyLoading.show(
                            status: 'Adding song to Bookmark Playlist');

                    addSongToFavourite(widget.mediaItem.extras['songId'])
                        .then((value) {
                      ScaffoldMessenger.maybeOf(context).showSnackBar(SnackBar(
                          content: Text("Bookmarked playlist updated")));
                      EasyLoading.showSuccess('');
                    });
                    addItemToPlaylist('Favorite Songs', widget.mediaItem);
                    liked = !liked;
                    setState(() {});
                  }),
              elevation: 6,
              backgroundColor: Colors.grey[900],
              behavior: SnackBarBehavior.floating,
              content: Text(
                liked ? 'Added to Favorites' : 'Removed from Favorites',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        });
  }
}
// class LikeButton extends StatefulWidget {
//   // final DocumentSnapshot document;
//   final MediaItem mediaItem;
//   final double size;
//   const LikeButton({Key key, @required this.mediaItem, this.size})
//       : super(key: key);

//   @override
//   _LikeButtonState createState() => _LikeButtonState();
// }

// class _LikeButtonState extends State<LikeButton> {
//   bool liked = false;

//   // Add song to favourite
//   Future<void> addSongToFavourite() {
//     MusicServices musicServices = MusicServices();
//     User user = FirebaseAuth.instance.currentUser;
//     return musicServices.favouriteSongs.doc(user.uid).collection('songs').add(
//           widget.mediaItem.toJson(),
//         );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.mediaItem != null) {
//       try {
//         liked = checkPlaylist('Favorite Songs', widget.mediaItem.id);
//       } catch (e) {}
//     }
//     return IconButton(
//         icon: Icon(
//           liked ? Icons.bookmark : Icons.bookmark_border,
//           color: liked ? Colors.purple : Colors.grey,

//           // color: liked ? Colors.redAccent : null,
//         ),
//         iconSize: liked ? 60 : widget.size ?? 60,
//         onPressed: () {
//           liked
//               ? removeLiked(widget.mediaItem.id)
//               : addSongToFavourite().then((value) {
//                   EasyLoading.show(status: 'Adding song to Bookmark Playlist');

//                   EasyLoading.showSuccess('Song added to bookmark');
//                 });
//           addPlaylist('Favorite Songs', widget.mediaItem);
//           liked = !liked;
//           setState(() {});
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               duration: Duration(seconds: 2),
//               action: SnackBarAction(
//                   textColor: Theme.of(context).accentColor,
//                   label: 'Undo',
//                   onPressed: () {
//                     liked
//                         ? removeLiked(widget.mediaItem.id)
//                         : addPlaylist('Favorite Songs', widget.mediaItem);
//                     liked = !liked;
//                     setState(() {});
//                   }),
//               elevation: 6,
//               backgroundColor: Colors.grey[900],
//               behavior: SnackBarBehavior.floating,
//               content: Text(
//                 liked ? 'Added to Favorites' : 'Removed from Favorites',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           );
//         });
//   }
// }
