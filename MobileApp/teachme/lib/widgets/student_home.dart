
import 'package:flutter/material.dart';
import 'package:teachme/models/adverstiment_model.dart';
import 'package:teachme/models/speciality_model.dart';
import 'package:teachme/service/course_service.dart';
import 'package:teachme/service/navigation_service.dart';
import 'package:teachme/service/subject_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/widgets/vertical_couse_box.dart';

class HomeStudent extends StatefulWidget {
  @override
  State<HomeStudent> createState() => _HomeStudentState();
}

class _HomeStudentState extends State<HomeStudent> {
  List<SpecialityModel> specialities = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
    });
    if (currentStudent.interestsIds.length == 1) {
      specialities = await SubjectService().getSpecialitiesFromSubject(
        currentStudent.interestsIds[0],
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return currentStudent.interestsIds.length >= 2
        ? _subjectsHome()
        : _specialitiesHome();
  }

  Widget _subjectsHome() {
    return ListView.builder(
      itemCount: currentStudent.interestsIds.length,
      itemBuilder: (context, index) {
        final subjectId = currentStudent.interestsIds[index];
        final subjectName = currentStudent.interestsNames[index];
        return _subjectSection(subjectId, subjectName);
      },
    );
  }

  Widget _specialitiesHome() {
    return ListView.builder(
      itemCount: specialities.length,
      itemBuilder: (context, index) {
        return _specialitySection(specialities[index]);
      },
    );
  }

  Widget _specialitySection(SpecialityModel speciality) {
    return FutureBuilder<List<AdvertisementModel>>(
      future: CourseService().getOtherCoursesFromSpeciality(speciality.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 240,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return SizedBox.shrink(); // No mostrar nada si no hay cursos o error
        } else {
          // Si hay cursos, mostramos el nombre de la especialidad y los cursos
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title(speciality.name, speciality.subjectId, speciality.id),
                _scrollHorizontalCourses(snapshot.data!),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _subjectSection(String subjectId, String subjectName) {
    return FutureBuilder<List<AdvertisementModel>>(
      future: CourseService().getOtherCoursesFromSubject(subjectId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 240,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return SizedBox.shrink();
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title(subjectName, subjectId, null),
                _scrollHorizontalCourses(snapshot.data!),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _scrollHorizontalCourses(List<AdvertisementModel> courses) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      height: 240,
      child: ListView.builder(
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

  Row _title(String subjectName, String subjectId, String? specialityId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(subjectName, style: TextStyle(color: Colors.white, fontSize: 22)),
        TextButton(
          onPressed: () async {
            CourseService.filters['subjectId'] = subjectId;
            CourseService.filters['specialityIds'] = specialityId != null ? [specialityId] : null;
            navIndexNotifier.value = 1;
            setState(() {});
          },
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            translate(context, "seeMore"),
            style: TextStyle(color: Color(0xFF3B82F6), fontSize: 16),
          ),
        ),
      ],
    );
  }
}
