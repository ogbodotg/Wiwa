import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:wiwa_app/ahia/Services/StoreServices.dart';
import 'package:wiwa_app/ahia/Services/UserServices.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class ArtistProvider with ChangeNotifier {
  MusicServices _services = MusicServices();
  User user = FirebaseAuth.instance.currentUser;

  String selectedArtist;
  String selectedArtistId;
  DocumentSnapshot artistDetails;
  String selectedGenre;
  String selectedSubGenre;

  getSelectedArtist(artistDetails) {
    this.artistDetails = artistDetails;
    notifyListeners();
  }

  selectedSongGenre(genre) {
    this.selectedGenre = genre;
    notifyListeners();
  }

  selectedGenreSub(subGenre) {
    this.selectedSubGenre = subGenre;
    notifyListeners();
  }
}
