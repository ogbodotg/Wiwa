import 'dart:io';

// import 'package:audioplayers/audioplayers.dart';
import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:uuid/uuid.dart';

class AlbumProvider with ChangeNotifier {
  // StoreServices _storeServices = StoreServices();
  // UserServices _userServices = UserServices();
  MusicServices _musicServices = MusicServices();
  User user = FirebaseAuth.instance.currentUser;

  String selectedArtist;
  String selectedArtistId;
  DocumentSnapshot artistDetails;
  String selectedSongAlbum;
  String selectedSongGenre;
  String selectedSongSubGenre;
  // String selectedSubCategory;

  getSelectedArtist(artistDetails) {
    this.artistDetails = artistDetails;
    notifyListeners();
  }

  selectedAlbum(album) {
    this.selectedSongAlbum = album;
    notifyListeners();
  }

  selectedGenre(genre) {
    this.selectedSongGenre = genre;
    notifyListeners();
  }

  selectedGenreSub(subGenre) {
    this.selectedSongSubGenre = subGenre;
    notifyListeners();
  }
}
