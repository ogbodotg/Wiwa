import 'package:wiwa_app/Music/ArtistHomeScreen.dart';
import 'package:wiwa_app/Music/FrontEnd/Screens/Home/home.dart';
import 'package:wiwa_app/Music/FrontEnd/Screens/Library/nowplaying.dart';
import 'package:wiwa_app/Music/FrontEnd/Screens/Library/playlists.dart';
import 'package:wiwa_app/Music/FrontEnd/Screens/Library/recent.dart';
import 'package:wiwa_app/Music/FrontEnd/Screens/Settings/setting.dart';
import 'package:wiwa_app/Music/Widgets/AddNewSongs.dart';
import 'package:wiwa_app/Music/Widgets/AlbumSongs.dart';
import 'package:wiwa_app/Music/Widgets/GenreSongs.dart';
import 'package:wiwa_app/ahia/Categories/CategoryList.dart';
import 'package:wiwa_app/ahia/Categories/SubCategories.dart';
import 'package:wiwa_app/ahia/Pages/FavouriteProductDetails.dart';
import 'package:wiwa_app/ui/page/profile/RhythmAhia/albumSongsOnProfile.dart';
import 'package:wiwa_app/ui/page/settings/accountSettings/privacyAndSafety/Privacy.dart';
import 'package:wiwa_app/ui/page/settings/accountSettings/privacyAndSafety/Terms.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:wiwa_app/ui/page/Auth/selectAuthMethod.dart';
import 'package:wiwa_app/ui/page/Auth/verifyEmail.dart';
import 'package:wiwa_app/ui/page/common/splash.dart';
import 'package:wiwa_app/ui/page/feed/composeTweet/composeTweet.dart';
import 'package:wiwa_app/ui/page/feed/composeTweet/state/composeTweetState.dart';
import 'package:wiwa_app/ui/page/message/conversationInformation/conversationInformation.dart';
import 'package:wiwa_app/ui/page/message/newMessagePage.dart';
import 'package:wiwa_app/ui/page/profile/follow/followerListPage.dart';
import 'package:wiwa_app/ui/page/profile/follow/followingListPage.dart';
import 'package:wiwa_app/ui/page/profile/profileImageView.dart';
import 'package:wiwa_app/ui/page/search/SearchPage.dart';
import 'package:wiwa_app/ui/page/settings/accountSettings/about/aboutTwitter.dart';
import 'package:wiwa_app/ui/page/settings/accountSettings/accessibility/accessibility.dart';
import 'package:wiwa_app/ui/page/settings/accountSettings/accountSettingsPage.dart';
import 'package:wiwa_app/ui/page/settings/accountSettings/contentPrefrences/contentPreference.dart';
import 'package:wiwa_app/ui/page/settings/accountSettings/contentPrefrences/trends/trendsPage.dart';
import 'package:wiwa_app/ui/page/settings/accountSettings/dataUsage/dataUsagePage.dart';
import 'package:wiwa_app/ui/page/settings/accountSettings/displaySettings/displayAndSoundPage.dart';
import 'package:wiwa_app/ui/page/settings/accountSettings/notifications/notificationPage.dart';
import 'package:wiwa_app/ui/page/settings/accountSettings/privacyAndSafety/directMessage/directMessage.dart';
import 'package:wiwa_app/ui/page/settings/accountSettings/privacyAndSafety/privacyAndSafetyPage.dart';
import 'package:wiwa_app/ui/page/settings/accountSettings/proxy/proxyPage.dart';
import 'package:wiwa_app/ui/page/settings/settingsAndPrivacyPage.dart';
import 'package:provider/provider.dart';
import '../ui/page/Auth/signin.dart';
import '../helper/customRoute.dart';
import '../ui/page/feed/imageViewPage.dart';
import '../ui/page/Auth/forgetPasswordPage.dart';
import '../ui/page/Auth/signup.dart';
import '../ui/page/feed/feedPostDetail.dart';
import '../ui/page/profile/EditProfilePage.dart';
import '../ui/page/message/chatScreenPage.dart';
import '../ui/page/profile/profilePage.dart';
import '../widgets/customWidgets.dart';
import 'package:wiwa_app/ahia/Pages/CartPage.dart';
import 'package:wiwa_app/ahia/Pages/ProductDetails.dart';
import 'package:wiwa_app/ahia/Pages/ProductList.dart';
import 'package:wiwa_app/ahia/Pages/ProfileScreen.dart';
import 'package:wiwa_app/ahia/Pages/ProfileUpdate.dart';
import 'package:wiwa_app/ahia/Pages/SetDeliveryAddress.dart';
import 'package:wiwa_app/ahia/Pages/VendorHomeScreen.dart';
import 'package:wiwa_app/ahia/Auth/WelcomeScreen.dart';
import 'package:wiwa_app/ahia/Pages/HomeScreen.dart';
import 'package:wiwa_app/ahia/Services/OnlinePayment.dart';
import 'package:wiwa_app/ahia_vendor/Auth/Register_Screen.dart';
import 'package:wiwa_app/ahia_vendor/Pages/AddEditCoupon.dart';
import 'package:wiwa_app/ahia_vendor/Pages/AddNewProduct.dart';
import 'package:wiwa_app/ahia_vendor/Pages/VendorBanner.dart';
import 'package:flutter/cupertino.dart';

class Routes {
  static dynamic route() {
    // initialFuntion() {
    //   return Hive.box('settings').get('name') != null
    //       ? AudioServiceWidget(child: FrontEndMusicHome())
    //       : AudioServiceWidget(child: FrontEndMusicHome());
    // }

    return {
      'SplashPage': (BuildContext context) => SplashPage(),

      // Privacy and Terms
      WiwaPrivacy.id: (context) => WiwaPrivacy(),
      WiwaTerms.id: (context) => WiwaTerms(),

      // ahia
      HomeScreen.id: (BuildContext context) => HomeScreen(),
      WelcomeScreen.id: (BuildContext context) => WelcomeScreen(),
      SetDeliveryLocation.id: (BuildContext context) => SetDeliveryLocation(),
      // MainScreen.id: (BuildContext context) => MainScreen(),
      ProductList.id: (BuildContext context) => ProductList(),
      ProductDetails.id: (BuildContext context) => ProductDetails(),
      FavouriteProductDetails.id: (BuildContext context) =>
          FavouriteProductDetails(),
      CartPage.id: (BuildContext context) => CartPage(),
      ProfileScreen.id: (BuildContext context) => ProfileScreen(),
      UpdateProfile.id: (BuildContext context) => UpdateProfile(),
      OnlinePayment.id: (BuildContext context) => OnlinePayment(),
      VendorHomeScreen.id: (BuildContext context) => VendorHomeScreen(),
      CategoryListScreen.id: (BuildContext context) => CategoryListScreen(),
      SubCatListScreen.id: (BuildContext context) => SubCatListScreen(),
      // CarSalesForm.id: (BuildContext context) => CarSalesForm(),

      // vendor
      RegisterScreen.id: (context) => RegisterScreen(),
      AddNewProduct.id: (context) => AddNewProduct(),
      VendorBanner.id: (context) => VendorBanner(),
      AddEditCoupon.id: (context) => AddEditCoupon(),

      // music
      // MusicHome.id: (context) => MusicHome(),
      AddNewSong.id: (context) => AddNewSong(),
      ArtistHomeScreen.id: (context) => ArtistHomeScreen(),

      // PlayScreen.id: (context) => AudioServiceWidget(child: PlayScreen()),
      MusicFront.id: (context) => AudioServiceWidget(child: MusicFront()),
      AlbumSongs.id: (context) => AlbumSongs(),
      GenreSongs.id: (context) => GenreSongs(),
      AlbumSongsOnProfile.id: (context) => AlbumSongsOnProfile(),
      // RhythmMainScreen.id: (context) => RhythmMainScreen(),

      // Music FrontEnd
      '/setting': (context) => SettingPage(),
      '/playlists': (context) => PlaylistScreen(),
      '/nowplaying': (context) => NowPlaying(),
      '/recent': (context) => RecentlyPlayed(),
    };
  }

  static void sendNavigationEventToFirebase(String path) {
    if (path != null && path.isNotEmpty) {
      // analytics.setCurrentScreen(screenName: path);
    }
  }

  static Route onGenerateRoute(RouteSettings settings) {
    final List<String> pathElements = settings.name.split('/');
    if (pathElements[0] != '' || pathElements.length == 1) {
      return null;
    }
    switch (pathElements[1]) {
      case "ComposeTweetPage":
        bool isRetweet = false;
        bool isTweet = false;
        if (pathElements.length == 3 && pathElements[2].contains('retweet')) {
          isRetweet = true;
        } else if (pathElements.length == 3 &&
            pathElements[2].contains('tweet')) {
          isTweet = true;
        }
        return CustomRoute<bool>(
            builder: (BuildContext context) =>
                ChangeNotifierProvider<ComposeTweetState>(
                  create: (_) => ComposeTweetState(),
                  child:
                      ComposeTweetPage(isRetweet: isRetweet, isTweet: isTweet),
                ));
      case "FeedPostDetail":
        var postId = pathElements[2];
        return SlideLeftRoute<bool>(
            builder: (BuildContext context) => FeedPostDetail(
                  postId: postId,
                ),
            settings: RouteSettings(name: 'FeedPostDetail'));
      case "ProfilePage":
        String profileId;
        if (pathElements.length > 2) {
          profileId = pathElements[2];
        }
        return CustomRoute<bool>(
            builder: (BuildContext context) => ProfilePage(
                  profileId: profileId,
                ));
      // case "MusicFront":
      //   String profileId;
      //   if (pathElements.length > 2) {
      //     profileId = pathElements[2];
      //   }
      //   return CustomRoute<bool>(
      //       builder: (BuildContext context) => MusicFront(
      //             profileId: profileId,
      //           ));
      case "CreateFeedPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) =>
                ChangeNotifierProvider<ComposeTweetState>(
                  create: (_) => ComposeTweetState(),
                  child: ComposeTweetPage(isRetweet: false, isTweet: true),
                ));
      case "WelcomePage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => WelcomePage());
      case "SignIn":
        return CustomRoute<bool>(builder: (BuildContext context) => SignIn());
      // case "Register-screen":
      //   return CustomRoute<bool>(
      //       builder: (BuildContext context) => RegisterScreen());
      case "SignUp":
        return CustomRoute<bool>(builder: (BuildContext context) => Signup());
      case "ForgetPasswordPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => ForgetPasswordPage());
      case "SearchPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => SearchPage());
      case "ImageViewPge":
        return CustomRoute<bool>(
            builder: (BuildContext context) => ImageViewPge());

      case "ChatScreenPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => ChatScreenPage());
      case "NewMessagePage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => NewMessagePage(),
        );
      case "SettingsAndPrivacyPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => SettingsAndPrivacyPage(),
        );
      case "AccountSettingsPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => AccountSettingsPage(),
        );
      case "AccountSettingsPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => AccountSettingsPage(),
        );
      case "PrivacyAndSaftyPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => PrivacyAndSaftyPage(),
        );
      case "NotificationPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => NotificationPage(),
        );
      case "ContentPrefrencePage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => ContentPrefrencePage(),
        );
      case "DisplayAndSoundPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => DisplayAndSoundPage(),
        );
      case "DirectMessagesPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => DirectMessagesPage(),
        );
      case "TrendsPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => TrendsPage(),
        );
      case "DataUsagePage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => DataUsagePage(),
        );
      case "AccessibilityPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => AccessibilityPage(),
        );
      case "ProxyPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => ProxyPage(),
        );
      case "AboutPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => AboutPage(),
        );
      case "ConversationInformation":
        return CustomRoute<bool>(
          builder: (BuildContext context) => ConversationInformation(),
        );
      case "FollowingListPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => FollowingListPage(),
        );
      case "FollowerListPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => FollowerListPage(),
        );
      case "VerifyEmailPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => VerifyEmailPage(),
        );
      default:
        return onUnknownRoute(RouteSettings(name: '/Feature'));
    }
  }

  static Route onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: customTitleText(settings.name.split('/')[1]),
          centerTitle: true,
        ),
        body: Center(
          child: Text('${settings.name.split('/')[1]} Comming soon..'),
        ),
      ),
    );
  }
}
