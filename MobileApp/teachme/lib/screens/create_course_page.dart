import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:teachme/models/adverstiment_model.dart';
import 'package:teachme/models/enums/AdvertisementState.dart';
import 'package:teachme/models/speciality_model.dart';
import 'package:teachme/models/subject_model.dart';
import 'package:teachme/screens/create_versions_course_page.dart';
import 'package:teachme/service/image_service.dart';
import 'package:teachme/service/subject_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/utils.dart';

class CreateCoursePage extends StatefulWidget {
  final String teacherId;

  const CreateCoursePage({super.key, required this.teacherId});
  @override
  State<CreateCoursePage> createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  AdvertisementModel advertisement = AdvertisementModel(
    id: '', // Done
    title: '', // Done
    parametersBasic: {},
    description: '', // Done
    photos: [], // Done
    prices: [],
    publicationDate: DateTime.now(), // Done
    score: 0, // Done
    scoreCount: 0, // Done
    state: AdvertisementState.active, // Done
    specialityId: '',
    subjectId: '',
    tutorId: currentTeacher.userId, // Done
  );

  final SubjectService _subjectService = SubjectService();

  List<Subject> _subjects = [];
  List<SpecialityModel> _specialities = [];

  Subject? _selectedSubject;
  SpecialityModel? _selectedSpeciality;

  final picker = ImagePicker();
  final PageController _pageController = PageController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isImageLoading = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();

    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  void _loadInitialData() async {
    final subjects =
        await _subjectService.getSubjects(); // Asume que este método existe
    final specialities = await _subjectService.getSpecialities();

    setState(() {
      _subjects = subjects;
      _specialities = specialities;
    });
  }

  void _resetData() {
    setState(() {
      _isImageLoading = true;
    });

    advertisement = AdvertisementModel(
      id: '',
      title: '',
      parametersBasic: {},
      description: '',
      photos: [],
      prices: [],
      publicationDate: DateTime.now(),
      score: 0,
      scoreCount: 0,
      state: AdvertisementState.active,
      specialityId: '',
      subjectId: '',
      tutorId: currentTeacher.userId,
    );

    _titleController.text = '';
    _descriptionController.text = '';
    _selectedSpeciality = null;
    _selectedSubject = null;

    _loadInitialData();

    setState(() {
      _isImageLoading = false;
    });
  }

  void _onSubjectSelected(Subject? subject) async {
    if (subject == null) return;

    final specialities = await _subjectService.getSpecialitiesFromSubject(
      subject.id,
    );

    setState(() {
      _selectedSubject = subject;
      _specialities = specialities;
      _selectedSpeciality = null;

      advertisement.subjectId = subject.id;
    });
  }

  void _onSpecialitySelected(SpecialityModel? speciality) async {
    if (speciality == null) return;

    final subject = await _subjectService.getSubjectById(speciality.subjectId);

    setState(() {
      _selectedSpeciality = speciality;
      _selectedSubject = subject;

      advertisement.specialityId = speciality.id;
      advertisement.subjectId = subject.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Creando anuncio'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(onPressed: () => _resetData(), icon: Icon(Icons.refresh)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _topImage(screenHeight),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  _inputField(
                    label: 'Título *',
                    controller: _titleController,
                    hintText: 'Escriba el título...',
                  ),
                  SizedBox(height: 30),
                  _inputField(
                    label: 'Descripción *',
                    controller: _descriptionController,
                    hintText: 'Describa el curso del anuncio...',
                    minLines: 2,
                  ),
                  SizedBox(height: 30),
                  _buildSubjectDropdown(),
                  SizedBox(height: 30),
                  _buildSpecialityDropdown(),
              SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _nextButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  SizedBox _topImage(double screenHeight) {
    return SizedBox(
      height: screenHeight * 0.33,
      child:
          _isImageLoading
              ? Container(
                color: Colors.grey[850],
                child: Center(child: CircularProgressIndicator()),
              )
              : Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: advertisement.photos.length + 1,
                    itemBuilder: (context, index) {
                      if (index == advertisement.photos.length) {
                        return Container(
                          color: Colors.grey[850],
                          child: Center(
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 43, 97, 184),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () => _showImageSourceDialog(),
                                icon: Icon(Icons.add, color: Colors.white),
                                iconSize: 32,
                                splashRadius: 26,
                              ),
                            ),
                          ),
                        );
                      }
                      return Image.network(
                        advertisement.photos[index],
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  if (_currentPage != advertisement.photos.length)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(),
                          icon: Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              advertisement.photos.removeAt(_currentPage);
                            });
                          },
                          tooltip: 'Eliminar imagen',
                        ),
                      ),
                    ),
                  if (advertisement.photos.length + 1 > 1)
                    Positioned(
                      bottom: 15,
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: advertisement.photos.length + 1,
                        effect: WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          activeDotColor: Colors.white,
                          dotColor: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                ],
              ),
    );
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 35,
            top: 20,
          ),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.white),
                title: Text(
                  'Usar cámara',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.white),
                title: Text(
                  'Elegir de galería',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    setState(() {
      _isImageLoading = true;
    });
    if (pickedFile != null) {
      final newImage = await ImageService.uploadImageToCloudinary(
        File(pickedFile.path),
      );
      setState(() {
        if (newImage != null) {
          advertisement.photos.add(newImage);
          print('FOTO AÑADIDA');
        } else {
          ScaffoldMessageError(
            'Ha ocurrido un error. No se ha podido guardar la imágen',
            context,
          );
        }
        _isImageLoading = false;
      });
    } else {
      setState(() {
        _isImageLoading = false;
      });
    }
  }

  TextField _inputField({
    required String label,
    required TextEditingController controller,
    int? minLines,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      maxLines: null,
      minLines: minLines,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white38),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF3B82F6)),
        ),
      ),
    );
  }

  Widget _buildSubjectDropdown() {
    return DropdownButtonFormField<Subject>(
      value: _selectedSubject,
      onChanged: _onSubjectSelected,
      items:
          _subjects.map((subject) {
            return DropdownMenuItem<Subject>(
              value: subject,
              child: Text(subject.name, style: TextStyle(color: Colors.white)),
            );
          }).toList(),
      decoration: InputDecoration(
        labelText: 'Asignatura *',
        labelStyle: TextStyle(color: Colors.white),
        hintText: 'Selecciona una asignatura',
        hintStyle: TextStyle(color: Colors.white38),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF3B82F6)),
        ),
      ),
      dropdownColor: Colors.black87,
      iconEnabledColor: Colors.white,
    );
  }

  Widget _buildSpecialityDropdown() {
    return DropdownButtonFormField<SpecialityModel>(
      value: _selectedSpeciality,
      onChanged: _onSpecialitySelected,
      items:
          _specialities.map((speciality) {
            return DropdownMenuItem<SpecialityModel>(
              value: speciality,
              child: Text(
                speciality.name,
                style: TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
      decoration: InputDecoration(
        labelText: 'Especialidad',
        labelStyle: TextStyle(color: Colors.white),
        hintText: 'Selecciona una especialidad',
        hintStyle: TextStyle(color: Colors.white38),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF3B82F6)),
        ),
      ),
      dropdownColor: Colors.black87,
      iconEnabledColor: Colors.white,
    );
  }

  Padding _nextButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            print('Next');
            advertisement.description = _descriptionController.text;
            advertisement.title = _titleController.text;
            if (advertisement.photos.isEmpty) {
              ScaffoldMessageError(
                'Por favor, añada al menos una imagen al anuncio',
                context,
              );
            } else if (advertisement.description.isEmpty ||
                advertisement.title.isEmpty ||
                advertisement.subjectId.isEmpty) {
              ScaffoldMessageError(
                'Por favor, rellene los datos obligatorios antes de continuar',
                context,
              );
            } else {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder:
                      (_, __, ___) => CreateVersionsCoursePage(
                        advertisement: advertisement,
                      ),
                  transitionsBuilder: (_, animation, __, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;

                    var tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              );
            }
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
                'Siguiente',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
