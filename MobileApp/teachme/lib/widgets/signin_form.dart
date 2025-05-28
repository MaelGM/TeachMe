import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teachme/models/models.dart';
import 'package:teachme/providers/register_form_provider.dart';
import 'package:teachme/screens/pages.dart';
import 'package:teachme/service/auth_service.dart';
import 'package:teachme/ui/input_decorations.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/widgets/widgets.dart';

import '../utils/translate.dart';

class SignInForm extends StatefulWidget {
  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  bool hideTextPassword1 = true;
  bool hideTextPassword2 = true;

  @override
  Widget build(BuildContext context) {
    final signForm = Provider.of<SignFormProvider>(context);

    return Form(
      key: signForm.formKey,
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _nameInput(signForm, context),
              SizedBox(height: 22),
              EmailInputSign(signForm: signForm, context: context),
              SizedBox(height: 22),
              _passwordInput(signForm, context, true),
              SizedBox(height: 22),
              _passwordInput(signForm, context, false),
              Expanded(child: Container()),
              _signButton(signForm, context),
              SizedBox(height: 10),
              _divider(),
              SizedBox(height: 10),
              GoogleSignInButton(),
              SizedBox(height: 20),
        
            ],
          ),
        ),
      
    );
  }

  Row _divider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            "Or",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Column _passwordInput(SignFormProvider signForm, BuildContext context, bool first) {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(first ? "${translate(context, "password")} *" : "${translate(context, "repeatPassword")} *", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
              SizedBox(height: 2),
              TextFormField(
                onChanged: (value) {
                  first ? signForm.password = value : signForm.password2 = value;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => _validPassword(context, value, signForm, first),
                autofocus: false,
                obscureText: first ? hideTextPassword1 : hideTextPassword2,
                textCapitalization: TextCapitalization.none,
                style: TextStyle(color: Colors.white),
                decoration: InputDecorations.authInputDecorationBorderFull(
                    hintText: first ? translate(context, "enterPassword") : translate(context, "repeatPasswordPlease"),
                    labelText: translate(context, "password"),
                    suffixIcon: IconButton(
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          first ? 
                          hideTextPassword1 = !hideTextPassword1 
                          : hideTextPassword2 = !hideTextPassword2; // Alternar obscureText
                        });
                      }, 
                      icon: first ? Icon(
                        hideTextPassword1 ? Icons.visibility_off_outlined
                        // ignore: dead_code
                        : Icons.visibility_outlined,
                      ) : 
                      Icon(
                        hideTextPassword2 ? Icons.visibility_off_outlined
                        // ignore: dead_code
                        : Icons.visibility_outlined,
                      ) 
                    )
                ),
              )
            ],
          );
  }

  Column _nameInput(SignFormProvider signForm, BuildContext context) {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${translate(context, "name")} *", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
              SizedBox(height: 2),
              TextFormField(
                onChanged: (value) {
                  signForm.name = value;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => _validName(context, value, signForm),
                autofocus: false,
                textCapitalization: TextCapitalization.none,
                style: TextStyle(color: Colors.white),
                decoration: InputDecorations.authInputDecorationBorderFull(
                    hintText: translate(context, "name"),
                    labelText: translate(context, "name")),
              )
            ],
          );
  }

  Container _signButton(SignFormProvider signForm, BuildContext context) {
    return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: signForm.isLoading ? Colors.grey :Color(0xFF3B82F6),
            ),
            width: double.infinity,
            height: 50,
            child: TextButton(
              onPressed: () => _registerUser(signForm, context),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: signForm.isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(translate(context, "signin"),style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          );
  }
  
  _registerUser(SignFormProvider signForm, BuildContext context) async{
    //return signForm.isLoading ? null : 
    //() async {
      signForm.clearErrors; // Limpia errores previos
      bool isValid = true;

      print('Estoy');

      if (validateForm(signForm) || !signForm.formKey.currentState!.validate()) isValid = false;

      if(isValid) {
        signForm.isLoading = true;
        final authService = AuthService(); // Instancia de AuthService
        if (await authService.emailExists(signForm.email)) {
          signForm.emailError = translate(context, "emailExists");
          signForm.isLoading = false;
        }else {
          creatingUser = UserModel(
            id: '',
            connected: 'no', 
            email: signForm.email, 
            isStudent: false, 
            isTeacher: false, 
            username: signForm.name, 
            profilePicture: ''
          );
          isGoogleSignUp = false;
          creatingUserPassword = signForm.password;
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => SigninFormPage(), 
              transitionsBuilder: (_, animation, __, child) {
                const begin = Offset(1.0, 0.0);
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
        }
      }

      signForm.isLoading = false;
    
  }

  _validPassword(BuildContext context, String? password, SignFormProvider signForm, bool first) {
    if (password == null || password.isEmpty) return translate(context, "enterPasswordPlease");
    if(signForm.password.length < 8) return translate(context, "minimalLengthPassword");
    return first ? signForm.passwordError : signForm.password2Error; // Mostrar error dinámico si existe
  }

  _validName(BuildContext context, String? username, SignFormProvider signForm) {
    if (username == null || username.isEmpty) return translate(context, "enterNamePlease");
    return signForm.nameError; // Mostrar error dinámico si existe
  }

  
  bool validateForm(SignFormProvider signForm) {
    bool hasError = false;
    if (signForm.password != signForm.password2) {
      signForm.password2Error = translate(context, "differentsPasswords");
    
      print('Passwords diferentes');
      signForm.formKey.currentState!.validate(); // Fuerza validación
      hasError = true;
    }else signForm.password2Error = null;

    String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[09]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$'; 
    RegExp regExp  = new RegExp(pattern);
    if(!regExp.hasMatch(signForm.email)) {
      signForm.emailError = translate(context, "enterCorrectEmailPlease");
      signForm.formKey.currentState!.validate(); // Fuerza validación
      hasError = true;
    }else signForm.emailError = null;

    return hasError;
  }
}
