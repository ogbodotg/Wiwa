import 'package:flutter/material.dart';
import 'package:wiwa_app/ui/page/common/usersListPage.dart';
import 'package:wiwa_app/state/authState.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:provider/provider.dart';

class FollowingListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    return UsersListPage(
        pageTitle: 'Following',
        userIdsList: state.profileUserModel.followingList,
        appBarIcon: AppIcon.follow,
        emptyScreenText:
            '${state?.profileUserModel?.userName ?? state.userModel.userName} is not following anyone',
        emptyScreenSubTileText:
            'Accounts ${state?.profileUserModel?.userName ?? state.userModel.userName} follows would be listed here.');
  }
}
