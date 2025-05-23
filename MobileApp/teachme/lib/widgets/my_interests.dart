import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:teachme/screens/config_menu.dart';
import 'package:teachme/screens/edit_account_page.dart';
import 'package:teachme/screens/favorite_courses_page.dart';
import 'package:teachme/screens/pages.dart';
import 'package:teachme/service/auth_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/widgets/interests_chips.dart';

class MyInterests extends StatefulWidget {
  final VoidCallback? onBecameTeacher;

  const MyInterests({super.key, this.onBecameTeacher});

  @override
  State<MyInterests> createState() => _MyInterestsState();
}

class _MyInterestsState extends State<MyInterests> {
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
        if (!currentUser.isTeacher) _becomeSellerButton(context),
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
      onTap: () async {
        final bool? confirm = await _alertDialog(context);

        if (confirm != true) return;

        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TeacherForm(editing: true)),
        );

        if (result == true) {
          await _reloadUserFromBackend();
          if (widget.onBecameTeacher != null) widget.onBecameTeacher!();
        }
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

  Future<bool?> _alertDialog(BuildContext context) {
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
                  Icons.warning_amber_rounded,
                  color: Color(0xFFF59E0B), // Color de advertencia (amarillo)
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  "Confirmar acción",
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
                  "¿Estás seguro de que deseas convertirte en un profesor?",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  "Esta acción no es reversible.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(
                      0xFF3B82F6,
                    ), // Color rojo claro para advertencia
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
                child: Text("Cancelar"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Confirmar", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  GestureDetector _accountButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (_, __, ___) => EditAccountPage(), // Tu pantalla destino
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
      },
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
            pageBuilder:
                (_, __, ___) => ConfigMenuPage(), // Tu pantalla destino
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
            Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
      ],
    );
  }

  GestureDetector _favButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (_, __, ___) => FavoriteCoursesPage(), // Tu pantalla destino
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
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF151515),
          border: Border(bottom: BorderSide(width: 1.1, color: Colors.white)),
        ),
        child: _buttonRow('Favoritos', Icons.favorite_outline),
      ),
    );
  }

  Future<void> _reloadUserFromBackend() async {
    final newUser = await AuthService.getUserById(
      currentUser.id,
    ); // o el método que uses
    setState(() {
      currentUser = newUser;
    });
  }
}
