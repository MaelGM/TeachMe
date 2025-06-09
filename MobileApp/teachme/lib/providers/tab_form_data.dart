import 'package:flutter/material.dart';

class TabFormData {
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController titleController = TextEditingController(); // nuevo

  List<TextEditingController> keyControllers = [];
  List<TextEditingController> valueControllers = [];

  TabFormData() {
    keyControllers.add(TextEditingController());
    valueControllers.add(TextEditingController());
  }

  void dispose() {
    priceController.dispose();
    descriptionController.dispose();
    titleController.dispose(); // nuevo
    for (var c in keyControllers) c.dispose();
    for (var c in valueControllers) c.dispose();
  }

  Map<String, String> getParametersMap() {
    final Map<String, String> map = {};

    for (int i = 0; i < keyControllers.length; i++) {
      final key = keyControllers[i].text.trim();
      final value = valueControllers[i].text.trim();
      if (key.isNotEmpty && value.isNotEmpty) {
        map[key] = value;
      }
    }

    final desc = descriptionController.text.trim();
    if (desc.isNotEmpty) {
      map['description'] = desc;
    }

    final title = titleController.text.trim();
    if (title.isNotEmpty) {
      map['title'] = title; // agregamos el título en parámetros
    }

    return map;
  }
}
