import 'package:flutter/material.dart';
import 'package:teachme/screens/pages.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';

class SigninFormPage extends StatefulWidget{
  static const routeName = 'signForm';

  @override
  State<SigninFormPage> createState() => _SigninFormPageState();
}

class _SigninFormPageState extends State<SigninFormPage> {
  bool isStudent = false;
  bool isTeacher = false;

  @override
  void initState() {
    super.initState();
    isStudent = false;
    isTeacher = false;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        title: Text(translate(context, "whatAreYou"), style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),),
        centerTitle: true,
        toolbarHeight: 70,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        
          children: [
            Container(),
            _buttonsRole(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _backButton(context),
              
                _nextButton(context),
              ],
            )
          ],
        ),
      ),
    );
  }

  ElevatedButton _backButton(BuildContext context) {
    return ElevatedButton(
                onPressed: () => Navigator.pop(context),
              
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  minimumSize: Size(100, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Border radius leve
                  ),
                  
                ),
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    Text(translate(context, "back"),style: TextStyle(fontSize: 18,color: Colors.white,),),
                    SizedBox(width: 8),
                  ],
                ),
              );
  }

  ElevatedButton _nextButton(BuildContext context) {
    return ElevatedButton(
                onPressed: () => !isStudent && !isTeacher ? {} : {
                  creatingUser.isStudent = isStudent,
                  creatingUser.isTeacher = isTeacher,
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => isStudent ? ChooseInterestsPage(editing: false,) : TeacherForm(editing: false,), 
                      transitionsBuilder: (_, animation, __, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;
              
                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  )
                },
              
                style: ElevatedButton.styleFrom(
                  backgroundColor: !isStudent && !isTeacher ? Colors.grey : Color(0xFF3B82F6),
                  minimumSize: Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Border radius leve
                  ),
                  
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      translate(context, "next"),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ],
                ),
              );
  }

  Row _buttonsRole() {
    return Row(
            spacing: 20,
            children: [
              _rolButton(
                translate(context, "student"),
                isStudent,
                () => setState(() => isStudent = !isStudent),
                Icons.school
              ),
              _rolButton(
                translate(context, "teacher"),
                isTeacher,
                () => setState(() => isTeacher = !isTeacher),
                Icons.person
              )
            ],
          );
  }

  Expanded _rolButton(String rol, bool isSelected, VoidCallback onTap, IconData icon) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double size = constraints.maxWidth;

          return GestureDetector(
            onTap: onTap,
            child: Stack(
              children: [
                  Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  margin: EdgeInsets.symmetric(vertical: 10),
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: Color(0xFF151515),
                    border: Border.all(width: 2, color: isSelected ? Color(0xFF3B82F6) : Color(0xFF151515)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(icon, size: 55, color: Colors.white,),
                      Center(
                        child: Text(
                          rol,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      )
                    ],
                  ),
                ),
                if (isSelected)
                  _checkIcon(),
              ]
            ),
          );
        }
      )
    );
  }

  Positioned _checkIcon() {
    return Positioned(
              top: 0,
              right: 0,
              child: CircleAvatar(
                radius: 17,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.check,
                  size: 18,
                  color: Color(0xFF3B82F6),
                ),
              ),
            );
  }

  
}