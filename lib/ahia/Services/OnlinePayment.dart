import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnlinePayment extends StatelessWidget {
  static const String id = 'online-payment';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Online Payment'),
        centerTitle: true,
      ),
      body: Center(
        child: Text('Online payment coming soon'),
      ),
    );
  }
}
