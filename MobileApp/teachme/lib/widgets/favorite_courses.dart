import 'package:flutter/material.dart';
import 'package:teachme/models/adverstiment_model.dart';
import 'package:teachme/service/course_service.dart';
import 'package:teachme/service/student_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/widgets/course_card.dart';

class FavoriteCourses extends StatefulWidget {
  const FavoriteCourses({super.key});

  @override
  State<FavoriteCourses> createState() => _FavoriteCoursesState();
}

class _FavoriteCoursesState extends State<FavoriteCourses> {
  final StudentService _studentService = StudentService();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  List<AdvertisementModel> _favoriteCourses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);

    await _studentService.fetchFavorites(currentUser.id);

    final fetchedCourses = await Future.wait(
      currentStudent.savedAdvertisements.map((courseId) async {
        final course = await CourseService.getCourseById(courseId);
        return course;
      }),
    );

    setState(() {
      _favoriteCourses =
          fetchedCourses.whereType<AdvertisementModel>().toList();
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
                  : _favoriteCourses.isEmpty
                  ? _noCoursesAlert()
                  : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _favoriteCourses.length,
                    itemBuilder: (context, index) {
                      final course = _favoriteCourses[index];
                      return CourseCard(
                        course: course,
                        own: false,
                        onRefresh: _loadCourses,
                      );
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
              translate(context, "noFavCourses"),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              translate(context, "howToHaveAFavCourse"),
              style: TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
