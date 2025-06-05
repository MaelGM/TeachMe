import 'package:flutter/material.dart';
import 'package:teachme/models/adverstiment_model.dart';
import 'package:teachme/models/enums/AdvertisementState.dart';
import 'package:teachme/screens/course_details_page.dart';
import 'package:teachme/service/course_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/utils/utils.dart';

class CourseCard extends StatefulWidget {
  final AdvertisementModel course;
  final bool own;
  final VoidCallback? onRefresh;

  CourseCard({required this.course, required this.own, this.onRefresh});

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: GestureDetector(
        onTap: () async {
          await CourseService.setCourse(widget.course.id);
          final result = await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (_, __, ___) => CourseDetailsPage(), // Tu pantalla destino
              transitionsBuilder: (_, animation, __, child) {
                const begin = Offset(1.0, 0.0); // De derecha a izquierda
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
          if (result == true) {
            widget.onRefresh?.call();
          }
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
                    ),
                  ],
                ),
              ),
            ),
            if (currentUser.isTeacher &&
                widget.course.tutorId == currentTeacher.userId &&
                widget.own)
              Positioned(
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () => _showStateOptions(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          widget.course.state.name == 'active'
                              ? Colors.green
                              : Colors.red, // Fondo del banner
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      translate(
                        context,
                        widget.course.state.name,
                      ), // Mensaje del banner
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showStateOptions(BuildContext context) {
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
                'Estado del anuncio',
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
                leading: Icon(Icons.visibility, color: Colors.white),
                title: Text("Activar", style: TextStyle(color: Colors.white)),
                onTap: () async{
                  Navigator.pop(context);
                  setState(() {
                    widget.course.state = AdvertisementState.active;
                  });
                  await CourseService.changeState(widget.course.state.name, widget.course.id);
                  ScaffoldMessageInfo('El estado del anuncio es ahora: Activo', context);
                },
              ),
              Divider(color: const Color.fromARGB(31, 158, 158, 158)),
              ListTile(
                leading: Icon(Icons.visibility_off, color: Colors.white),
                title: Text("Ocultar", style: TextStyle(color: Colors.white)),
                onTap: () async {
                  final bool? confirm = await _confirmDialog(context);
                  if (confirm != true) return;

                  Navigator.pop(context);
                  setState(() {
                    widget.course.state = AdvertisementState.hidden;
                  });
                  await CourseService.changeState(widget.course.state.name, widget.course.id);
                  ScaffoldMessageInfo('El estado del anuncio es ahora: Oculto', context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _confirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Color(0xFF121212),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Column(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: Color(0xFF3B82F6),
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  'Estas seguro que quiere ocultar este anuncio?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Este anuncio no se mostrará a los estudiantes.',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'Puedes revertir esta acción en cualquier momento.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF3B82F6),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(translate(context, "cancel")),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  translate(context, "confirm"),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Widget _showPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text("From  ", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        Text(
          "${widget.course.prices.first.toStringAsFixed(0)} €",
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
      widget.course.title,
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
          widget.course.score.toStringAsFixed(1),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Text(
          "(${widget.course.scoreCount.toInt()})",
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }

  Widget _imageCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        bottomLeft: Radius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(widget.course.photos.first),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
