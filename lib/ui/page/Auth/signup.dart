import 'package:wiwa_app/Music/Services/FirebaseServices.dart';
import 'package:wiwa_app/ui/page/Auth/widget/facebookLoginButton.dart';
import 'package:wiwa_app/ui/page/Auth/widget/twitterLoginButton.dart';
import 'package:wiwa_app/ui/page/settings/accountSettings/privacyAndSafety/Privacy.dart';
import 'package:wiwa_app/ui/page/settings/accountSettings/privacyAndSafety/Terms.dart';
import 'package:wiwa_app/ui/page/settings/widgets/headerWidget.dart';
import 'package:wiwa_app/widgets/customFlatButton.dart';
import 'package:wiwa_app/widgets/newWidget/title_text.dart';
import 'package:flutter/material.dart';
import 'package:wiwa_app/helper/constant.dart';
import 'package:wiwa_app/helper/enum.dart';
import 'package:wiwa_app/helper/utility.dart';
import 'package:wiwa_app/model/user.dart';
import 'package:wiwa_app/ui/page/Auth/widget/googleLoginButton.dart';
import 'package:wiwa_app/state/authState.dart';
import 'package:wiwa_app/ui/theme/theme.dart';
import 'package:wiwa_app/widgets/customWidgets.dart';
import 'package:wiwa_app/widgets/newWidget/customLoader.dart';
import 'package:provider/provider.dart';

class Signup extends StatefulWidget {
  final VoidCallback loginCallback;

  const Signup({Key key, this.loginCallback}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  MusicServices _musicServices = MusicServices();
  var name;
  TextEditingController _nameController;
  TextEditingController _phoneController;
  TextEditingController _emailController;
  TextEditingController _passwordController;
  TextEditingController _confirmController;
  CustomLoader loader;

  final _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    loader = CustomLoader();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
    super.initState();
  }

  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Widget _body(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        // height: MediaQuery.of(context).size.height,
        // height: context.height - 88,

        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _entryFeild('Name', controller: _nameController),
              _entryFeild('Enter email',
                  controller: _emailController, isEmail: true),
              _entryFeild('Phone no',
                  controller: _phoneController, isPhoneNumber: true),
              _entryFeild('Enter password',
                  controller: _passwordController, isPassword: true),
              _entryFeild('Confirm password',
                  controller: _confirmController, isPassword: true),
              _submitButton(context),

              // Divider(height: 30),
              // SizedBox(height: 30),
              // _googleLoginButton(context),
              GoogleLoginButton(
                loginCallback: widget.loginCallback,
                loader: loader,
              ),
              SizedBox(height: 20),
              TwitterLoginButton(
                loginCallback: widget.loginCallback,
                loader: loader,
              ),
              SizedBox(height: 20),
              FacebookLoginButton(
                loginCallback: widget.loginCallback,
                loader: loader,
              ),
              SizedBox(height: 30),
              Divider(height: 0),
              TitleText(
                'Please, read and accept our Terms and Policies before proceeding',
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: Colors.redAccent,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      child:
                          Text('Terms', style: TextStyle(color: Colors.black)),
                      onPressed: () =>
                          Navigator.pushNamed(context, WiwaTerms.id)),
                  SizedBox(
                    width: 10,
                  ),
                  TextButton(
                      child: Text('Policies',
                          style: TextStyle(color: Colors.black)),
                      onPressed: () =>
                          Navigator.pushNamed(context, WiwaPrivacy.id)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _entryFeild(String hint,
      {TextEditingController controller,
      bool isPassword = false,
      bool isEmail = false,
      bool isPhoneNumber = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isEmail
            ? TextInputType.emailAddress
            : isPhoneNumber
                ? TextInputType.phone
                : TextInputType.text,
        style: TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.normal,
        ),
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30.0),
            ),
            borderSide: BorderSide(color: Colors.purple),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 35),
      child: CustomFlatButton(
        label: "Sign up",
        onPressed: _submitForm,
        borderRadius: 30,
      ),
    );
  }

  void _submitForm() {
    // User userID = FirebaseAuth.instance.currentUser;

    if (_emailController.text.isEmpty) {
      Utility.customSnackBar(_scaffoldKey, 'Please enter name');
      return;
    }
    if (_emailController.text.length > 27) {
      Utility.customSnackBar(
          _scaffoldKey, 'Name length cannot exceed 27 character');
      return;
    }
    if (_emailController.text == null ||
        _emailController.text.isEmpty ||
        _passwordController.text == null ||
        _passwordController.text.isEmpty ||
        _confirmController.text == null) {
      Utility.customSnackBar(_scaffoldKey, 'Please fill form carefully');
      return;
    } else if (_passwordController.text != _confirmController.text) {
      Utility.customSnackBar(
          _scaffoldKey, 'Password and confirm password did not match');
      return;
    }
    loader.showLoader(context);
    // _musicServices.sendAnalytics(_nameController.text);

    var state = Provider.of<AuthState>(context, listen: false);

    UserModel user = UserModel(
      email: _emailController.text.toLowerCase(),
      bio: 'Edit profile to update bio',
      contact: _phoneController.text,
      displayName: _nameController.text,
      dob: DateTime(1950, DateTime.now().month, DateTime.now().day + 3)
          .toString(),
      location: 'Somewhere on planet earth',
      profilePic: Constants.dummyProfilePic,
      isVerified: false,
    );

    state
        .signUp(
      user,
      password: _passwordController.text,
      scaffoldKey: _scaffoldKey,
    )
        .then((status) {
      print(status);
    }).whenComplete(
      () {
        loader.hideLoader();
        if (state.authStatus == AuthStatus.LOGGED_IN) {
          Navigator.pop(context);
          widget.loginCallback();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: customText(
          'Create a Wiwa Account',
          context: context,
          style: TextStyle(fontSize: 20, color: Colors.black54),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(child: _body(context)),
    );
  }
}
