import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:audio_service/audio_service.dart';
import 'package:wiwa_app/Music/FrontEnd/Helpers/playlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wiwa_app/ui/theme/custom_icon_icons.dart';

class LikeSong extends StatefulWidget {
  final MediaItem mediaItem;
  final List likes;
  final double size;
  const LikeSong({Key key, @required this.mediaItem, this.size, this.likes})
      : super(key: key);

  @override
  _LikeSongState createState() => _LikeSongState();
}

class _LikeSongState extends State<LikeSong> {
  bool liked = false;
  var user;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    setState(() {
      liked = widget.likes.any((element) => element == user.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    MusicServices _musicServices = MusicServices();

    // if (widget.mediaItem != null) {
    //   try {
    // liked = widget.likes.any((element) => element == user.uid);

    //   } catch (e) {}
    // }
    return IconButton(
        icon: Icon(
          // liked ? Icons.favorite : Icons.favorite_border,
          liked ? CustomIcon.thumbs_up_alt : CustomIcon.thumbs_up_1,
          color: liked ? Colors.purple : Colors.grey,
        ),
        iconSize: liked ? 40 : widget.size ?? 40,
        onPressed: () async {
          liked
              ? _musicServices.songs
                  .doc(widget.mediaItem.extras['songId'])
                  .update({
                  'likes': FieldValue.arrayRemove([user.uid]),
                })
              : _musicServices.songs
                  .doc(widget.mediaItem.extras['songId'])
                  .update({
                  'likes': FieldValue.arrayUnion([user.uid]),
                });

          liked = !liked;
        });
  }
}
