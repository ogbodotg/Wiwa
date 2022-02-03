import 'dart:io';
import 'package:wiwa_app/Music/Providers/AlbumProvider.dart';
import 'package:wiwa_app/Music/Providers/SongProvider.dart';
import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:wiwa_app/Music/Widgets/AlbumList.dart';
import 'package:wiwa_app/Music/Widgets/GenreList.dart';
import 'package:wiwa_app/ahia_vendor/Widgets/CategoryList.dart';
import 'package:wiwa_app/state/authState.dart';
import 'package:wiwa_app/widgets/newWidget/rippleButton.dart';
import 'package:wiwa_app/widgets/newWidget/title_text.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as Path;
import 'package:uuid/uuid.dart';

class AddNewSong extends StatefulWidget {
  static const String id = 'add-new-song';

  @override
  _AddNewSongState createState() => _AddNewSongState();
}

class _AddNewSongState extends State<AddNewSong> {
  User user = FirebaseAuth.instance.currentUser;
  MusicServices _services = MusicServices();
  DocumentSnapshot doc;
  final _formKey = GlobalKey<FormState>();

  File _pickedSong;
  String songpath;
  AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  // String currentTime = "00:00";
  // String completeTime = "00:00";

  String songTitle;
  String albumName;
  String song;
  String artistName;
  String songDescription;
  String producer;
  String songId;
  String albumId;
  bool _artistExists = false;

  var _genreTextController = TextEditingController();
  var _albumTextController = TextEditingController();
  var _subGenreTextController = TextEditingController();
  var _songTitleTextController = TextEditingController();
  var _artistNameTextController = TextEditingController();
  var _songDescriptionTextController = TextEditingController();
  var _producerTextController = TextEditingController();

  String uniqueSongId = Uuid().v4();
  String uniqueAlbumId = Uuid().v4();
  File pickedSongFile;
  File _image;
  File _albumImage;
  bool _visible = false;
  bool _track = false;
  final picker = ImagePicker();
  bool _play = false;

  selectSong() async {
    //  pickedSongFile = await FilePicker.platform.pickFiles(type: FileType.audio);
    // String pickedSong = await FilePicker.getFilePath(type: FileType.audio);
    FilePickerResult result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    // String pickedSong = await FilePicker.getFilePath(type: FileType.audio);
    if (result != null) {
      pickedSongFile = File(result.files.single.path);
      _pickedSong = pickedSongFile;
      songpath = pickedSongFile.path;
      if (songpath != null) {
        setState(() {
          // _audioPlayer.setFilePath(songpath);
          _audioPlayer.setAudioSource(AudioSource.uri(Uri.file(songpath)));
          isPlaying = true;
        });
        // return _pickedSong;
      } else {}
    } else {
      // User canceled the picker
    }

    // int status = await _audioPlayer.play(songpath, isLocal: true);
    // if (status == 1) {
    //   setState(() {
    //     isPlaying = true;

    //     _pickedSong = pickedSongFile;
    //   });
    //   return _pickedSong;
    // }
  }

  // Widget _floatingActionButton() {
  //   return FloatingActionButton(
  //     onPressed: () async {
  //       pickedSongFile = await FilePicker.getFile(type: FileType.audio);

  //       String filePath = pickedSongFile.path;
  //       int status = await _audioPlayer.play(filePath, isLocal: true);
  //       if (status == 1) {
  //         setState(() {
  //           isPlaying = true;
  //           songpath = filePath;
  //           _pickedSong = pickedSongFile;
  //         });
  //       }
  //     },
  //     child: Icon(
  //       Icons.audiotrack,
  //       color: Theme.of(context).colorScheme.onPrimary,
  //       size: 25,
  //     ),
  //   );
  // }

  Future<void> getArtistsDetails() async {
    _services.artists.doc(user.uid).get().then((DocumentSnapshot document) {
      if (document.exists) {
        setState(() {
          _artistExists = true;
          doc = document;
          artistName = doc['artistName'];
        });
      }
    });
  }

  uploadSongToStorage() async {
    String uniqueSongId = Uuid().v4();
    FirebaseStorage _storage = FirebaseStorage.instance;
    UploadTask uploadTask = _storage
        .ref('songs/${this.artistName}/$songTitle$uniqueSongId')
        .putFile(_pickedSong);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  void initState() {
    setState(() {
      getArtistsDetails();
      songId = uniqueSongId.toString();
      albumId = uniqueAlbumId.toString();
      // _audioPlayer.onAudioPositionChanged.listen((Duration duration) {
      //   setState(() {
      //     currentTime = duration.toString().split(".")[0];
      //   });
      // });

      // _audioPlayer.onDurationChanged.listen((Duration duration) {
      //   setState(() {
      //     completeTime = duration.toString().split(".")[0];
      //   });
      // });
    });
    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _playerButton(PlayerState playerState) {
    // 1
    final processingState = playerState?.processingState;
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      // 2
      return Container(
        margin: EdgeInsets.all(8.0),
        width: 64.0,
        height: 64.0,
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    } else if (_audioPlayer.playing != true) {
      // 3
      return IconButton(
        icon: Icon(Icons.play_arrow, color: Colors.white),
        iconSize: 64.0,
        onPressed: _audioPlayer.play,
      );
    } else if (processingState != ProcessingState.completed) {
      // 4
      return IconButton(
        icon: Icon(Icons.pause, color: Colors.white),
        iconSize: 64.0,
        onPressed: _audioPlayer.pause,
      );
    } else {
      // 5
      return IconButton(
        icon: Icon(Icons.replay, color: Colors.white),
        iconSize: 64.0,
        onPressed: () => _audioPlayer.seek(Duration.zero,
            index: _audioPlayer.effectiveIndices.first),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _provider = Provider.of<SongProvider>(context);
    // final _albumProvider = Provider.of<AlbumProvider>(context);

    var state = Provider.of<AuthState>(context);

    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        // floatingActionButton: _floatingActionButton(),
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.purple),
          centerTitle: true,
          title: Text(
            'Upload New Song',
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Material(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Container(
                          child: Text('Songs / Add'),
                        ),
                      ),
                      // FlatButton.icon(
                      //   color: Theme.of(context).primaryColor,
                      //   onPressed: () async {
                      //     if (_formKey.currentState.validate()) {
                      //       if (_image != null && _pickedSong != null) {
                      //         EasyLoading.show(status: 'Saving...');
                      //         // checkArtistsExists();
                      //         song = await uploadSongToStorage();

                      //         _provider
                      //             .uploadSongImage(
                      //                 _image.path, artistName, songTitle)
                      //             .then((url) {
                      //           if (url != null) {
                      //             EasyLoading.dismiss();

                      //             _provider.saveSongToDb(
                      //               context: context,
                      //               songId: songId,
                      //               songTitle: songTitle,
                      //               song: song,
                      //               songDescription:
                      //                   _songDescriptionTextController.text,
                      //               artistName: _artistExists
                      //                   ? artistName
                      //                   : state.userModel.displayName,
                      //               producer: producer,
                      //             );

                      //             setState(() {
                      //               _formKey.currentState.reset();
                      //               _genreTextController.clear();
                      //               _albumTextController.clear();
                      //               _subGenreTextController.clear();
                      //               _songTitleTextController.clear();
                      //               _artistNameTextController.clear();
                      //               _songDescriptionTextController.clear();
                      //               _producerTextController.clear();
                      //               _track = false;
                      //               _image = null;
                      //               _pickedSong = null;

                      //               _visible = false;
                      //             });
                      //           } else {
                      //             _provider.alertDialog(
                      //               context: context,
                      //               title: 'Song Image Upload',
                      //               content: 'Song image upload failed',
                      //             );
                      //           }
                      //         });
                      //       } else {
                      //         _provider.alertDialog(
                      //           context: context,
                      //           title: 'Song Image',
                      //           content: 'Song Image not selected',
                      //         );
                      //       }
                      //     }
                      //   },
                      //   icon: Icon(Icons.cloud_upload, color: Colors.white),
                      //   label: Text('Upload Song',
                      //       style: TextStyle(color: Colors.white)),
                      // ),
                      RippleButton(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            if (_image != null && _pickedSong != null) {
                              EasyLoading.show(status: 'Saving...');
                              // checkArtistsExists();
                              song = await uploadSongToStorage();

                              _provider
                                  .uploadSongImage(
                                      _image.path, artistName, songTitle)
                                  .then((url) {
                                if (url != null) {
                                  EasyLoading.dismiss();

                                  _provider.saveSongToDb(
                                    context: context,
                                    songId: songId,
                                    songTitle: songTitle,
                                    song: song,
                                    songDescription:
                                        _songDescriptionTextController.text,
                                    artistName: _artistExists
                                        ? artistName
                                        : state.userModel.displayName,
                                    producer: producer,
                                  );

                                  setState(() {
                                    _formKey.currentState.reset();
                                    _genreTextController.clear();
                                    _albumTextController.clear();
                                    _subGenreTextController.clear();
                                    _songTitleTextController.clear();
                                    _artistNameTextController.clear();
                                    _songDescriptionTextController.clear();
                                    _producerTextController.clear();
                                    _track = false;
                                    _image = null;
                                    _pickedSong = null;
                                    songId = null;
                                    albumId = null;

                                    _visible = false;
                                  });
                                } else {
                                  _provider.alertDialog(
                                    context: context,
                                    title: 'Song Image Upload',
                                    content: 'Song image upload failed',
                                  );
                                }
                              });
                            } else {
                              _provider.alertDialog(
                                context: context,
                                title: 'Song Image',
                                content: 'Song Image not selected',
                              );
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Color(0xffeeeeee),
                                blurRadius: 15,
                                offset: Offset(5, 5),
                              ),
                            ],
                          ),
                          child: Wrap(
                            children: <Widget>[
                              Icon(Icons.cloud_upload,
                                  color: Theme.of(context).primaryColor),
                              SizedBox(width: 10),
                              TitleText(
                                'Upload',
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TabBar(
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.black54,
                tabs: [
                  Tab(
                    text: 'Upload Song',
                  ),
                  Tab(
                    text: 'Create Album',
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: TabBarView(
                      children: [
                        // first side of the tab
                        ListView(children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Song Title';
                                    }
                                    setState(() {
                                      songTitle = value;
                                    });
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Song Title',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20.0, bottom: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Select Album',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 16),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: AbsorbPointer(
                                          absorbing: true,
                                          child: TextFormField(
                                            controller: _albumTextController,
                                            // validator: (value) {
                                            //   if (value.isEmpty) {
                                            //     return 'Please select genre';
                                            //   }
                                            //   return null;
                                            // },
                                            decoration: InputDecoration(
                                              hintText: 'Select album',
                                              labelStyle:
                                                  TextStyle(color: Colors.grey),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit_outlined),
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlbumList();
                                              }).whenComplete(() {
                                            setState(() {
                                              _albumTextController.text =
                                                  _provider.selectedAlbum;
                                              _visible = true;
                                            });
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Enter Artist Name';
                                    }
                                    setState(() {
                                      artistName = value;
                                    });
                                    return null;
                                  },
                                  // controller: _artistNameTextController,
                                  // initialValue: _artistExists
                                  //     ? artistName
                                  //     : state.userModel.displayName,
                                  decoration: InputDecoration(
                                    labelText: 'Artist',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Enter Producer';
                                    }
                                    setState(() {
                                      producer = value;
                                    });
                                    return null;
                                  },
                                  controller: _producerTextController,
                                  decoration: InputDecoration(
                                    labelText: 'Producer',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      _provider.getSongImage().then((image) {
                                        setState(() {
                                          _image = image;
                                        });
                                      });
                                    },
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: 300,
                                      child: Card(
                                        child: Center(
                                            child: _image == null
                                                ? Text('Select Song Artwork')
                                                : Image.file(_image,
                                                    fit: BoxFit.cover)),
                                      ),
                                    ),
                                  ),
                                ),
                                // FlatButton.icon(
                                //   color: Theme.of(context).primaryColor,
                                //   onPressed: () {
                                //     selectSong();
                                //   },
                                //   icon: Icon(Icons.file_upload,
                                //       color: Colors.white, size: 35),
                                //   label: Text('Select music file',
                                //       style: TextStyle(color: Colors.white)),
                                // ),
                                RippleButton(
                                  onPressed: () {
                                    selectSong();
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: Color(0xffeeeeee),
                                          blurRadius: 15,
                                          offset: Offset(5, 5),
                                        ),
                                      ],
                                    ),
                                    child: Wrap(
                                      children: <Widget>[
                                        Icon(Icons.upload,
                                            color:
                                                Theme.of(context).primaryColor),
                                        SizedBox(width: 10),
                                        TitleText(
                                          'Select Music File',
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                _pickedSong == null
                                    ? SizedBox.shrink()
                                    : Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        height: 70,
                                        decoration: BoxDecoration(
                                            color: Colors.purple,
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        child: Center(
                                          child: StreamBuilder<PlayerState>(
                                            stream:
                                                _audioPlayer.playerStateStream,
                                            builder: (context, snapshot) {
                                              final playerState = snapshot.data;
                                              return _playerButton(playerState);
                                            },
                                          ),
                                        ),
                                      ),

                                // Container(
                                //     width:
                                //         MediaQuery.of(context).size.width *
                                //             0.8,
                                //     height: 50,
                                //     decoration: BoxDecoration(
                                //         color: Colors.purple,
                                //         borderRadius:
                                //             BorderRadius.circular(50)),
                                //     child: Row(
                                //       mainAxisAlignment:
                                //           MainAxisAlignment.center,
                                //       mainAxisSize: MainAxisSize.max,
                                //       children: <Widget>[
                                //         IconButton(
                                //           icon: Icon(
                                //               isPlaying
                                //                   ? Icons.pause
                                //                   : Icons.play_arrow,
                                //               color: Colors.white),
                                //           onPressed: () {
                                //             if (isPlaying) {
                                //               _audioPlayer.pause();

                                //               setState(() {
                                //                 isPlaying = false;
                                //               });
                                //             } else {
                                //               _audioPlayer.resume();

                                //               setState(() {
                                //                 isPlaying = true;
                                //               });
                                //             }
                                //           },
                                //         ),
                                //         SizedBox(
                                //           width: 16,
                                //         ),
                                //         IconButton(
                                //           icon: Icon(Icons.stop,
                                //               color: Colors.white),
                                //           onPressed: () {
                                //             _audioPlayer.stop();

                                //             setState(() {
                                //               isPlaying = false;
                                //             });
                                //           },
                                //         ),
                                //         Text(
                                //           currentTime,
                                //           style: TextStyle(
                                //               color: Colors.white,
                                //               fontWeight: FontWeight.w700),
                                //         ),
                                //         Text(" | ",
                                //             style: TextStyle(
                                //               color: Colors.white,
                                //             )),
                                //         Text(
                                //           completeTime,
                                //           style: TextStyle(
                                //               color: Colors.white,
                                //               fontWeight: FontWeight.w300),
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                TextFormField(
                                  controller: _songDescriptionTextController,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 5,
                                  maxLength: 500,
                                  decoration: InputDecoration(
                                    labelText: 'Song Description',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20.0, bottom: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Genre',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 16),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: AbsorbPointer(
                                          absorbing: true,
                                          child: TextFormField(
                                            controller: _genreTextController,
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Please select genre';
                                              }
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'genre not selected',
                                              labelStyle:
                                                  TextStyle(color: Colors.grey),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit_outlined),
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return GenreList();
                                              }).whenComplete(() {
                                            setState(() {
                                              _genreTextController.text =
                                                  _provider.selectedGenre;
                                              _visible = true;
                                            });
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: _visible,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 20.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Sub-Genre',
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 16),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: AbsorbPointer(
                                            absorbing: true,
                                            child: TextFormField(
                                              controller:
                                                  _subGenreTextController,
                                              // validator: (value) {
                                              //   if (value.isEmpty) {
                                              //     return 'Please select song sub-genre';
                                              //   }
                                              //   return null;
                                              // },
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Pls select genre first to avoid error',
                                                labelStyle: TextStyle(
                                                    color: Colors.grey),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.grey[300],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit_outlined),
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return SubGenreList();
                                                }).whenComplete(() {
                                              setState(() {
                                                _subGenreTextController.text =
                                                    _provider.selectedSubGenre;
                                              });
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ]),

                        // second side of the tab

                        ListView(children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Album/EP Name';
                                    }
                                    setState(() {
                                      albumName = value;
                                    });
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Album/EP Name',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Artist Name';
                                    }
                                    setState(() {
                                      artistName = value;
                                    });
                                    return null;
                                  },
                                  // controller: _artistNameTextController,
                                  initialValue: _artistExists
                                      ? artistName
                                      : state.userModel.displayName,

                                  decoration: InputDecoration(
                                    labelText: 'Artist',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      _provider.getAlbumImage().then((image) {
                                        setState(() {
                                          _albumImage = image;
                                        });
                                      });
                                    },
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: 300,
                                      child: Card(
                                        child: Center(
                                            child: _albumImage == null
                                                ? Text('Select Album Artwork')
                                                : Image.file(_albumImage,
                                                    fit: BoxFit.cover)),
                                      ),
                                    ),
                                  ),
                                ),
                                // FlatButton(
                                //   color: Theme.of(context).primaryColor,

                                //   onPressed: () {
                                //     if (_formKey.currentState.validate()) {
                                //       if (_albumImage != null &&
                                //           albumName != null) {
                                //         EasyLoading.show(
                                //             status: 'Creating Album...');
                                //         // checkArtistsExists();
                                //         // song = await uploadSongToStorage();

                                //         _provider
                                //             .uploadAlbumImage(_albumImage.path,
                                //                 artistName, albumName)
                                //             .then((url) {
                                //           if (url != null) {
                                //             EasyLoading.dismiss();

                                //             _provider.saveAlbumToDb(
                                //               context: context,
                                //               albumId: albumId,
                                //               albumName: albumName,
                                //               artistName: _artistExists
                                //                   ? artistName
                                //                   : state.userModel.displayName,
                                //             );

                                //             setState(() {
                                //               _formKey.currentState.reset();

                                //               _albumTextController.clear();
                                //               _artistNameTextController.clear();
                                //               _track = false;
                                //               _albumImage = null;
                                //               _visible = false;
                                //             });
                                //           } else {
                                //             _provider.alertDialog(
                                //               context: context,
                                //               title: 'Album Image Upload',
                                //               content:
                                //                   'Album image upload failed',
                                //             );
                                //           }
                                //         });
                                //       } else {
                                //         _provider.alertDialog(
                                //           context: context,
                                //           title: 'Album Image',
                                //           content: 'Album Image not selected',
                                //         );
                                //       }
                                //     }
                                //   },
                                //   // icon: Icon(Icons.file_upload,
                                //   //     color: Colors.white, size: 35),
                                //   child: Text('Create Album/EP',
                                //       style: TextStyle(color: Colors.white)),
                                // ),
                                RippleButton(
                                  onPressed: () async {
                                    if (_formKey.currentState.validate()) {
                                      if (_albumImage != null &&
                                          albumName != null) {
                                        EasyLoading.show(
                                            status: 'Creating Album...');
                                        // checkArtistsExists();
                                        // song = await uploadSongToStorage();

                                        _provider
                                            .uploadAlbumImage(_albumImage.path,
                                                artistName, albumName)
                                            .then((url) {
                                          if (url != null) {
                                            EasyLoading.dismiss();

                                            _provider.saveAlbumToDb(
                                              context: context,
                                              albumId: albumId,
                                              albumName: albumName,
                                              artistName: _artistExists
                                                  ? artistName
                                                  : state.userModel.displayName,
                                            );

                                            setState(() {
                                              _formKey.currentState.reset();

                                              _albumTextController.clear();
                                              _artistNameTextController.clear();
                                              _track = false;
                                              _albumImage = null;
                                              _visible = false;
                                            });
                                          } else {
                                            _provider.alertDialog(
                                              context: context,
                                              title: 'Album Image Upload',
                                              content:
                                                  'Album image upload failed',
                                            );
                                          }
                                        });
                                      } else {
                                        _provider.alertDialog(
                                          context: context,
                                          title: 'Album Image',
                                          content: 'Album Image not selected',
                                        );
                                      }
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: Color(0xffeeeeee),
                                          blurRadius: 15,
                                          offset: Offset(5, 5),
                                        ),
                                      ],
                                    ),
                                    child: Wrap(
                                      children: <Widget>[
                                        Icon(Icons.album, color: Colors.white),
                                        SizedBox(width: 10),
                                        TitleText(
                                          'Create Album/EP',
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
