import 'package:cloud_firestore/cloud_firestore.dart';

// class Song {
//   final String songTitle, songImage, genre, artist, artistUid, album, producer;
//   final DocumentSnapshot document;
//   List<QueryDocumentSnapshot> topSongsList;

//   Song(
//       {this.songTitle,
//       this.songImage,
//       this.genre,
//       this.artist,
//       this.artistUid,
//       // this.playCount,
//       this.document,
//       this.topSongsList,
//       this.producer,
//       this.album});
// }

class AllSongs {
  final String songTitle, songImage, genre, artist, artistUid, album, producer;
  final DocumentSnapshot document;
  final List<QueryDocumentSnapshot> topSongsList;

  AllSongs(
      {this.songTitle,
      this.songImage,
      this.genre,
      this.artist,
      this.artistUid,
      // this.playCount,
      this.document,
      this.topSongsList,
      this.producer,
      this.album});
}
