import 'package:flutter/material.dart';

class TeacherFormProvider extends ChangeNotifier{
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  bool _isLoading = false;
  String description = '';
  String date = '';

  String? descriptionError; // Error del campo email/email
  String? dateError; // Error del campo contraseña

  bool get isLoading => _isLoading;
  

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool isValidForm() {
    print('$description - $date');
    print(formKey.currentState?.validate());
    return formKey.currentState?.validate() ?? false;
  }

  void setDescriptionError(String? error) {
    descriptionError = error;
    notifyListeners();
  }

  void setDateError(String? error) {
    dateError = error;
    notifyListeners();
  }

  void clearErrors() {
    dateError = null;
    descriptionError = null;
    notifyListeners();
  }
}