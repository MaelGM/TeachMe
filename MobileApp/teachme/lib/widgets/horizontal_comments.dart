import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teachme/models/rating_model.dart';
import 'package:teachme/providers/language_provider.dart';
import 'package:teachme/service/course_service.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/screens/focus_comments_page.dart';
import 'package:teachme/widgets/no_comments_alert.dart';
import 'package:timeago/timeago.dart' as timeago;

class HorizontalComments extends StatefulWidget {
  const HorizontalComments({super.key});

  @override
  State<HorizontalComments> createState() => _HorizontalCommentsState();
}

class _HorizontalCommentsState extends State<HorizontalComments> {
  @override
  Widget build(BuildContext context) {
    print(CourseService.ratings.length);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        border: Border.symmetric(
          horizontal: BorderSide(
            width: 1,
            color: Color.fromARGB(255, 44, 44, 44),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _topColumn(),
          SizedBox(height: CourseService.ratings.isEmpty ? 0 : 8),
          SizedBox(
            height: 180,
            child:
                CourseService.ratings.isEmpty
                    ? NoCommentsAlert()
                    : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: CourseService.ratings.length,
                      itemBuilder: (context, index) {
                        final rating = CourseService.ratings[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: _commentBox(rating),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _commentBox(RatingModel rating) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 109, 109, 109),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(rating.userPhotoUrl),
                radius: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  rating.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.star, color: Colors.amber, size: 16),
              SizedBox(width: 2),
              Text(
                rating.score.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            rating.comment,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              _timeAgoComment(context, rating),
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgoComment(BuildContext context, RatingModel rating) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    return timeago.format(
      rating.date,
      locale:
          supportedLanguages.contains(languageProvider.locale.toString())
              ? languageProvider.locale.toString()
              : 'en',
    );
  }

  Row _topColumn() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _showCourseScore(),
        TextButton(
          onPressed: () async {
            print('see all');
            await CourseService().getCommentsByDate();
            await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => FocusCommentsPage(),
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
          },
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(
              EdgeInsets.zero,
            ), // Eliminar padding extra
            tapTargetSize:
                MaterialTapTargetSize
                    .shrinkWrap, // Hace que el área de tap se ajuste al contenido
          ),
          child: Text(
            translate(context, "seeAll"),
            style: TextStyle(color: Color(0xFF3B82F6), fontSize: 16),
          ),
        ),
      ],
    );
  }

  Row _showCourseScore() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        Icon(Icons.star, color: Colors.white, size: 22),
        const SizedBox(width: 4),
        Text(
          CourseService.course.score.toStringAsFixed(1),
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          "(${CourseService.course.scoreCount.toInt()})",
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
      ],
    );
  }
}
