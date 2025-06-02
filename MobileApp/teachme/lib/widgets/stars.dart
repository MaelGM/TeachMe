import 'package:flutter/material.dart';

class Stars extends StatelessWidget {
  final double rating;
  const Stars({
    super.key,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, color: Color(0xFF3B82F6));
        } else if (rating - index >= 0.5) {
          // Estrella a la mitad
          return Icon(Icons.star_half, color: Color(0xFF3B82F6));
        } else {
          // Estrellas vacías
          return Icon(Icons.star_border, color: Color(0xFF3B82F6));
        }
      }),
    );
  }
}