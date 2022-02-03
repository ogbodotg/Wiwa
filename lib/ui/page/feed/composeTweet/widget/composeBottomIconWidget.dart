import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:wiwa_app/widgets/customWidgets.dart';
import 'package:image_picker/image_picker.dart';

class ComposeBottomIconWidget extends StatefulWidget {
  final TextEditingController textEditingController;
  final Function(File) onImageIconSelcted;
  final Function(File) onVideoIconSelcted;
  ComposeBottomIconWidget(
      {Key key,
      this.textEditingController,
      this.onImageIconSelcted,
      this.onVideoIconSelcted})
      : super(key: key);

  @override
  _ComposeBottomIconWidgetState createState() =>
      _ComposeBottomIconWidgetState();
}

class _ComposeBottomIconWidgetState extends State<ComposeBottomIconWidget> {
  bool reachToWarning = false;
  bool reachToOver = false;
  Color wordCountColor;
  String tweet = '';

  @override
  void initState() {
    wordCountColor = Colors.blue;
    widget.textEditingController.addListener(updateUI);
    super.initState();
  }

  void updateUI() {
    setState(() {
      tweet = widget.textEditingController.text;
      if (widget.textEditingController.text != null &&
          widget.textEditingController.text.isNotEmpty) {
        if (widget.textEditingController.text.length > 280 &&
            widget.textEditingController.text.length < 320) {
          wordCountColor = Colors.orange;
        } else if (widget.textEditingController.text.length >= 320) {
          wordCountColor = Theme.of(context).errorColor;
        } else {
          wordCountColor = Colors.blue;
        }
      }
    });
  }

  Widget _bottomIconWidget() {
    return Container(
      width: context.width,
      height: 50,
      decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Theme.of(context).dividerColor)),
          color: Theme.of(context).backgroundColor),
      child: Row(
        children: <Widget>[
          // IconButton(
          //     onPressed: () {
          //       // captureImage();
          //       setImage(ImageSource.gallery);
          //     },
          //     icon: customIcon(context,
          //         icon: AppIcon.image,
          //         istwitterIcon: true,
          //         iconColor: AppColor.primary)),
          // IconButton(
          //     onPressed: () {
          //       setImage(ImageSource.camera);
          //     },
          //     icon: customIcon(context,
          //         icon: AppIcon.camera,
          //         istwitterIcon: true,
          //         iconColor: AppColor.primary)),
          Padding(
            padding: const EdgeInsets.only(top: 7.0),
            child: IconButton(
                onPressed: () {
                  captureImage();
                },
                icon: customIcon(context,
                    icon: Icons.image,
                    istwitterIcon: true,
                    iconColor: AppColor.primary)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 7.0),
            child: IconButton(
                onPressed: () {
                  captureVideo();
                },
                icon: customIcon(context,
                    icon: Icons.video_library,
                    istwitterIcon: true,
                    iconColor: AppColor.primary)),
          ),
          Expanded(
              child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: tweet != null && tweet.length > 329
                    ? Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: customText('${320 - tweet.length}',
                            style:
                                TextStyle(color: Theme.of(context).errorColor)),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(
                            value: getTweetLimit(),
                            backgroundColor: Colors.grey,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(wordCountColor),
                          ),
                          tweet.length > 280
                              ? customText('${320 - tweet.length}',
                                  style: TextStyle(color: wordCountColor))
                              : customText('',
                                  style: TextStyle(color: wordCountColor))
                        ],
                      )),
          ))
        ],
      ),
    );
  }

  void setImage(ImageSource source) {
    Navigator.pop(context);
    // ImagePicker.pickImage(source: source, imageQuality: 20).then((File file) {
    ImagePicker()
        // .getImage(source: source, imageQuality: 20)
        // .then((PickedFile file) {
        .pickImage(source: source, imageQuality: 20)
        .then((XFile file) {
      setState(() {
        // _image = file;
        widget.onImageIconSelcted(File(file.path));
      });
    });
  }

  captureImage() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Image Upload",
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.bold)),
            children: <Widget>[
              SimpleDialogOption(
                child: Center(
                  child: Row(
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(AppIcon.image, color: Colors.grey),
                      SizedBox(width: 5),
                      Text("Select from Gallery",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                onPressed: () => setImage(ImageSource.gallery),
              ),
              SimpleDialogOption(
                child: Center(
                  child: Row(
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(AppIcon.camera, color: Colors.grey),
                      SizedBox(width: 5),
                      Text("Capture with Camera",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                onPressed: () => setImage(ImageSource.camera),
              ),
              SimpleDialogOption(
                child: Center(
                    child: Row(
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cancel, color: Colors.grey),
                    SizedBox(width: 5),
                    Text("Cancel", style: TextStyle(color: Colors.grey)),
                  ],
                )),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  // void setVideo(ImageSource source) {
  //   // ImagePicker.pickImage(source: source, imageQuality: 20).then((File file) {
  //   ImagePicker().getVideo(source: source).then((PickedFile file) {
  //     setState(() {
  //       widget.onVideoIconSelcted(File(file.path));
  //     });
  //   });
  // }

  // Video upload section
  void pickVideo(ImageSource src) async {
    Navigator.pop(context);
    final video = await ImagePicker().pickVideo(source: src);
    setState(() {
      // _image = file;
      widget.onVideoIconSelcted(File(video.path));
    });
  }

  // pickVideoFromGallery(ImageSource src) async {
  //   Navigator.pop(context);

  //   File video = await FilePicker.getFile(
  //       type: FileType.custom,
  //       allowedExtensions: ['mp4', 'mp3', 'mkv', 'mpeg']);
  //   setState(() {
  //     widget.onVideoIconSelcted(File(video.path));
  //   });
  // }

  captureVideo() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Media Upload",
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.bold)),
            children: <Widget>[
              SimpleDialogOption(
                child: Center(
                  child: Row(
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.video_library, color: Colors.grey),
                      SizedBox(width: 5),
                      Text("Select from Gallery",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                onPressed: () => pickVideo(ImageSource.gallery),
              ),
              SimpleDialogOption(
                child: Center(
                  child: Row(
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(AppIcon.camera, color: Colors.grey),
                      SizedBox(width: 5),
                      Text("Capture with Camera",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                onPressed: () => pickVideo(ImageSource.camera),
              ),
              SimpleDialogOption(
                child: Center(
                    child: Row(
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cancel, color: Colors.grey),
                    SizedBox(width: 5),
                    Text("Cancel", style: TextStyle(color: Colors.grey)),
                  ],
                )),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  double getTweetLimit() {
    if (tweet == null || tweet.isEmpty) {
      return 0.0;
    }
    if (tweet.length > 320) {
      return 1.0;
    }
    var length = tweet.length;
    var val = length * 100 / 32000.0;
    return val;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _bottomIconWidget(),
    );
  }
}
