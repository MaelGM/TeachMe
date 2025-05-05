import 'package:flutter/material.dart';

class SignFormProvider extends ChangeNotifier{
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  bool _isLoading = false;
  String email = '';
  String name = '';
  String password = '';
  String password2 = '';

  String? emailError; // Error del campo email/email
  String? passwordError; // Error del campo contraseña
  String? nameError;
  String? password2Error;

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
  
  void setPassword2Error(String? error) {
    password2Error = error;
    notifyListeners();
  }

  void setNameError(String? error) {
    nameError = error;
    notifyListeners();
  }

  void clearErrors() {
    emailError = null;
    passwordError = null;
    password2Error = null;
    nameError = null;
    notifyListeners();
  }
}