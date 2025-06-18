import 'package:flutter/material.dart';
import 'package:teachme/screens/create_course_page.dart';
import 'package:teachme/service/teacher_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/widgets/course_card.dart';

class TeacherCourses extends StatefulWidget {
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
    setState(() {
      _isLoading = true;
    });
    await _teacherService.getCoursesFromTeacher(TeacherService.teacher.userId);
    setState(() {
      _isLoading = false;
    });
  }

  @override
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return RefreshIndicator(
        onRefresh: () async => await _loadCourses(),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : TeacherService.courses.isEmpty
                ? Stack(
                    children: [
                      if (currentUser.id == TeacherService.teacher.userId)
                        _addCourseButton(context),
                      ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [_noCoursesAlert()],
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: TeacherService.courses.length,
                        itemBuilder: (context, index) {
                          final course = TeacherService.courses[index];
                          return CourseCard(course: course, own: true);
                        },
                      ),
                      if (currentUser.id == TeacherService.teacher.userId)
                        _addCourseButton(context),
                    ],
                  ),
      );
    },
  );
}


  Positioned _addCourseButton(BuildContext context) {
    return Positioned(
      bottom: 16.0,
      right: 16.0,
      child: FloatingActionButton(
        backgroundColor: Color(0xFF3B82F6),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CreateCoursePage(
                    teacherId: TeacherService.teacher.userId,
                  ),
            ),
          );
          if (result == true) {
            setState(() {});
          }
        },
        child: Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _noCoursesAlert() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined, color: Colors.white, size: 60),
            const SizedBox(height: 16),
            Text(
              translate(context, "noOwnCoursesYet"),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              translate(context, "ownCoursesWillAppear"),
              style: TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
