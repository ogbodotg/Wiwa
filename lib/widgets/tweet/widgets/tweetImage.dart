import 'package:flutter/material.dart';
import 'package:wiwa_app/helper/enum.dart';
import 'package:wiwa_app/model/feedModel.dart';
import 'package:wiwa_app/state/feedState.dart';
import 'package:wiwa_app/widgets/cache_image.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:provider/provider.dart';

class TweetImage extends StatelessWidget {
  const TweetImage(
      {Key key, this.model, this.type, this.isRetweetImage = false})
      : super(key: key);

  final FeedModel model;
  final TweetType type;
  final bool isRetweetImage;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      alignment: Alignment.centerRight,
      child: model.imagePath == null
          ? SizedBox.shrink()
          : Padding(
              padding: EdgeInsets.only(
                top: 8,
              ),
              child: InkWell(
                borderRadius: BorderRadius.all(
                  Radius.circular(isRetweetImage ? 0 : 20),
                ),
                onTap: () {
                  if (type == TweetType.ParentTweet) {
                    return;
                  }
                  var state = Provider.of<FeedState>(context, listen: false);
                  state.getpostDetailFromDatabase(model.key);
                  state.setTweetToReply = model;
                  Navigator.pushNamed(context, '/ImageViewPge');
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(isRetweetImage ? 0 : 20),
                  ),
                  child: Container(
                    width:
                        context.width * (type == TweetType.Detail ? .95 : .8) -
                            8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                    ),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child:
                          CacheImage(path: model.imagePath, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
