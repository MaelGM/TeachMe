import 'package:flutter/material.dart';
import 'package:teachme/models/student_model.dart';
import 'package:teachme/models/subject_model.dart';
import 'package:teachme/service/auth_service.dart';
import 'package:teachme/service/subject_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/utils/utils.dart';

class ChooseInterestsPage extends StatefulWidget {
  static const routeName = "interestsPage";
  final bool editing;
  final bool? newStudent;

  const ChooseInterestsPage({
    super.key,
    required this.editing,
    this.newStudent,
  });

  @override
  State<ChooseInterestsPage> createState() => _ChooseInterestsPageState();
}

class _ChooseInterestsPageState extends State<ChooseInterestsPage> {
  final SubjectService _subjectService = SubjectService();
  List<Subject> selectedSubjects = [];
  late List<Subject> _subjects;

  bool _isLoading = false;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    _subjects = await _subjectService.getSubjects();

    if (!widget.editing || (widget.newStudent != null && widget.newStudent!)) {
      currentStudent = StudentModel(
        userId: '',
        interestsIds: [],
        interestsNames: [],
        savedAdvertisements: [], 
        payedAdvertisements: {},
      );
    } else {
      selectedSubjects = await _subjectService.getSubjectsByIds(
        currentStudent.interestsIds,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.newStudent != null && widget.newStudent!);
    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        title: Text(
          translate(context, "whatInterests"),
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        toolbarHeight: 70,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      padding: const EdgeInsets.only(bottom: 100),
                      children:
                          _subjects.map((subject) {
                            final isSelected = selectedSubjects.contains(
                              subject,
                            );
                            return _subjectBox(subject, isSelected);
                          }).toList(),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _backButton(context),
                          widget.editing ||
                                  (widget.newStudent != null &&
                                      widget.newStudent!)
                              ? _saveButton(context)
                              : _nextButton(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  ElevatedButton _backButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (!widget.editing) currentStudent.interestsIds = [];
        Navigator.pop(context);
      },

      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,
        minimumSize: Size(100, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Border radius leve
        ),
      ),
      child: Row(
        spacing: 8,
        children: [
          Icon(Icons.arrow_back, color: Colors.white),
          Text(
            translate(context, "back"),
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }

  ElevatedButton _saveButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (selectedSubjects.isNotEmpty) {
          print('GUARDANDO');
          currentStudent.interestsIds =
              selectedSubjects.map((s) => s.id).toList();
          currentStudent.interestsNames =
              selectedSubjects.map((s) => s.name).toList();
          if (widget.newStudent != null && widget.newStudent!)
            await AuthService().transformTeacherToStudent(context);
          else
            await _subjectService.updateStudentInterests(context);
        } else {
          ScaffoldMessageError(
            translate(context, 'oneInterest'),
            context,
          );
        }
      },

      style: ElevatedButton.styleFrom(
        backgroundColor:
            selectedSubjects.isEmpty ? Colors.grey : Color(0xFF3B82F6),
        minimumSize: Size(0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Border radius leve
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            translate(context, "save"),
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward, color: Colors.white),
        ],
      ),
    );
  }

  ElevatedButton _nextButton(BuildContext context) {
    AuthService authService;
    return ElevatedButton(
      onPressed:
          () =>
              selectedSubjects.isEmpty
                  ? {}
                  : {
                    currentStudent.interestsIds =
                        selectedSubjects.map((s) => s.id).toList(),
                    currentStudent.interestsNames =
                        selectedSubjects.map((s) => s.name).toList(),
                    if (creatingUser.isTeacher == false)
                      {
                        authService = AuthService(), // Instancia de AuthService
                        authService.register(context),
                      },
                  },

      style: ElevatedButton.styleFrom(
        backgroundColor:
            selectedSubjects.isEmpty ? Colors.grey : Color(0xFF3B82F6),
        minimumSize: Size(0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Border radius leve
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            translate(context, "next"),
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward, color: Colors.white),
        ],
      ),
    );
  }

  Widget _subjectBox(Subject subject, bool isSelected) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double size = constraints.maxWidth;

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedSubjects.remove(subject);
              } else {
                selectedSubjects.add(subject);
              }
            });
          },
          child: Stack(
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Color(0xFF151515),
                  border: Border.all(
                    width: 2,
                    color: isSelected ? Color(0xFF3B82F6) : Color(0xFF151515),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(subject.icon, size: 55, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      subject.name,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      subject.description,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (isSelected) _checkIcon(),
            ],
          ),
        );
      },
    );
  }

  Positioned _checkIcon() {
    return Positioned(
      top: 0,
      right: 0,
      child: CircleAvatar(
        radius: 17,
        backgroundColor: Colors.white,
        child: Icon(Icons.check, size: 18, color: Color(0xFF3B82F6)),
      ),
    );
  }
}
