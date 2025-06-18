import 'package:flutter/material.dart';
import 'package:teachme/models/adverstiment_model.dart';
import 'package:teachme/screens/filter_page.dart';
import 'package:teachme/service/course_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/debouncer.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/widgets/course_card.dart';
import 'package:teachme/widgets/standard_app_bar.dart';

class SearchPage extends StatefulWidget {
  static const routeName = 'search';

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int? _selectedFilterIndex;
  final ScrollController _scrollController = ScrollController();
  final CourseService _courseService = CourseService();
  final Debouncer _debouncer = Debouncer(milliseconds: 500);
  final TextEditingController _searchController = TextEditingController();

  List<AdvertisementModel> _courses = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _loadInitialData();
  }

  void _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    if (_courses.isEmpty) {
      final result = await _courseService.searchCourses();
      setState(() {
        _courses = result;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _onSearchChanged(String title) {
    _debouncer.run(() async {
      // Lógica para llamar a CourseService y actualizar los cursos
      List<AdvertisementModel> results = await _courseService.searchCourses(
        title: title,
      );
      setState(() {
        _courses = results;
      });
    });
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
    });
    final result = await _courseService.searchCourses(
      title: _searchController.text,
    );
    setState(() {
      _courses = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: standardAppBar(context, "searchPage"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            SizedBox(height: 10),
            if (currentUser.isStudent) _searcher(),
            if (currentUser.isStudent) _filtersButtons(context),
            if (currentUser.isTeacher && !currentUser.isStudent)
              Row(
                children: [
                  Expanded(child: _searcher()),
                  SizedBox(width: 10),
                  _filterButton(),
                ],
              ),
            SizedBox(height: 5),
            _findedCourses(),
          ],
        ),
      ),
    );
  }

  Widget _findedCourses() {
    if (_isLoading) {
      return Expanded(child: Center(child: CircularProgressIndicator()));
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          print('refresh');
          _loadData();
        },
        child:
            _courses.isEmpty
                ? ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: _noCoursesAlert(),
                    ),
                  ],
                )
                : ListView.builder(
                  controller: _scrollController,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: _courses.length,
                  itemBuilder: (context, index) {
                    final course = _courses[index];
                    return CourseCard(course: course, own: false);
                  },
                ),
      ),
    );
  }

  Widget _searcher() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Color(0xFF151515),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white30),
      ),
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.search, color: Color(0xFF3B82F6)),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: translate(context, "searching"),
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
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
              translate(context, "noCourseFound"),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              translate(context, "tryChangeFilter"),
              style: TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _filtersButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(vertical: 5),
            itemCount: currentStudent.interestsNames.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                // Botón de filtro general (con ícono)
                return _filterButton();
              } else {
                final interest = currentStudent.interestsNames[index - 1];
                final interestId = currentStudent.interestsIds[index - 1];
                final isSelected =
                    CourseService.filters['subjectId'] == interestId;

                return _interestButton(index, isSelected, interest, interestId);
              }
            },
          ),
        ),
      ],
    );
  }

  GestureDetector _interestButton(
    int index,
    bool isSelected,
    String interest,
    String interestId,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex =
              isSelected ? null : index; // Marca como seleccionado
          CourseService.filters['subjectId'] = isSelected ? null : interestId;
          CourseService.filters['specialityIds'] = [];
        });
        _loadData();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF1F3B67) : Color(0xFF151515),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white38 : Colors.white30,
          ),
        ),
        child: Center(
          child: Text(
            interest,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _filterButton() {
    return Container(
      margin: EdgeInsets.only(right: 5),
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color: Color(0xFF151515),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30),
      ),

      child: IconButton(
        color: Colors.white,

        icon: Icon(Icons.filter_list),
        onPressed: () async {
          print('FILTER');
          final result = await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => FilterPage(), // Tu pantalla destino
              transitionsBuilder: (_, animation, __, child) {
                const begin = Offset(0.0, 1.0); // De derecha a izquierda
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
          if (result) _loadData();
        },
      ),
    );
  }
}
