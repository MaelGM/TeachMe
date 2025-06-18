
import 'package:flutter/material.dart';
import 'package:teachme/screens/choose_language_page.dart';
import 'package:teachme/screens/course_details_page.dart';
import 'package:teachme/screens/forgot_password_page.dart';
import 'package:teachme/screens/pages.dart';
import 'package:teachme/utils/config.dart';

Map<String, WidgetBuilder> getApplicationRoutes(){
  return <String, WidgetBuilder>{
    //'/':(BuildContext context) => HomePage(),
    AccessPage.routeName:(BuildContext context) => AccessPage(),
    ForgotPasswordPage.routeName: (context) => ForgotPasswordPage(),
    HomePage.routeName:(BuildContext context) => HomePage(),
    NavBarPage.routeName:(BuildContext context) => NavBarPage(),
    MessagesPage.routeName:(BuildContext context) => MessagesPage(),
    ProfilePage.routeName:(BuildContext context) => ProfilePage(user: currentUser,),
    SearchPage.routeName:(BuildContext context) => SearchPage(),
    SigninFormPage.routeName:(BuildContext context) => SigninFormPage(),
    ChooseInterestsPage.routeName:(BuildContext context) => ChooseInterestsPage(editing: false),
    ChooseLanguagePage.routeName:(BuildContext context) => ChooseLanguagePage(),
    CourseDetailsPage.routeName:(BuildContext context) => CourseDetailsPage(),

  };
}