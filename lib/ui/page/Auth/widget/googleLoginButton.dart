import 'package:flutter/material.dart';
import 'package:wiwa_app/helper/utility.dart';
import 'package:wiwa_app/state/authState.dart';
import 'package:wiwa_app/widgets/newWidget/customLoader.dart';
import 'package:wiwa_app/widgets/newWidget/rippleButton.dart';
import 'package:wiwa_app/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({Key key, @required this.loader, this.loginCallback});
  final CustomLoader loader;
  final Function loginCallback;
  void _googleLogin(context) {
    var state = Provider.of<AuthState>(context, listen: false);
    loader.showLoader(context);
    state.handleGoogleSignIn().then((status) {
      // print(status)
      if (state.user != null) {
        loader.hideLoader();
        Navigator.pop(context);
        loginCallback();
      } else {
        loader.hideLoader();
        cprint('Unable to login', errorIn: '_googleLoginButton');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RippleButton(
      onPressed: () {
        _googleLogin(context);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0xffeeeeee),
              blurRadius: 15,
              offset: Offset(5, 5),
            ),
          ],
        ),
        child: Wrap(
          children: <Widget>[
            Image.asset(
              'assets/images/google_logo.png',
              height: 30,
              width: 30,
            ),
            SizedBox(width: 10),
            TitleText(
              'Continue with Google',
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
