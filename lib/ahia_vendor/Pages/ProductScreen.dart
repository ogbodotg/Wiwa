import 'package:wiwa_app/ahia_vendor/Pages/AddNewProduct.dart';
import 'package:wiwa_app/ahia_vendor/Widgets/PublishedProduct.dart';
import 'package:wiwa_app/ahia_vendor/Widgets/UnPublishedProducts.dart';
import 'package:wiwa_app/widgets/newWidget/rippleButton.dart';
import 'package:wiwa_app/widgets/newWidget/title_text.dart';
import 'package:flutter/material.dart';

class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.purple),
          centerTitle: true,
          title: Text(
            'My Products/Services',
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ),
        body: Column(
          children: [
            Material(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 3),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text('Products/Services'),
                          // SizedBox(width: 10),
                          // CircleAvatar(
                          //     backgroundColor: Colors.black54,
                          //     maxRadius: 8,
                          //     child: FittedBox(
                          //       child: Padding(
                          //         padding: const EdgeInsets.all(8.0),
                          //         child: Text(
                          //           '20',
                          //           style: TextStyle(
                          //             color: Colors.white,
                          //             fontWeight: FontWeight.bold,
                          //           ),
                          //         ),
                          //       ),
                          //     )),
                        ],
                      ),
                      RippleButton(
                        onPressed: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddNewProduct()));
                          // Navigator.pushReplacementNamed(
                          //     context, AddNewProduct.id);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
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
                              Icon(Icons.add,
                                  color: Theme.of(context).primaryColor),
                              SizedBox(width: 10),
                              TitleText(
                                'Add New',
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // FlatButton.icon(
                      //   color: Theme.of(context).primaryColor,
                      //   onPressed: () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => AddNewProduct()));
                      // // Navigator.pushReplacementNamed(
                      // //     context, AddNewProduct.id);
                      //   },
                      //   icon: Icon(Icons.add, color: Colors.white),
                      //   label: Text('Add New',
                      //       style: TextStyle(color: Colors.white)),
                      // )
                    ],
                  ),
                ),
              ),
            ),
            TabBar(
              indicatorColor: Theme.of(context).primaryColor,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.black54,
              tabs: [Tab(text: 'Published'), Tab(text: 'UnPublished')],
            ),
            Expanded(
              child: Container(
                child: TabBarView(
                  children: [
                    PublishedProducts(),
                    UnPublishedProducts(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
