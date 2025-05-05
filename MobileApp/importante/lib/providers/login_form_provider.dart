import 'package:flutter/material.dart';

class LoginFormProvider extends ChangeNotifier{
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  bool _isLoading = false;
  String email = '';
  String password = '';

  String? emailError; // Error del campo email/email
  String? passwordError; // Error del campo contraseña

  bool get isLoading => _isLoading;
  

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool isValidForm() {
    print('$email - $password');
    print(formKey.currentState?.validate());
    return formKey.currentState?.validate() ?? false;
  }

  void setEmailError(String? error) {
    emailError = error;
    notifyListeners();
  }

  void setPasswordError(String? error) {
    passwordError = error;
    notifyListeners();
  }

  void clearErrors() {
    emailError = null;
    passwordError = null;
    notifyListeners();
  }
}