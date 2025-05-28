import 'package:flutter/material.dart';

class EditFormProvider extends ChangeNotifier{
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  bool _isLoading = false;
  String email = '';
  String name = '';

  String? emailError; // Error del campo email/email
  String? nameError;

  bool get isLoading => _isLoading;
  

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool isValidForm() {
    print('$email - $name');
    print(formKey.currentState?.validate());
    return formKey.currentState?.validate() ?? false;
  }

  void setEmailError(String? error) {
    emailError = error;
    notifyListeners();
  }

  void setNameError(String? error) {
    nameError = error;
    notifyListeners();
  }

  void clearErrors() {
    emailError = null;
    nameError = null;
    notifyListeners();
  }
}