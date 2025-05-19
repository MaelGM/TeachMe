import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:teachme/screens/config_menu.dart';
import 'package:teachme/screens/pages.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/widgets/interests_chips.dart';

class MyInterests extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: 16, top: 16, right: 16),
          child: Text(
            'My Interests',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        SizedBox(height: 10),
        _subjectsButton(context),
        _favButton(context),
        Container(
          padding: EdgeInsets.only(left: 16, top: 16, right: 16),
          child: Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        SizedBox(height: 10),
        _configButton(context),
        _accountButton(context),
        if(!currentUser.isTeacher) 
          _becomeSellerButton(context)
      ],
    );
  }

  GestureDetector _subjectsButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ChooseInterestsPage(editing: true),
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
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF151515),
          border: Border.symmetric(
            horizontal: BorderSide(width: 1.1, color: Colors.white),
          ),
        ),
        child: _buttonRow('Intereses', Icons.interests),
      ),
    );
  }

  GestureDetector _becomeSellerButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, TeacherForm.routeName);
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF151515),
          border: Border.symmetric(
            horizontal: BorderSide(width: 1.1, color: Colors.white),
          ),
        ),
        child: _buttonRow('Become a seller', Icons.storefront),
      ),
    );
  }

  GestureDetector _accountButton(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF151515),
          border: Border.symmetric(
            horizontal: BorderSide(width: 1.1, color: Colors.white),
          ),
        ),
        child: _buttonRow('My account', Icons.person),
      ),
    );
  }

  GestureDetector _configButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ConfigMenuPage(), // Tu pantalla destino
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
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF151515),
          border: Border.symmetric(
            horizontal: BorderSide(width: 1.1, color: Colors.white),
          ),
        ),
        child: _buttonRow('Settings', Icons.settings),
      ),
    );
  }

  Row _buttonRow(String title, IconData icon) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        ],
      );
  }

  GestureDetector _favButton(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF151515),
          border: Border(
            bottom: BorderSide(width: 1.1, color: Colors.white),
          ),
        ),
        child: _buttonRow('Favoritos', Icons.favorite_outline)
      ),
    );
  }
}
