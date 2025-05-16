import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:teachme/service/course_service.dart';
import 'package:teachme/widgets/widgets.dart';

class FocusCommentsPage extends StatefulWidget {
  @override
  State<FocusCommentsPage> createState() => _FocusCommentsPageState();
}

class _FocusCommentsPageState extends State<FocusCommentsPage> {
  final CourseService _courseService = CourseService();
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
    await CourseService().getCommentsByDate();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close),
            ),
            actions: [
              IconButton(
                onPressed: () => _showSortOptions(context),
                icon: Icon(Icons.filter_list_alt),
              ),
            ],
            title: Text('${CourseService.allRatings.length} Comments'),
          ),
          body: ListView.builder(itemBuilder: itemBuilder),
        );
  }

  void _showSortOptions(BuildContext context) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort by',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 10),
              Divider(color: const Color.fromARGB(31, 158, 158, 158)),
              ListTile(
                leading: Icon(Icons.access_time, color: Colors.white),
                title: Text(
                  "Most recent",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() {_isLoading = true;});
                  await _courseService.getCommentsByDate();
                  setState(() {_isLoading = false;});
                },
              ),
              Divider(color: const Color.fromARGB(31, 158, 158, 158)),
              ListTile(
                leading: Icon(Icons.thumb_up, color: Colors.white),
                title: Text(
                  "Most favourable",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() {_isLoading = true;});
                  await _courseService.getCommentsByRating(true);
                  setState(() {_isLoading = false;});
                },
              ),
              Divider(color: const Color.fromARGB(31, 158, 158, 158)),
              ListTile(
                leading: Icon(Icons.thumb_down, color: Colors.white),
                title: Text(
                  "Most critical",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() {_isLoading = true;});
                  await _courseService.getCommentsByRating(false);
                  setState(() {_isLoading = false;});
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
