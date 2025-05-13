import 'package:flutter/material.dart';
import 'package:teachme/models/adverstiment_model.dart';
import 'package:teachme/screens/course_details_page.dart';
import 'package:teachme/screens/pages.dart';
import 'package:teachme/service/course_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';

class CourseCard extends StatelessWidget {
  final AdvertisementModel course;

  CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: GestureDetector(
        onTap: () {
          CourseService.course = course;
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => CourseDetailsPage(), // Tu pantalla destino
              transitionsBuilder: (_, animation, __, child) {
                const begin = Offset(1.0, 0.0); // De derecha a izquierda
                const end = Offset.zero;
                const curve = Curves.ease;
      
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );
        },
        child: Stack(
          children: [
            Card(
              color: const Color(0xFF1E1E1E),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                height: 125,
                child: Row(
                  children: [
                    // Primera imagen del curso
                    _imageCard(context),

                    // Información importante del curso (precio, nota y titulo)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Nota
                            _showScore(),
                            // Título
                            _showtitle(),
                            // Precio
                            _showPrice(),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            if(currentUser.isTeacher && course.tutorId == currentTeacher.userId)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: course.state.name != 'Active' ? Colors.green : Colors.red, // Fondo del banner
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    translate(context, course.state.name), // Mensaje del banner
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ]
        ),
      ),
    );
  }

  Widget _showPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "From  ",
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        Text(
          "${course.prices.first.toStringAsFixed(0)} €",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Text _showtitle() {
    return Text(
      course.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Row _showScore() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      
      children: [
        Icon(Icons.star, color: Colors.white, size: 18),
        const SizedBox(width: 4),
        Text(
          course.score.toStringAsFixed(1),
          style: TextStyle(
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
    );
  }

  Widget _imageCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(course.photos.first),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
