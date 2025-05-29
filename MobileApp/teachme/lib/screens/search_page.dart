import 'package:flutter/material.dart';
import 'package:teachme/models/adverstiment_model.dart';
import 'package:teachme/service/course_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/debouncer.dart';
import 'package:teachme/widgets/course_card.dart';
import 'package:teachme/widgets/standard_app_bar.dart';

class SearchPage extends StatefulWidget {
  static const routeName = 'search';
  final String? subjectId;
  final List<String>? specialityIds;
  final double? minPrice;
  final double? maxPrice;
  final String? order;

  const SearchPage({
    Key? key,
    this.subjectId,
    this.specialityIds,
    this.minPrice,
    this.maxPrice,
    this.order,
  }) : super(key: key);

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
  late Map<String, dynamic> _filters;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _filters = {
      'subjectId': widget.subjectId,
      'specialityIds': widget.specialityIds,
      'minPrice': widget.minPrice,
      'maxPrice': widget.maxPrice,
      'order': widget.order ?? 'date',
    };

    _loadInitialData();
  }

  void _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    if (_courses.isEmpty) {
      final result = await _courseService.searchCourses(filters: _filters);
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
        filters: _filters,
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
    final result = await _courseService.searchCourses(title: _searchController.text, filters: _filters);
    setState(() {
      _courses = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('INTERESES ${currentStudent.interestsNames.length}');
    return Scaffold(
      appBar: standardAppBar(context, "searchPage"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            SizedBox(height: 10),
            _searcher(),
            if (currentUser.isStudent) _filtersButtons(context),
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

  Widget _searcher() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Color(0xFF151515),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white30),
      ),
      height: 45,
      child: Row(
        children: [
          Icon(Icons.search, color: Color(0xFF3B82F6)),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar curso...',
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
                final isSelected = _selectedFilterIndex == index;

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
          _selectedFilterIndex = isSelected ? null : index; // Marca como seleccionado
          _filters['subjectId'] = isSelected ? null : interestId;
        });
        _loadData();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF1F3B67) : Color(0xFF151515),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.white38 : Colors.white30),
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
      decoration: BoxDecoration(
        
          color:  Color(0xFF151515),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white30),
      ),

      child: IconButton(
        color: Colors.white,
        
        icon: Icon(Icons.filter_list),
        onPressed: () {
          print('FILTER');
          _loadData();
          //TODO: Navigator.push(
          //  context,
          //  MaterialPageRoute(builder: (context) => FiltroScreen()),
          //);
        },
      ),
    );
  }
}
