import 'package:flutter/material.dart';

class InputDecorations {
  static InputDecoration authInputDecoration(
      {String? hintText,
      required String? labelText,
      IconData? prefixIcon,
      IconData? suffixIcon}) {
    return InputDecoration(
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(66, 191, 100, 1))
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(66, 191, 100, 1), width: 2)
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Color.fromRGBO(66, 191, 100, 1),) : null,
      );
  }

  static InputDecoration authInputDecorationBorderFull(
      {String? hintText,
      required String? labelText,
      IconData? prefixIcon,
      IconData? suffixIcon}) {
    return InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey)
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.white, width: 2)
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Color.fromARGB(255, 190, 90, 84))
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Color.fromARGB(255, 214, 82, 75), width: 2)
        ),
        fillColor: Color.fromRGBO(21, 21, 21, 1),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Color(0xFF3B82F6),) : null,
      );
  }

  static BoxDecoration containerDecoration = const BoxDecoration(
    border: Border(
      bottom: BorderSide(color: Color.fromRGBO(66, 191, 100, 1), width: 2),
    ),
  );
}
