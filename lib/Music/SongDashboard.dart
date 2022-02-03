import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:wiwa_app/Music/Widgets/AddNewSongs.dart';
import 'package:wiwa_app/Music/Widgets/PublishedSongs.dart';
import 'package:wiwa_app/Music/Widgets/UnPublishedSongs.dart';
import 'package:wiwa_app/ahia_vendor/Pages/AddNewProduct.dart';
import 'package:wiwa_app/ahia_vendor/Widgets/PublishedProduct.dart';
import 'package:wiwa_app/ahia_vendor/Widgets/UnPublishedProducts.dart';
import 'package:wiwa_app/state/authState.dart';
import 'package:wiwa_app/widgets/newWidget/rippleButton.dart';
import 'package:wiwa_app/widgets/newWidget/title_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SongDashBoard extends StatefulWidget {
  @override
  _SongDashBoardState createState() => _SongDashBoardState();
}

class _SongDashBoardState extends State<SongDashBoard> {
  MusicServices _services = MusicServices();
  bool _artistExists = false;
  User user = FirebaseAuth.instance.currentUser;
  DocumentSnapshot doc;
  String artistName;
  String artistUid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkArtistsExists();
  }

  Future<void> checkArtistsExists() async {
    _services.artists.doc(user.uid).get().then((DocumentSnapshot document) {
      if (document.exists) {
        setState(() {
          _artistExists = true;
          doc = document;
          artistName = doc['artistName'];
          artistUid = doc['artistUid'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.purple),
          centerTitle: true,
          title: Text(
            'My Songs',
            style: TextStyle(
                color: Colors.black54,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            Material(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 3),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text('Songs'),
                        ],
                      ),
                      // FlatButton.icon(
                      //   color: Theme.of(context).primaryColor,
                      //   onPressed: () {
                      //     if (_artistExists) {
                      //       Navigator.pushReplacementNamed(
                      //           context, AddNewSong.id);
                      //     } else {
                      //       _services.artists.doc(user.uid).set({
                      //         'artistUsername': state.userModel.userName,
                      //         'artistUid': state.userModel.userId,
                      //         'artistImage': state.userModel.profilePic,
                      //         'artistName': state.userModel.displayName,
                      //         'verified': state.userModel.isVerified,
                      //         'isTopArtist': false,
                      //         'accountVerified': false,
                      //         'isFeaturedArtist': false,
                      //         'playCount': 0,
                      //       });
                      //       Navigator.pushReplacementNamed(
                      //           context, AddNewSong.id);
                      //       // Navigator.push(
                      //       //     context,
                      //       //     MaterialPageRoute(
                      //       //         builder: (context) => AddNewSong()));
                      //     }
                      //   },
                      //   icon: Icon(Icons.add, color: Colors.white),
                      //   label: Text('Add New Song',
                      //       style: TextStyle(color: Colors.white)),
                      // ),
                      RippleButton(
                        onPressed: () async {
                          if (_artistExists) {
                            Navigator.pushReplacementNamed(
                                context, AddNewSong.id);
                          } else {
                            _services.artists.doc(user.uid).set({
                              'artistUsername': state.userModel.userName,
                              'artistUid': state.userModel.userId,
                              'artistImage': state.userModel.profilePic,
                              'artistName': state.userModel.displayName,
                              'verified': state.userModel.isVerified,
                              'isTopArtist': false,
                              'accountVerified': false,
                              'isFeaturedArtist': false,
                              'playCount': 0,
                            });
                            Navigator.pushReplacementNamed(
                                context, AddNewSong.id);
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => AddNewSong()));
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
                                'Upload New Song',
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
            ),
            TabBar(
              indicatorColor: Theme.of(context).primaryColor,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.black54,
              tabs: [Tab(text: 'Published'), Tab(text: 'UnPublished')],
            ),
            Expanded(
              child: Container(
                child: TabBarView(
                  children: [
                    PublishedSongs(),
                    UnPublishedSongs(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
