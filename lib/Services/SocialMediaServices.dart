import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SocialMediaServices {
  final BannerAd myBanner = BannerAd(
    adUnitId: 'ca-app-pub-2788962623894298/2647090582',
    size: AdSize.largeBanner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );

  final BannerAd mySmallBanner = BannerAd(
    adUnitId: 'ca-app-pub-2788962623894298/2647090582',
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );

  final BannerAd myBigSquare = BannerAd(
    adUnitId: 'ca-app-pub-2788962623894298/9312054361',
    size: AdSize.mediumRectangle,
    request: AdRequest(),
    listener: BannerAdListener(),
  );
  User user = FirebaseAuth.instance.currentUser;
  CollectionReference reportPost =
      FirebaseFirestore.instance.collection('reportPost');
}
