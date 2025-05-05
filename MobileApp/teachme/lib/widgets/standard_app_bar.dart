import 'package:flutter/material.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/widgets/widgets.dart';

AppBar standardAppBar(BuildContext context, String title) {
    return AppBar(
      leading: null,
      automaticallyImplyLeading: false,
      title: Text(translate(context, title)), 
      iconTheme: IconThemeData(color: Colors.white),
      actions: [
        HamburguerMenu()
      ],
    );
  }