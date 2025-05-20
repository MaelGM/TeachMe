import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:teachme/models/adverstiment_model.dart';
import 'package:teachme/screens/profile_page.dart';
import 'package:teachme/service/course_service.dart';
import 'package:teachme/service/teacher_service.dart';
import 'package:teachme/widgets/vertical_couse_box.dart';

class OtherCoursesRecomendations extends StatefulWidget {
  @override
  State<OtherCoursesRecomendations> createState() => _OtherCoursesRecomendationsState();
}

class _OtherCoursesRecomendationsState extends State<OtherCoursesRecomendations> {
  final CourseService _courseService = CourseService();
  bool _isLoading = false;

  List<AdvertisementModel> _otherCoursesFromTeacher = [];
  List<AdvertisementModel> _otherCoursesFromSpeciality = [];

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  void dispose() {
    _otherCoursesFromTeacher = [];
    _otherCoursesFromSpeciality = [];
    
    super.dispose();
  }

  
  Future<void> _loadData() async {
    setState(() {_isLoading = true;});

    _otherCoursesFromTeacher = await _courseService.getOtherCoursesFromTeacher(CourseService.course.tutorId);
    _otherCoursesFromSpeciality = await _courseService.getOtherCoursesFromSpeciality(CourseService.course.specialityId);

    setState(() {_isLoading = false;});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if(_otherCoursesFromTeacher.isNotEmpty) _otherFromTeacher(),
        if(_otherCoursesFromSpeciality.isNotEmpty) _otherFromSpeciality(),
      ],
    );
  }

  Container _otherFromTeacher() {
    //TODO _isLoading ? Center(child: CircularProgressIndicator()) :  En el listView horizontal
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        children: [
          _topColumn(),
          _scrollHorizontalCourses(_otherCoursesFromTeacher)
        ]
      ),
    );
  }

  Container _scrollHorizontalCourses(List<AdvertisementModel> courses) {
    return Container(
          margin: EdgeInsets.only(top: 20),
          height: 240,
          child: _isLoading ? 
            Center(child: CircularProgressIndicator(),) : 
            ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: courses.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: VerticalCourseBox(course: courses[index]),
                );
              },
            ),
        );
  }

  Row _topColumn() {
    return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text('Other gigs from ${TeacherService.teacherUserAcount.username}', maxLines: 2, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),)),
            _seeMoreButton()
          ],
        );
  }

  TextButton _seeMoreButton() {
    return TextButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder:
                      (_, __, ___) => ProfilePage(user: TeacherService.teacherUserAcount, initialIndex: 1,),
                  transitionsBuilder: (_, animation, __, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;        

                    var tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));        

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              );
            }, 
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),  // Eliminar padding extra
              tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Hace que el área de tap se ajuste al contenido
            ),
            child: Text('See more', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 16),)
          );
  }

  Container _otherFromSpeciality() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('People also view', maxLines: 2, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),)),
            ],
          ),
          _scrollHorizontalCourses(_otherCoursesFromSpeciality)
        ]
      ),
    );
  }
  
}