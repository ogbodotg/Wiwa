import 'dart:io';

// import 'package:audioplayers/audioplayers.dart';
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

class SongProvider with ChangeNotifier {
  String selectedGenre;
  String selectedAlbum;
  String selectedSubGenre;
  String genreImage;
  File image;
  String pickerError;
  String artistName;
  String songImageUrl;
  String albumImageUrl;
  String albumImage;

  selectGenre(mainGenre, genreImage) {
    this.selectedGenre = mainGenre;
    this.genreImage = genreImage;
    notifyListeners();
  }

  selectSubGenre(selected) {
    this.selectedSubGenre = selected;
    notifyListeners();
  }

  selectAlbum(album, albumImage) {
    this.selectedAlbum = album;
    this.albumImage = albumImage;
    notifyListeners();
  }

  getArtistName(artistName) {
    this.artistName = artistName;
    notifyListeners();
  }

  resetProvider() {
    this.selectedGenre = null;
    this.selectedSubGenre = null;
    this.selectedAlbum = null;
    this.genreImage = null;
    this.albumImage = null;
    this.image = null;
    this.songImageUrl = null;
    this.albumImageUrl = null;

    notifyListeners();
  }

// upload multiple images to cloud storage and get dowload urls WILL TRY THIS FOR ARTISTS ALBUM UPLOAD
  // Future uploadProductImages(images, productName, productId) async {
  //   firebase_storage.Reference ref;
  //   CollectionReference _productImages =
  //       FirebaseFirestore.instance.collection('productImages');
  //   for (var img in images) {
  //     ref = firebase_storage.FirebaseStorage.instance.ref().child(
  //         'ProductImages/${this.shopName}/$productName/${Path.basename(img.path)}');
  //     await ref.putFile(img).whenComplete(() async {
  //       await ref.getDownloadURL().then((value) {
  //         _productImages.add({
  //           'productImages': value,
  //           'productId': productId,
  //         });
  //       });
  //     });
  //   }
  // }

  Future<String> uploadSongImage(filePath, artistName, songTitle) async {
    File file = File(filePath);
    String uniqueSongId = Uuid().v4();

    FirebaseStorage _storage = FirebaseStorage.instance;
    try {
      await _storage
          .ref('songImage/${artistName}/$songTitle$uniqueSongId')
          .putFile(file);
    } on FirebaseException catch (e) {
      print(e.code);
    }
    String downloadURL = await _storage
        .ref('songImage/${artistName}/$songTitle$uniqueSongId')
        .getDownloadURL();
    this.songImageUrl = downloadURL;
    notifyListeners();
    return downloadURL;
  }

  Future<File> getSongImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 20);

    if (pickedFile != null) {
      this.image = File(pickedFile.path);
      notifyListeners();
    } else {
      this.pickerError = 'No image selected.';
      notifyListeners();
      print('No image selected.');
    }
    return this.image;
  }

  alertDialog({context, title, content}) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  Future<void> saveSongToDb({
    songTitle,
    song,
    songDescription,
    genreName,
    songId,
    artistName,
    producer,
    context,
  }) {
    var timeStamp = DateTime.now();
    User user = FirebaseAuth.instance.currentUser;
    CollectionReference _songs = FirebaseFirestore.instance.collection('songs');
    try {
      _songs.doc(songId).set({
        'uid': user.uid,
        'artist': {'artistName': artistName, 'artistUid': user.uid},
        'producer': producer,
        'songTitle': songTitle,
        'album': this.selectedAlbum,
        'song': song,
        'songDescription': songDescription,
        'isTopPicked': false,
        'isFeatured': false,
        'published': false,
        'trendingSong': false,
        'genre': {
          'mainGenre': this.selectedGenre,
          'subGenre': this.selectedSubGenre,
          'genreImage': this.genreImage,
        },
        'songId': songId,
        'songImage': this.songImageUrl,
        'timestamp': timeStamp,
        'likes': [],
        // 'dislikes': 0,
        'playCount': 0,
      });
      this.alertDialog(
        context: context,
        title: 'Song Upload',
        content: 'Song saved successfully',
      );
    } catch (e) {
      this.alertDialog(
          context: context, title: 'Song Upload', content: '${e.toString()}');
    }
    return null;
  }

  // Future<void> updateSong({
  //   productName,
  //   productDescription,
  //   price,
  //   comparedPrice,
  //   collection,
  //   brand,
  //   categoryName,
  //   tax,
  //   stockQuantity,
  //   lowStockQuanity,
  //   context,
  //   productId,
  //   image,
  //   category,
  //   subCategory,
  // }) {
  //   CollectionReference _products =
  //       FirebaseFirestore.instance.collection('products');
  //   try {
  //     _products.doc(productId).update({
  //       'productName': productName,
  //       'productDescription': productDescription,
  //       'price': price,
  //       'comparedPrice': comparedPrice,
  //       'collection': collection,
  //       'brand': brand,
  //       'category': {
  //         'mainCategory': category,
  //         'subCategory': subCategory,
  //       },
  //       'tax': tax,
  //       'stockQuantity': stockQuantity,
  //       'lowStockQuantity': lowStockQuanity,
  //       'productId': productId,
  //       'productImage':
  //           this.productImageUrl == null ? image : this.productImageUrl,
  //     });
  //     this.alertDialog(
  //       context: context,
  //       title: 'Save Product',
  //       content: 'Product details saved successfully',
  //     );
  //   } catch (e) {
  //     this.alertDialog(
  //         context: context, title: 'Save Product', content: '${e.toString()}');
  //   }
  //   return null;
  // }

  Future<String> uploadAlbumImage(filePath, artistName, albumName) async {
    File file = File(filePath);
    String uniqueSongId = Uuid().v4();

    FirebaseStorage _storage = FirebaseStorage.instance;
    try {
      await _storage
          .ref('albumImage/${artistName}/$albumName$uniqueSongId')
          .putFile(file);
    } on FirebaseException catch (e) {
      print(e.code);
    }
    String downloadURL = await _storage
        .ref('albumImage/${artistName}/$albumName$uniqueSongId')
        .getDownloadURL();
    this.albumImageUrl = downloadURL;
    notifyListeners();
    return downloadURL;
  }

  Future<File> getAlbumImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 20);

    if (pickedFile != null) {
      this.image = File(pickedFile.path);
      notifyListeners();
    } else {
      this.pickerError = 'No image selected.';
      notifyListeners();
      print('No image selected.');
    }
    return this.image;
  }

  // alertDialog({context, title, content}) {
  //   showCupertinoDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return CupertinoAlertDialog(
  //           title: Text(title),
  //           content: Text(content),
  //           actions: [
  //             CupertinoDialogAction(
  //                 child: Text('OK'),
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 })
  //           ],
  //         );
  //       });
  // }

  Future<void> saveAlbumToDb({
    albumName,
    albumId,
    artistName,
    context,
  }) {
    var timeStamp = DateTime.now();
    User user = FirebaseAuth.instance.currentUser;
    CollectionReference _albums =
        FirebaseFirestore.instance.collection('albums');
    try {
      _albums.doc('$albumName - $artistName').set({
        'artistName': artistName,
        'artistUid': user.uid,
        'albumName': albumName,
        'isTopPicked': false,
        'isFeatured': false,
        'albumId': albumId,
        'albumImage': this.albumImageUrl,
        'timestamp': timeStamp,
        'likes': 0,
        'dislikes': 0,
        'playCount': 0,
      });
      this.alertDialog(
        context: context,
        title: 'Album Creation',
        content: 'Album created successfully',
      );
    } catch (e) {
      this.alertDialog(
          context: context,
          title: 'Album Creation',
          content: '${e.toString()}');
    }
    return null;
  }
}
