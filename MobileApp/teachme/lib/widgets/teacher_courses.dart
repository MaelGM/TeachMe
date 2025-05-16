import 'package:flutter/material.dart';
import 'package:teachme/service/teacher_service.dart';
import 'package:teachme/widgets/course_card.dart';

class TeacherCourses extends StatefulWidget{
  const TeacherCourses({super.key});
  
  @override
  State<TeacherCourses> createState() => _TeacherCoursesState();
}

class _TeacherCoursesState extends State<TeacherCourses> {
  final TeacherService _teacherService = TeacherService();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {_isLoading = true;});
    await _teacherService.getCoursesFromTeacher(TeacherService.teacher.userId);
    setState(() {_isLoading = false;});
  }


  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => await _teacherService.getCoursesFromTeacher(TeacherService.teacher.userId), 
      child: TeacherService.courses.isEmpty && _isLoading ? Center(child: CircularProgressIndicator()) : 
        ListView.builder(
          controller: _scrollController,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: TeacherService.courses.length,
          itemBuilder: (context, index) {
            final course = TeacherService.courses[index];
            return CourseCard(course: course,);
          }
        )
    );
  }
}