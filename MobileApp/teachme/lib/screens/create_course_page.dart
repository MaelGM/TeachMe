import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateCoursePage extends StatefulWidget{
  final String teacherId;

  const CreateCoursePage({super.key, required this.teacherId});
  @override
  State<CreateCoursePage> createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear Comentario')),
    );
  }
}