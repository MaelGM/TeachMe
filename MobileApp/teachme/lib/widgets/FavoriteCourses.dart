import 'package:flutter/material.dart';
import 'package:teachme/service/student_service.dart';
import 'package:teachme/service/teacher_service.dart';
import 'package:teachme/utils/config.dart';
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
    print(_studentService.favorites.length);
    return RefreshIndicator(
      onRefresh:
          () async => await _studentService.fetchFavorites(currentUser.id),
      child:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _studentService.favorites.isEmpty
              ? _noCoursesAlert()
              : ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                itemCount: _studentService.favorites.length,
                itemBuilder: (context, index) {
                  final course = _studentService.favorites[index];
                  return CourseCard(course: course, own: false,);
                },
              ),
    );
  }

  Widget _noCoursesAlert() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined, color: Colors.white, size: 60),
          const SizedBox(height: 16),
          Text(
            'Aún no hay ningún tienes ningún curso como favorito',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Guardate un curso como favorito, y se almacenará aquí.',
            style: TextStyle(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
