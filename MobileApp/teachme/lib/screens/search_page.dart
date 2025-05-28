import 'package:flutter/material.dart';
import 'package:teachme/models/adverstiment_model.dart';
import 'package:teachme/service/course_service.dart';
import 'package:teachme/widgets/course_card.dart';
import 'package:teachme/widgets/standard_app_bar.dart';

class SearchPage extends StatefulWidget {
  static const routeName = 'search';

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ScrollController _scrollController = ScrollController();
  final CourseService _courseService = CourseService();
  List<AdvertisementModel> _courses = [];
  Map<String, dynamic> _filters = {
    'subjectId': null,
    'specialityIds': null,
    'minPrice': null,
    'maxPrice': null,
    'order': 'date',
  };

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
      final result = await _courseService.searchCourses(
        subjectId: _filters['subjectId'],
        specialityIds: _filters['specialityIds'],
        minPrice: _filters['minPrice'],
        maxPrice: _filters['maxPrice'],
        order: _filters['order'],
      );
      setState(() {
        _courses = result;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
    });
    final result = await _courseService.searchCourses(
      subjectId: _filters['subjectId'],
      specialityIds: _filters['specialityIds'],
      minPrice: _filters['minPrice'],
      maxPrice: _filters['maxPrice'],
      order: _filters['order'],
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
            _searcher(),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _filters['minPrice'] = 10.0;
                  _filters['maxPrice'] = 50.0;
                });
                _loadData(); // Carga datos inmediatamente con nuevos filtros
              },
              child: Text("Aplicar filtros de prueba"),
            ),
            SizedBox(height: 20),
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
          print(_filters['maxPrice']);
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

  Container _searcher() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      height: 45,
      child: Row(
        children: [
          Icon(Icons.search, color: Color(0xFF3B82F6)),
          SizedBox(width: 10),
          Text(
            'Buscar curso...',
            style: TextStyle(color: Colors.white38, fontSize: 16),
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
              'No se ha encontrado nigún curso',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta cambiar los filtros o busca otro tema.',
              style: TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
