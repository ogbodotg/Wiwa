import 'package:wiwa_app/ahia/Widgets/Products/AddToCartWidget.dart';
import 'package:wiwa_app/ahia/Widgets/Products/SaveForLater.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FavBottomSheetContainer extends StatefulWidget {
  final DocumentSnapshot document;

  FavBottomSheetContainer(this.document);

  @override
  _FavBottomSheetContainerState createState() =>
      _FavBottomSheetContainerState();
}

class _FavBottomSheetContainerState extends State<FavBottomSheetContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Flexible(flex: 1, child: AddToCartWidget(widget.document)),
        ],
      ),
    );
  }
}
