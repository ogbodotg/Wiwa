import 'dart:io';

import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:wiwa_app/helper/enum.dart';
import 'package:wiwa_app/model/feedModel.dart';
import 'package:wiwa_app/state/feedState.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class PostVideo extends StatefulWidget {
  const PostVideo({Key key, this.model, this.type, this.isRetweetVideo = false})
      : super(key: key);

  final FeedModel model;
  final TweetType type;
  final bool isRetweetVideo;

  @override
  _PostVideoState createState() => _PostVideoState();
}

class _PostVideoState extends State<PostVideo> {
  VideoPlayerController videoPlayerController;
  ChewieController chewieController;
  var playerWidget;
  var viewCount;

  @override
  void initState() {
    super.initState();

    if (widget.model.videoPath != null) {
      videoPlayerController =
          VideoPlayerController.network(widget.model.videoPath);
      videoPlayerController.initialize().then((value) => {addViewCount()});

      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: false,
        looping: false,
        // showControls: true,
        // showControlsOnInitialize: true,
      );
      playerWidget = AspectRatio(
          // aspectRatio: 16 / 9,
          aspectRatio: videoPlayerController.value.aspectRatio,
          child: Chewie(
            controller: chewieController,
          ));
      // playerWidget = AspectRatio(
      //   aspectRatio: videoPlayerController.value.aspectRatio,
      //   child: VideoPlayer(videoPlayerController),
      // );
      // videoPlayerController.value.isInitialized
      //     ? AspectRatio(
      //         aspectRatio: videoPlayerController.value.aspectRatio,
      //         child: VideoPlayer(videoPlayerController),
      //       )
      //     : Container();
    }
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    super.dispose();
    // controller?.dispose();
  }

  // add media view count
  addViewCount() {
    var state = Provider.of<FeedState>(context, listen: false);
    state.addViewCount(widget.model);
  }

  @override
  Widget build(BuildContext context) {
    MusicServices _services = MusicServices();

    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      alignment: Alignment.centerRight,
      child: widget.model.videoPath == null
          ? SizedBox.shrink()
          : Padding(
              padding: EdgeInsets.only(
                top: 8,
              ),
              child: InkWell(
                borderRadius: BorderRadius.all(
                  Radius.circular(widget.isRetweetVideo ? 0 : 20),
                ),
                onTap: () {
                  if (widget.type == TweetType.ParentTweet) {
                    return;
                  }
                  var state = Provider.of<FeedState>(context, listen: false);
                  state.getpostDetailFromDatabase(widget.model.key);
                  state.setTweetToReply = widget.model;
                  // Navigator.pushNamed(context, '/ImageViewPge');
                },
                child: Container(
                  child: SafeArea(
                    child: Column(
                      children: [
                        Container(
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(
                              Radius.circular(widget.isRetweetVideo ? 0 : 20),
                            ),
                            child: Container(
                              height: 440,
                              width: context.width *
                                      (widget.type == TweetType.Detail
                                          ? .95
                                          : .8) -
                                  8,
                              decoration: BoxDecoration(
                                color: Theme.of(context).backgroundColor,
                              ),
                              child: Platform.isIOS
                                  ? Theme(
                                      data: ThemeData.light().copyWith(
                                        platform: TargetPlatform.iOS,
                                      ),
                                      child: playerWidget)
                                  : playerWidget,
                            ),
                          ),
                        ),
                        if (widget.model.viewCount > 0)
                          Padding(
                            padding: widget.type == TweetType.Detail
                                ? const EdgeInsets.only(right: 480.0)
                                : const EdgeInsets.only(right: 400.0),
                            child: Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.remove_red_eye,
                                      color: Theme.of(context).primaryColor),
                                  SizedBox(width: 3),
                                  Text(
                                      _services
                                          .formatNumber(widget.model.viewCount),
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
