import 'package:flutter/material.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/widgets/standard_app_bar.dart';

class MessagesPage extends StatelessWidget{
  static const routeName = 'messages';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: standardAppBar(context, "messages"),
      body: Container(
        child: Center(child: Text(translate(context, "messages"), style: TextStyle(color: Colors.white, fontSize: 24),),),
      )
    );
  }
}