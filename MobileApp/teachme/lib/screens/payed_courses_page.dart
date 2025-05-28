import 'package:flutter/material.dart';
import 'package:teachme/widgets/hamburguer_menu.dart';
import 'package:teachme/widgets/payed_courses.dart';

class PayedCoursesPage extends StatefulWidget {
  @override
  State<PayedCoursesPage> createState() => _PayedCoursesPageState();
}

class _PayedCoursesPageState extends State<PayedCoursesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payed Courses'),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [HamburguerMenu()],
      ),
      body: PayedCourses(),
    );
  }
}
