import 'package:wiwa_app/ahia_vendor/Auth/Login_Screen.dart';
import 'package:wiwa_app/ahia_vendor/Widgets/ImagePicker.dart';
import 'package:wiwa_app/ahia_vendor/Widgets/RegistrationForm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  static const String id = 'register-screen';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.purple),
          centerTitle: true,
          title: Text(
            'Register your store',
            // style: TextStyle(
            //     color: Colors.black87,
            //     fontSize: 18,
            //     fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(children: [
                // Column(
                //   // mainAxisSize: MainAxisSize.min,
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Text('Register your store',
                //         style: TextStyle(
                //             fontFamily: 'Signatra',
                //             fontWeight: FontWeight.bold,
                //             fontSize: 40,
                //             color: Theme.of(context).primaryColor)),
                //     SizedBox(height: 20),
                //     // Text('Register',
                //     //     style: TextStyle(fontFamily: 'Anton', fontSize: 20)),
                //   ],
                // ),
                ShopPicCard(),
                RegisterForm(),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
