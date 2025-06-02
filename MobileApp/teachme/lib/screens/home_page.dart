import 'package:flutter/material.dart';
import 'package:teachme/models/adverstiment_model.dart';
import 'package:teachme/models/models.dart';
import 'package:teachme/models/speciality_model.dart';
import 'package:teachme/service/course_service.dart';
import 'package:teachme/service/navigation_service.dart';
import 'package:teachme/service/subject_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/widgets/student_home.dart';
import 'package:teachme/widgets/vertical_couse_box.dart';
import 'package:teachme/widgets/widgets.dart';

class HomePage extends StatelessWidget {
  static const routeName = 'home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('TeachMe'),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [HamburguerMenu()],
      ),
      body: currentUser.isStudent ? HomeStudent() : HomeTeacher(),
    );
  }
}
class HomeTeacher extends StatefulWidget {
  @override
  State<HomeTeacher> createState() => _HomeTeacherState();
}

class _HomeTeacherState extends State<HomeTeacher> {
  bool _isLoading = false;
  List<Subject> randomSubjects = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
    });

    randomSubjects = await SubjectService().getRandomSubjects(count: 3);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView(
      children: [
        if (randomSubjects.isNotEmpty) ...[
          ...randomSubjects.map((subject) => _subjectSection(subject)).toList(),
        ]
      ],
    );
  }

  Widget _subjectSection(Subject subject) {
    return FutureBuilder<List<AdvertisementModel>>(
      future: CourseService().getOtherCoursesFromSubject(subject.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(height: 240, child: Center(child: CircularProgressIndicator()));
        //} else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        //  return SizedBox.shrink();
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title(subject.name, subject.id, null),
                _scrollHorizontalCourses(snapshot.data!),
              ],
            ),
          );
        }
      },
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
            'Ver más',
            style: TextStyle(color: Color(0xFF3B82F6), fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _specialitySection(SpecialityModel speciality) {
    return FutureBuilder<List<AdvertisementModel>>(
      future: CourseService().getOtherCoursesFromSpeciality(speciality.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(height: 240, child: Center(child: CircularProgressIndicator()));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox.shrink();
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(speciality.name, style: TextStyle(color: Colors.white, fontSize: 20)),
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
      margin: EdgeInsets.only(top: 10),
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: VerticalCourseBox(course: courses[index]),
          );
        },
      ),
    );
  }
}
