import 'package:wiwa_app/model/user.dart';

class FeedModel {
  String key;
  String parentkey;
  String childRetwetkey;
  String description;
  String userId;
  int likeCount;
  int dislikeCount;
  List<String> likeList;
  List<String> dislikeList;
  int commentCount;
  int retweetCount;
  String createdAt;
  String imagePath;
  String videoPath;
  int viewCount;
  List<String> tags;
  List<String> replyTweetKeyList;
  UserModel user;
  FeedModel(
      {this.key,
      this.description,
      this.userId,
      this.likeCount,
      this.dislikeCount,
      this.commentCount,
      this.retweetCount,
      this.createdAt,
      this.imagePath,
      this.videoPath,
      this.viewCount,
      this.likeList,
      this.dislikeList,
      this.tags,
      this.user,
      this.replyTweetKeyList,
      this.parentkey,
      this.childRetwetkey});
  toJson() {
    return {
      "userId": userId,
      "description": description,
      "likeCount": likeCount,
      "dislikeCount": dislikeCount,
      "commentCount": commentCount ?? 0,
      "retweetCount": retweetCount ?? 0,
      "createdAt": createdAt,
      "imagePath": imagePath,
      "videoPath": videoPath,
      "viewCount": viewCount ?? 0,
      "likeList": likeList,
      "dislikeList": dislikeList,
      "tags": tags,
      "replyTweetKeyList": replyTweetKeyList,
      "user": user == null ? null : user.toJson(),
      "parentkey": parentkey,
      "childRetwetkey": childRetwetkey
    };
  }

  FeedModel.fromJson(Map<dynamic, dynamic> map) {
    key = map['key'];
    description = map['description'];
    userId = map['userId'];
    //  name = map['name'];
    //  profilePic = map['profilePic'];
    likeCount = map['likeCount'] ?? 0;
    dislikeCount = map['dislikeCount'] ?? 0;
    commentCount = map['commentCount'];
    retweetCount = map["retweetCount"] ?? 0;
    imagePath = map['imagePath'];
    createdAt = map['createdAt'];
    imagePath = map['imagePath'];
    videoPath = map['videoPath'];
    viewCount = map['viewCount'] ?? 0;
    //  username = map['username'];
    user = UserModel.fromJson(map['user']);
    parentkey = map['parentkey'];
    childRetwetkey = map['childRetwetkey'];
    if (map['tags'] != null) {
      tags = <String>[];
      map['tags'].forEach((value) {
        tags.add(value);
      });
    }
    if (map["likeList"] != null) {
      likeList = <String>[];

      final list = map['likeList'];

      /// In new tweet db schema likeList is stored as a List<String>()
      ///
      if (list is List) {
        map['likeList'].forEach((value) {
          if (value is String) {
            likeList.add(value);
          }
        });
        likeCount = likeList.length ?? 0;
      }

      /// In old database tweet db schema likeList is saved in the form of map
      /// like list map is removed from latest code but to support old schema below code is required
      /// Once all user migrated to new version like list map support will be removed
      else if (list is Map) {
        list.forEach((key, value) {
          likeList.add(value["userId"]);
        });
        likeCount = list.length;
      }
    } else {
      likeList = [];
      likeCount = 0;
    }
    // dislike
    if (map["dislikeList"] != null) {
      dislikeList = <String>[];

      final list = map['dislikeList'];

      /// In new tweet db schema likeList is stored as a List<String>()
      ///
      if (list is List) {
        map['dislikeList'].forEach((value) {
          if (value is String) {
            dislikeList.add(value);
          }
        });
        dislikeCount = dislikeList.length ?? 0;
      }

      /// In old database tweet db schema likeList is saved in the form of map
      /// like list map is removed from latest code but to support old schema below code is required
      /// Once all user migrated to new version like list map support will be removed
      else if (list is Map) {
        list.forEach((key, value) {
          dislikeList.add(value["userId"]);
        });
        dislikeCount = list.length;
      }
    } else {
      dislikeList = [];
      dislikeCount = 0;
    }
    //repost
    if (map['replyTweetKeyList'] != null) {
      map['replyTweetKeyList'].forEach((value) {
        replyTweetKeyList = <String>[];
        map['replyTweetKeyList'].forEach((value) {
          replyTweetKeyList.add(value);
        });
      });
      commentCount = replyTweetKeyList.length;
    } else {
      replyTweetKeyList = [];
      commentCount = 0;
    }
  }

  bool get isValidTweet {
    bool isValid = false;
    if (this.user != null &&
        this.user.userName != null &&
        this.user.userName.isNotEmpty) {
      isValid = true;
    } else {
      print("Invalid Tweet found. Id:- $key");
    }
    return isValid;
  }

  /// get tweet key to retweet.
  ///
  /// If tweet [TweetType] is [TweetType.Retweet] and its description is null
  /// then its retweeted child tweet will be shared.
  String get getTweetKeyToRetweet {
    if (this.description == null &&
        this.imagePath == null &&
        this.videoPath == null &&
        this.childRetwetkey != null) {
      return this.childRetwetkey;
    } else {
      return this.key;
    }
  }
}
