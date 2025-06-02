import 'package:flutter/material.dart';
import 'package:teachme/models/rating_model.dart';
import 'package:teachme/screens/create_comment_page.dart';
import 'package:teachme/service/course_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/widgets/no_comments_alert.dart';
import 'package:teachme/widgets/rating_card.dart';

class FocusCommentsPage extends StatefulWidget {
  @override
  State<FocusCommentsPage> createState() => _FocusCommentsPageState();
}

class _FocusCommentsPageState extends State<FocusCommentsPage> {
  final CourseService _courseService = CourseService();
  bool _isLoading = false;
  bool get _dateOrder => CourseService.dateOrder;
  bool get _goodRatingOrder => CourseService.goodRatingOrder;

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
    if (_dateOrder) {
      await _courseService.getCommentsByDate();
    } else if (_goodRatingOrder) {
      await _courseService.getCommentsByRating(true);
    } else {
      await _courseService.getCommentsByRating(false);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Text(
          CourseService.allRatings.isEmpty
              ? 'No comments'
              : '${CourseService.allRatings.length} Comments',
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : CourseService.allRatings.isEmpty
              ? NoCommentsAlert()
              : ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10,
                ),
                itemCount: CourseService.allRatings.length,
                itemBuilder: (context, index) {
                  final RatingModel rating = CourseService.allRatings[index];
                  return RatingCard(rating: rating);
                },
              ),
      floatingActionButton:
          currentUser.isTeacher &&
                  currentTeacher.userId == CourseService.course.tutorId
              ? null
              : FloatingActionButton(
                backgroundColor: Color(0xFF3B82F6),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CreateCommentPage(
                            courseId: CourseService.course.id,
                          ),
                    ),
                  );
                },
                child: Icon(Icons.add, color: Colors.white, size: 28,),
              ),
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
                  setState(() {
                    _isLoading = true;
                  });
                  await _courseService.getCommentsByDate();
                  setState(() {
                    _isLoading = false;
                  });
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
                  setState(() {
                    _isLoading = true;
                  });
                  await _courseService.getCommentsByRating(true);
                  setState(() {
                    _isLoading = false;
                  });
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
                  setState(() {
                    _isLoading = true;
                  });
                  await _courseService.getCommentsByRating(false);
                  setState(() {
                    _isLoading = false;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
