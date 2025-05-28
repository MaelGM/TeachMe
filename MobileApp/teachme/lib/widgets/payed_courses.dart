import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:teachme/service/navigation_service.dart';
import 'package:teachme/service/student_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/widgets/course_card.dart';

class PayedCourses extends StatefulWidget {
  const PayedCourses({super.key});

  @override
  State<PayedCourses> createState() => _PayedCoursesState();
}

class _PayedCoursesState extends State<PayedCourses> {
  final StudentService _studentService = StudentService();
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
    await _studentService.fetchFavorites(currentUser.id);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh:
          () async => await _studentService.fetchFavorites(currentUser.id),
      child:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : currentStudent.payedAdvertisements.isEmpty
              ? _noCoursesAlert()
              : ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                itemCount: currentStudent.payedAdvertisements.length,
                itemBuilder: (context, index) {
                  final course = currentStudent.payedAdvertisements[index];
                  return CourseCard(course: course, own: false);
                },
              ),
    );
  }

  Widget _noCoursesAlert() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined, color: Colors.white, size: 60),
            const SizedBox(height: 16),
            Text(
              'Aún no has pagado ningún servício o curso',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(color: Colors.white54, fontSize: 14),
                children: [
                  TextSpan(text: 'Encuentra algo que te guste '),
                  TextSpan(
                    text: 'aquí',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            navIndexNotifier.value = 1;
                          },
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
