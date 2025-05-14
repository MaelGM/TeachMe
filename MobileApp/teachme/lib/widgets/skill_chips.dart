import 'package:flutter/material.dart';
import 'package:teachme/models/models.dart';
import 'package:teachme/service/teacher_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';

class SkillChips extends StatefulWidget {
  final bool editable;
  const SkillChips({super.key, required this.editable});

  @override
  State<SkillChips> createState() => _SkillChipsState();
}

class _SkillChipsState extends State<SkillChips> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children:
          TeacherService.teacher.skills.map((skill) {
            return Chip(
              backgroundColor: const Color.fromARGB(255, 65, 65, 65),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Cambia el valor como desees
                side: BorderSide(color: const Color.fromARGB(255, 65, 65, 65),), // Opcional: borde del chip
              ),
              label: Text(translate(context, skill), style: TextStyle(color: Colors.white),),
              deleteIcon: widget.editable ? Icon(Icons.close, color: Colors.white,) : null,
              onDeleted: widget.editable ? () {
                setState(() {
                  currentTeacher.skills.remove(skill);
                });
              } : null,
            );
          }).toList(),
    );
  }
}
