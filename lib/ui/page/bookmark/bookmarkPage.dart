import 'package:flutter/material.dart';
import 'package:wiwa_app/ahia/Pages/FavouriteScreen.dart';
import 'package:wiwa_app/helper/enum.dart';
import 'package:wiwa_app/model/feedModel.dart';
import 'package:wiwa_app/state/bookmarkState.dart';
import 'package:wiwa_app/ui/page/bookmark/BookMarkedSongs.dart';
import 'package:wiwa_app/ui/page/bookmark/BookmarkedProducts.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:wiwa_app/widgets/customAppBar.dart';
import 'package:wiwa_app/widgets/newWidget/emptyList.dart';
import 'package:wiwa_app/widgets/tweet/tweet.dart';
import 'package:provider/provider.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key key}) : super(key: key);

  static Route<T> getRoute<T>() {
    return MaterialPageRoute(
      builder: (_) {
        return Provider(
          create: (_) => BookmarkState(),
          child: ChangeNotifierProvider(
            create: (BuildContext context) => BookmarkState(),
            builder: (_, child) => BookmarkPage(),
          ),
        );
      },
    );
  }

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final List<Tab> myTabs = <Tab>[
    //  TabBar(
    // indicatorColor: Theme.of(context).primaryColor,
    // labelColor: Theme.of(context).primaryColor,
    // unselectedLabelColor: Colors.black54,
    // tabs: [
    Tab(
      text: 'Posts',
    ),
    Tab(
      text: 'Songs',
    ),
    Tab(
      text: 'Products',
    ),
    //   ],
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        initialIndex: 0,
        child: Scaffold(
            backgroundColor: TwitterColor.mystic,
            appBar: AppBar(
              title: Text("Bookmarks", style: TextStyle(color: Colors.black54)),
              // isBackButton: true,
              bottom: TabBar(
                tabs: myTabs,
              ),
            ),
            body: TabBarView(children: [
              Container(child: BookmarkPageBody()),
              Container(
                child: BookMarkedSongs(),
              ),
              Container(
                child: BookMarkedProducts(),
              ),
            ])
            // ]),
            ));
  }
}

class BookmarkPageBody extends StatelessWidget {
  const BookmarkPageBody({Key key}) : super(key: key);

  Widget _tweet(BuildContext context, FeedModel model) {
    return Container(
      color: Colors.white,
      child: Tweet(
        model: model,
        type: TweetType.Tweet,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<BookmarkState>(context);
    var list = state.tweetList;
    if (state.isbusy) {
      return SingleChildScrollView(
        child: SizedBox(
          height: 3,
          child: LinearProgressIndicator(),
        ),
      );
    } else if (list == null || list.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: EmptyList(
          'You have not bookmarked any post yet',
          subTitle: 'Bookmarked posts appear here.',
        ),
      );
    }
    return ListView.builder(
      addAutomaticKeepAlives: true,
      itemBuilder: (context, index) => _tweet(context, list[index]),
      itemCount: list.length,
    );
  }
}
