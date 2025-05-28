
import 'package:flutter/material.dart';

class InfoListTile extends StatelessWidget {
  final String subtitle;
  final IconData icon;
  final String title;

  const InfoListTile({
    super.key,
    required this.title,
    required this.icon,
    required this.subtitle
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 28),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.grey[400], // Gris claro, más oculto
          fontSize: 13,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white, // Destacado
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 0),
      dense: true,
    );
  }
}