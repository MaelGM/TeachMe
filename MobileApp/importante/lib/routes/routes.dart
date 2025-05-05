
import 'package:flutter/material.dart';
import 'package:teachme/screens/pages.dart';

Map<String, WidgetBuilder> getApplicationRoutes(){
  return <String, WidgetBuilder>{
    //'/':(BuildContext context) => HomePage(),
    LoginPage.routeName:(BuildContext context) => LoginPage()
  };
}