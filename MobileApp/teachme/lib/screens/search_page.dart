import 'package:flutter/material.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/widgets/standard_app_bar.dart';

class SearchPage extends StatelessWidget{
  static const routeName = 'search';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: standardAppBar(context, "searchPage"),
      body: Container(
        child: Center(child: Text(translate(context, "search"), style: TextStyle(color: Colors.white, fontSize: 24),),),
      )
    );
  }
}