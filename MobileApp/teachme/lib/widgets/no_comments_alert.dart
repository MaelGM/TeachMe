import 'package:flutter/material.dart';
import 'package:teachme/service/course_service.dart';
import 'package:teachme/utils/config.dart';

class NoCommentsAlert extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                  CourseService.course.tutorId == currentUser.id
                      ? 'Cuando recibas comentarios de estudiantes,\naparecerán aquí.'
                      : 'Nadie ha dejado un comentario todavía.\n¡Sé el primero en compartir tu opinión!',
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
}