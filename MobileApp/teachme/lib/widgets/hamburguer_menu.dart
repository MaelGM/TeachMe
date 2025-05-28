import 'package:flutter/material.dart';
import 'package:teachme/screens/pages.dart';

class HamburguerMenu extends StatelessWidget {
  final VoidCallback? onConfigUpdated;

  const HamburguerMenu({super.key, this.onConfigUpdated});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.menu, color: Colors.white),
      onPressed: () async {
        final result = await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ConfigMenuPage(),
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

        if (result == true && onConfigUpdated != null) {
          onConfigUpdated!(); // Notifica a la pantalla que hubo un cambio
        }
      },
    );
  }
}
