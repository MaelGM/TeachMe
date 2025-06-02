import 'package:flutter/material.dart';
import 'package:teachme/models/speciality_model.dart';
import 'package:teachme/service/course_service.dart';
import 'package:teachme/service/subject_service.dart';

class FilterPage extends StatefulWidget {
  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final SubjectService _subjectService = SubjectService();

  List<SpecialityModel>? specialities = [];

  String? subjectId = CourseService.filters['subjectId'];
  List<dynamic>? specialityIds = CourseService.filters['specialityIds'] ?? [];
  String? order = CourseService.filters['order'] ?? 'date';

  bool showMoreSubjects = false;

  @override
  void initState() {
    if (SubjectService.subjetcs.isEmpty) _loadSubjects();
    if (subjectId != null && subjectId!.isNotEmpty) _loadSpecialities();
    super.initState();
  }

  void _resetData() {
    subjectId = null;
    specialityIds = [];
    order = 'date';
    setState(() {});
  }

  void _applyfilters() {
    CourseService.filters['subjectId'] = subjectId;
    CourseService.filters['specialityIds'] = specialityIds ?? [];
    CourseService.filters['order'] = order ?? 'date';

    Navigator.pop(context, true);
  }

  void _loadSubjects() async {
    await _subjectService.getSubjects();
    setState(() {});
  }

  void _loadSpecialities() async {
    final result = await _subjectService.getSpecialitiesFromSubject(subjectId!);
    setState(() {
      specialities = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filters'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context, false),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () => _resetData(),
            icon: Icon(Icons.refresh, color: Colors.white),
          ),
          SizedBox(width: 5),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        child: ListView(
          children: [
            Text(
              'Sort by: ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            _sortChips(),
            SizedBox(height: 15),
            _subjectSection(),
            if (subjectId != null) _specialitySection(),
            SizedBox(height: 10),
            _applyButton()
          ],
        ),
      ),
    );
  }

  Widget _subjectSection() {
    final subjects = SubjectService.subjetcs;
    final visibleSubjects =
        showMoreSubjects ? subjects : subjects.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Materia:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children:
              visibleSubjects.map((subject) {
                return ChoiceChip(
                  label: Text(
                    subject.name,
                    style: TextStyle(color: Colors.white),
                  ),
                  selected: subjectId == subject.id,
                  onSelected: (_) {
                    setState(() {
                      subjectId = subjectId == subject.id ? null : subject.id;
                      specialityIds = [];
                      _loadSpecialities();
                    });
                  },
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color:
                          subjectId == subject.id
                              ? Colors.white30
                              : Colors.white30,
                      width: subjectId == subject.id ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  selectedColor: Color(0xFF1F3B67),
                  backgroundColor: Colors.grey[850],
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontSize: subjectId == subject.id ? 14.5 : 13.5,
                    fontWeight:
                        subjectId == subject.id ? FontWeight.bold : null,
                  ),
                );
              }).toList(),
        ),
        if (subjects.length > 5)
          TextButton(
            onPressed: () {
              setState(() {
                showMoreSubjects = !showMoreSubjects;
              });
            },
            child: Text(
              showMoreSubjects ? 'Ver menos' : 'Ver todos',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _specialitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Especialidades:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children:
              (specialities ?? []).map((speciality) {
                return FilterChip(
                  label: Text(
                    speciality.name,
                    style: TextStyle(color: Colors.white),
                  ),
                  selected: specialityIds!.contains(speciality.id),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        specialityIds!.add(speciality.id);
                      } else {
                        specialityIds!.remove(speciality.id);
                      }
                    });
                  },
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color:
                          specialityIds!.contains(speciality.id)
                              ? Colors.white30
                              : Colors.white30,
                      width: specialityIds!.contains(speciality.id) ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  avatar: null,
                  selectedColor: Color(0xFF1F3B67),
                  backgroundColor: Colors.grey[850],
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontSize:
                        specialityIds!.contains(speciality.id) ? 14.5 : 13.5,
                    fontWeight:
                        specialityIds!.contains(speciality.id)
                            ? FontWeight.bold
                            : null,
                  ),
                );
              }).toList(),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Padding _applyButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            print('Apply');
            _applyfilters();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 43, 97, 184),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Aplicar',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sortChips() {
    final Map<String, String> options = {
      'date': 'Más reciente',
      'date2': 'Más antiguo',
      'scoreCount': 'Más popular',
      'score': 'Mejor valorado',
      'score2': 'Peor valorado',
      'title': 'Alfabéticamente',
    };

    return Wrap(
      spacing: 15,
      children:
          options.entries.map((entry) {
            final key = entry.key;
            final label = entry.value;

            return ChoiceChip(
              label: Text(label),
              selected: order == key,
              onSelected: (selected) {
                setState(() {
                  order = key;
                });
              },
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: order == key ? Colors.white30 : Colors.white30,
                  width: order == key ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              avatar: null,
              selectedColor: Color(0xFF1F3B67),
              backgroundColor: Colors.grey[850],
              labelStyle: TextStyle(
                color: Colors.white,
                fontSize: order == key ? 14.5 : 13.5,
                fontWeight: order == key ? FontWeight.bold : null,
              ),
            );
          }).toList(),
    );
  }
}
