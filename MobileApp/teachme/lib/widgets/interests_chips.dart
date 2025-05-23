import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:teachme/screens/choose_interests_page.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';

class InterestsChips extends StatefulWidget {
  @override
  State<InterestsChips> createState() => _InterestsChipsState();
}

class _InterestsChipsState extends State<InterestsChips> {
  @override
  Widget build(BuildContext context) {
    // print(currentStudent.interestsIds.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 7),
        _title(context),
        Wrap(
          spacing: 10,
          children:
              currentStudent.interestsNames.map((interest) {
                return Chip(
                  backgroundColor: const Color.fromARGB(255, 65, 65, 65),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: const Color.fromARGB(255, 65, 65, 65),
                    ),
                  ),
                  label: Text(
                    translate(context, interest),
                    style: TextStyle(color: Colors.white),
                  ),
                  deleteIcon: null,
                  onDeleted: null,
                );
              }).toList(),
        ),
      ],
    );
  }

  Row _title(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Interests',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        TextButton(
          onPressed: () async {
            await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => ChooseInterestsPage(editing: true),
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
            setState(() {});
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
            'Edit',
            style: TextStyle(color: Color(0xFF3B82F6), fontSize: 16),
          ),
        ),
      ],
    );
  }
}
