import 'package:flutter/material.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/widgets/standard_app_bar.dart';

class ProfilePage extends StatelessWidget{
  static const routeName = 'profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: standardAppBar(context, "profile"),
      body: Container(
        child: Center(child: Text(translate(context, "profile"), style: TextStyle(color: Colors.white, fontSize: 24),),),
      )
    );
  }
}
