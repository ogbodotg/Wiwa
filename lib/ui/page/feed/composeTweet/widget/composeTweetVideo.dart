import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:wiwa_app/ui/theme/theme.dart';

class ComposePostVideo extends StatefulWidget {
  final File video;
  final Function onCrossIconPressed;
  const ComposePostVideo({Key key, this.video, this.onCrossIconPressed})
      : super(key: key);

  @override
  _ComposePostVideoState createState() => _ComposePostVideoState();
}

class _ComposePostVideoState extends State<ComposePostVideo> {
  VideoPlayerController videoPlayerController;
  ChewieController chewieController;
  // VideoPlayerController controller;
  var playerWidget;
  // File importedVideo;

  @override
  void initState() {
    super.initState();

    if (widget.video.existsSync()) {
      videoPlayerController = VideoPlayerController.file(widget.video);
      videoPlayerController.initialize();

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

    // if (widget.video.existsSync()) {
    //   controller = VideoPlayerController.file(widget.video)
    //     ..addListener(() => setState(() {}))
    //     ..setLooping(true)
    //     ..initialize().then((_) => controller.play());
    // }
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    super.dispose();
    // controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('My video path is = ${widget.video}');

    // Widget buildVideoPlayer() => AspectRatio(
    //       aspectRatio: controller.value.aspectRatio,
    //       child: VideoPlayer(controller),
    //     );

    // Widget buildVideo() => Stack(
    //       children: <Widget>[
    //         buildVideoPlayer(),
    //       ],
    //     );

    return Container(
      child: widget.video == null
          ? Container()
          : Stack(
              children: <Widget>[
                InteractiveViewer(
                  child: Container(
                    alignment: Alignment.topRight,
                    child: Container(
                      height: 400,
                      width: context.width * .8,
                      child: Theme(
                          data: ThemeData.light().copyWith(
                            platform: TargetPlatform.iOS,
                          ),
                          child: playerWidget),
                      // child: controller != null &&
                      //         controller.value.initialized
                      //     ? Container(
                      //         alignment: Alignment.topCenter,
                      //         child: buildVideo())
                      //     : Container(
                      //         height: 200,
                      //         child: Center(
                      //             child: Column(
                      //           children: [
                      //             CircularProgressIndicator(),
                      //             Text('We\'re loading your media...'),
                      //             Text(
                      //                 'But, if you know what you are doing, then just go ahead and publish your post',
                      //                 style: TextStyle(color: Colors.grey))
                      //           ],
                      //         )),
                      //       ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.black54),
                    child: IconButton(
                      padding: EdgeInsets.all(0),
                      iconSize: 20,
                      onPressed: widget.onCrossIconPressed,
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
