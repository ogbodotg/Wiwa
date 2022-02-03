import 'package:flutter/material.dart';
import 'package:wiwa_app/model/feedModel.dart';
import 'package:wiwa_app/model/user.dart';
import 'package:wiwa_app/state/feedState.dart';
import 'package:wiwa_app/state/notificationState.dart';
import 'package:wiwa_app/ui/page/feed/feedPostDetail.dart';
import 'package:wiwa_app/ui/page/profile/profilePage.dart';
import 'package:wiwa_app/ui/page/profile/widgets/circular_image.dart';
import 'package:wiwa_app/ui/theme/custom_icon_icons.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:wiwa_app/widgets/customWidgets.dart';
import 'package:wiwa_app/widgets/newWidget/title_text.dart';
import 'package:wiwa_app/widgets/url_text/customUrlText.dart';
import 'package:provider/provider.dart';

class PostDislikeTile extends StatelessWidget {
  final FeedModel model;
  const PostDislikeTile({Key key, this.model}) : super(key: key);
  Widget _userList(BuildContext context, List<String> list) {
    // List<String> names = [];
    var length = list.length;
    List<Widget> avaterList = [];
    final int noOfUser = list.length;
    var state = Provider.of<NotificationState>(context);
    if (list != null && list.length > 5) {
      list = list.take(5).toList();
    }
    avaterList = list.map((userId) {
      return _userAvater(userId, state, (name) {
        // names.add(name);
      });
    }).toList();
    if (noOfUser > 5) {
      avaterList.add(
        Text(
          " +${noOfUser - 5}",
          style: TextStyles.subtitleStyle.copyWith(fontSize: 16),
        ),
      );
    }

    var col = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(width: 20),
            customIcon(context,
                icon: CustomIcon.thumbs_down_alt,
                // icon: AppIcon.heartFill,
                iconColor: TwitterColor.ceriseRed,
                istwitterIcon: true,
                size: 25),
            SizedBox(width: 10),
            Row(children: avaterList),
          ],
        ),
        // names.length > 0 ? Text(names[0]) : SizedBox(),
        Padding(
          padding: EdgeInsets.only(left: 60, bottom: 5, top: 5),
          child: TitleText(
            length > 1
                ? '$length people disliked your post'
                : '$length person disliked your post',
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        )
      ],
    );
    return col;
  }

  Widget _userAvater(
      String userId, NotificationState state, ValueChanged<String> name) {
    return FutureBuilder(
      future: state.getuserDetail(userId),
      //  initialData: InitialData,
      builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
        if (snapshot.hasData) {
          name(snapshot.data.displayName);
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    ProfilePage.getRoute(profileId: snapshot.data?.userId));
              },
              child: CircularImage(path: snapshot.data.profilePic, height: 30),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String description = "";
    if (model.description != null) {
      description = model.description.length > 150
          ? model.description.substring(0, 150) + '...'
          : model.description;
    }
    return model.dislikeList.length > 0
        ? Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                color: TwitterColor.white,
                child: ListTile(
                  onTap: () {
                    var state = Provider.of<FeedState>(context, listen: false);
                    state.getpostDetailFromDatabase(null, model: model);

                    Navigator.push(context, FeedPostDetail.getRoute(model.key));
                  },
                  title: _userList(context, model.dislikeList),
                  subtitle: Padding(
                    padding: EdgeInsets.only(left: 60),
                    child: UrlText(
                      text: description,
                      style: TextStyle(
                        color: AppColor.darkGrey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              Divider(height: 0, thickness: .6)
            ],
          )
        : Container();
  }
}
