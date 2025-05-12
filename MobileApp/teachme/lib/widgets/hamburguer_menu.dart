
import 'package:flutter/material.dart';
import 'package:teachme/screens/pages.dart';

class HamburguerMenu extends StatelessWidget {
  const HamburguerMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.menu, color: Colors.white,), // El ícono de las tres líneas
      onPressed: () {
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
    );
  }
}
