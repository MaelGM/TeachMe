import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:teachme/models/adverstiment_model.dart';
import 'package:teachme/service/course_service.dart';
import 'package:teachme/service/navigation_service.dart';
import 'package:teachme/service/student_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/widgets/course_card.dart';

class PayedCourses extends StatefulWidget {
  const PayedCourses({super.key});

  @override
  State<PayedCourses> createState() => _PayedCoursesState();
}

class _PayedCoursesState extends State<PayedCourses> {
  final StudentService _studentService = StudentService();
  final ScrollController _scrollController = ScrollController();

  List<AdvertisementModel> _paidCourses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);

    // Cargar estudiante con sus anuncios pagados
    await _studentService.fetchFavorites(currentUser.id);

    // Obtener cursos pagados desde Firestore
    final entries = currentStudent.payedAdvertisements.entries;
    final fetchedCourses = await Future.wait(
      entries.map((entry) async {
        final course = await CourseService.getCourseById(entry.key);
        return course;
      }),
    );

    setState(() {
      _paidCourses = fetchedCourses.whereType<AdvertisementModel>().toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: _loadCourses,
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _paidCourses.isEmpty
                  ? _noCoursesAlert()
                  : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _paidCourses.length,
                    itemBuilder: (context, index) {
                      final course = _paidCourses[index];
                      return CourseCard(course: course, own: false);
                    },
                  ),
        );
      },
    );
  }

  Widget _noCoursesAlert() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_outlined, color: Colors.white, size: 60),
            const SizedBox(height: 16),
            Text(
              translate(context, "noPayedCoursesYet"),
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
                style: const TextStyle(color: Colors.white54, fontSize: 14),
                children: [
                  TextSpan(text: translate(context, "findSomething")),
                  TextSpan(
                    text: translate(context, "here"),
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            navIndexNotifier.value = 1;
                          },
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
