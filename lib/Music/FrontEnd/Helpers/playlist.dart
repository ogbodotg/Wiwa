import 'package:wiwa_app/Music/FrontEnd/Helpers/mediaitem_converter.dart';
import 'package:audio_service/audio_service.dart';
import 'package:wiwa_app/Music/FrontEnd/Helpers/songs_count.dart';
import 'package:hive/hive.dart';

bool checkPlaylist(String name, String key) {
  if (name != 'Favorite Songs') {
    Hive.openBox(name).then((value) {
      final playlistBox = Hive.box(name);
      return playlistBox.containsKey(key);
    });
  }
  final playlistBox = Hive.box(name);
  return playlistBox.containsKey(key);
}

Future<void> removeLiked(String key) async {
  Box likedBox = Hive.box('Favorite Songs');
  likedBox.delete(key);
  // setState(() {});
}

Future<void> addMapToPlaylist(String name, Map info) async {
  if (name != 'Favorite Songs') await Hive.openBox(name);
  Box playlistBox = Hive.box(name);
  List _songs = playlistBox.values.toList();
  AddSongsCount().addSong(
    name,
    playlistBox.values.length + 1,
    _songs.length >= 4
        ? _songs.sublist(0, 4)
        : _songs.sublist(0, _songs.length),
  );
  playlistBox.put(info['id'].toString(), info);
}

Future<void> addItemToPlaylist(String name, MediaItem mediaItem) async {
  if (name != 'Favorite Songs') await Hive.openBox(name);
  Box playlistBox = Hive.box(name);
  Map info = MediaItemConverter().mediaItemtoMap(mediaItem);
  List _songs = playlistBox.values.toList();
  AddSongsCount().addSong(
    name,
    playlistBox.values.length + 1,
    _songs.length >= 4
        ? _songs.sublist(0, 4)
        : _songs.sublist(0, _songs.length),
  );
  playlistBox.put(mediaItem.id.toString(), info);
}

Future<void> addPlaylist(String name, List data) async {
  await Hive.openBox(name);
  Box playlistBox = Hive.box(name);

  AddSongsCount().addSong(
    name,
    data.length,
    data.length >= 4 ? data.sublist(0, 4) : data.sublist(0, data.length),
  );
  Map result =
      Map.fromIterable(data, key: (v) => v['id'].toString(), value: (v) => v);
  playlistBox.putAll(result);

  List playlistNames =
      Hive.box('settings').get('playlistNames')?.toList() ?? [];

  if (name.trim() == '') name = 'Playlist ${playlistNames.length}';
  while (playlistNames.contains(name)) name = name + ' (1)';
  playlistNames.add(name);
  Hive.box('settings').put('playlistNames', playlistNames);
}

// bool checkPlaylist(String name, String key) {
//   if (name != 'Favorite Songs') {
//     Hive.openBox(name).then((value) {
//       final playlistBox = Hive.box(name);
//       return playlistBox.containsKey(key);
//     });
//   }
//   final playlistBox = Hive.box(name);
//   return playlistBox.containsKey(key);
// }

// void removeLiked(String key) async {
//   Box likedBox = Hive.box('Favorite Songs');
//   likedBox.delete(key);
//   // setState(() {});
// }

// void addPlaylist(String name, MediaItem mediaItem) async {
//   if (name != 'Favorite Songs') await Hive.openBox(name);
//   Box playlistBox = Hive.box(name);
//   Map info = {
//     'id': mediaItem.id.toString(),
//     'artist': mediaItem.artist.toString(),
//     'album': mediaItem.album.toString(),
//     'image': mediaItem.artUri.toString(),
//     'duration': mediaItem.duration.inSeconds.toString(),
//     'title': mediaItem.title.toString(),
//     'url': mediaItem.extras['url'].toString(),
//     "genre": mediaItem.genre.toString(),
//     // "year": mediaItem.extras["year"].toString(),
//     // "language": mediaItem.extras["language"].toString(),
//     // "320kbps": mediaItem.extras["320kbps"],
//     // "has_lyrics": mediaItem.extras["has_lyrics"],
//     // "release_date": mediaItem.extras["release_date"],
//     // "album_id": mediaItem.extras["album_id"],
//     // "subtitle": mediaItem.extras["subtitle"]
//   };
//   List _songs = playlistBox.values.toList();
//   AddSongsCount().addSong(
//     name,
//     playlistBox.values.length + 1,
//     _songs.length >= 4
//         ? _songs.sublist(0, 4)
//         : _songs.sublist(0, _songs.length),
//   );
//   playlistBox.put(mediaItem.id.toString(), info);
// }
