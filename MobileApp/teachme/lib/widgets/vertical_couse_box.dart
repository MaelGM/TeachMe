
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:teachme/models/adverstiment_model.dart';
import 'package:teachme/screens/course_details_page.dart';
import 'package:teachme/service/course_service.dart';

class VerticalCourseBox extends StatelessWidget {
  final AdvertisementModel course;

  const VerticalCourseBox({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await CourseService.setCourse(course.id);
        await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => CourseDetailsPage(),
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
      child: Container(
        width: 190,
        margin: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color.fromARGB(255, 109, 109, 109),
            width: 0.6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _imageCard(context),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [_showPrice()],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(top: 0, right: 0, child: _showScore()),
          ],
        ),
      ),
    );
  }

  Widget _imageCard(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(course.photos.first),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _showScore() {
    return Container(
      padding: EdgeInsets.only(top: 3, right: 6, bottom: 6, left: 6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(120, 0, 0, 0),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), topRight: Radius.circular(1))
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 18),
          const SizedBox(width: 4),
          Text(
            course.score.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            "(${course.scoreCount.toInt()})",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _showPrice() {
    return Row(
      children: [
        Text(
          "From ",
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 13,
          ),
        ),
        Text(
          "${course.prices.first.toStringAsFixed(0)} €",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
