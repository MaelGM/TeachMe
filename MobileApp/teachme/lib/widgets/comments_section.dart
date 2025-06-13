import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teachme/screens/create_comment_page.dart';
import 'package:teachme/service/teacher_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/widgets/rating_card.dart';

class CommentsSection extends StatefulWidget {
  const CommentsSection({super.key});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final ScrollController _scrollController = ScrollController();
  final TeacherService _teacherService = TeacherService();

  DocumentSnapshot? _lastDocument;

  bool _isLoading = false;
  bool _hasMoreComments = true;
  bool get _dateOrder => TeacherService.dateOrder;
  bool get _goodRatingOrder => TeacherService.goodRatingOrder;

  @override
  void initState() {
    super.initState();
    if (TeacherService.ratings.isEmpty) _fetchInitialRatings();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMoreComments) {
      //_fetchMoreRatings();
    }
  }

  Future<void> _fetchInitialRatings() async {
    setState(() => _isLoading = true);
    try {
      if (_dateOrder)
        await _teacherService.getCommentsByDate(null);
      else if (_goodRatingOrder)
        await _teacherService.getCommentsByScoreDescending(null);
      else
        await _teacherService.getCommentsByScoreAscending(null);

      if (TeacherService.ratings.isEmpty) {
        _hasMoreComments = false;
      }
    } catch (e) {
      print("Error cargando comentarios iniciales: $e");
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async => await _fetchInitialRatings(),
          child:
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : TeacherService.ratings.isEmpty
                  ? _noCommentsAlert()
                  : Positioned.fill(
                    // Aquí se asegura de ocupar todo el espacio
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10,
                      ),
                      itemCount:
                          TeacherService.ratings.length +
                          1 +
                          (_hasMoreComments ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildHeader();
                        } else if (index <= TeacherService.ratings.length) {
                          final rating = TeacherService.ratings[index - 1];
                          return RatingCard(rating: rating);
                        }
                        return null;
                      },
                    ),
                  ),
        ),
        if (currentUser.id != TeacherService.teacher.userId)
          Positioned(
            bottom: 39.0,
            right: 16.0,
            child: FloatingActionButton(
              backgroundColor: Color(0xFF3B82F6),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CreateCommentPage(
                          teacherId: TeacherService.teacher.userId,
                        ),
                  ),
                );
                if (result == true) {
                  setState(() {});
                }
              },
              child: Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
      ],
    );
  }

  Widget _noCommentsAlert() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.comment_bank_outlined,
                  color: Colors.white,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aún no hay comentarios',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Cuando recibas comentarios de estudiantes,\naparecerán aquí.',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        _showScore(),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sorted by',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _showSortOptions(context),
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                  EdgeInsets.zero,
                ), // Eliminar padding extra
                tapTargetSize:
                    MaterialTapTargetSize
                        .shrinkWrap, // Hace que el área de tap se ajuste al contenido
              ),
              child: _textButtonText(),
            ),
          ],
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Row _showScore() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Overall rating',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            Icon(Icons.star, color: Colors.white, size: 22),
            SizedBox(width: 4),
            Text(
              TeacherService.teacher.rating.toStringAsFixed(1),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Text _textButtonText() {
    if (_dateOrder) {
      return Text(
        'Most recent',
        style: TextStyle(color: Color(0xFF3B82F6), fontSize: 16),
      );
    } else if (_goodRatingOrder) {
      return Text(
        'Most favourable',
        style: TextStyle(color: Color(0xFF3B82F6), fontSize: 16),
      );
    } else {
      return Text(
        'Most critical',
        style: TextStyle(color: Color(0xFF3B82F6), fontSize: 16),
      );
    }
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
                  await _teacherService.getCommentsByDate(_lastDocument);
                  setState(() {
                    TeacherService.dateOrder = true;
                    TeacherService.goodRatingOrder = false;
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
                  await _teacherService.getCommentsByScoreDescending(
                    _lastDocument,
                  );
                  setState(() {
                    TeacherService.dateOrder = false;
                    TeacherService.goodRatingOrder = true;
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
                  await _teacherService.getCommentsByScoreAscending(
                    _lastDocument,
                  );
                  setState(() {
                    TeacherService.dateOrder = false;
                    TeacherService.goodRatingOrder = false;
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
