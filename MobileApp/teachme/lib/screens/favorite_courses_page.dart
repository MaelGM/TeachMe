import 'package:flutter/material.dart';
import 'package:teachme/widgets/favorite_courses.dart';
import 'package:teachme/widgets/hamburguer_menu.dart';

class FavoriteCoursesPage extends StatefulWidget {
  @override
  State<FavoriteCoursesPage> createState() => _FavoriteCoursesPageState();
}

class _FavoriteCoursesPageState extends State<FavoriteCoursesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Courses'),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [HamburguerMenu()],
      ),
      body: FavoriteCourses(),
    );
  }
}
