import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teachme/providers/providers.dart';
import 'package:teachme/service/auth_service.dart';
import 'package:teachme/ui/input_decorations.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/widgets/widgets.dart';

class LoginForm extends StatefulWidget{
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool hideTextPassword = true;

  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);

    return Form(
      key: loginForm.formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            EmailInputLogin(loginForm: loginForm, context: context),
            SizedBox(height: 31),
            passwordInput(loginForm, context),
            SizedBox(height: 31),
            Expanded(child: Container()),
            loginButton(loginForm, context),
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

  Column passwordInput(LoginFormProvider loginForm, BuildContext context) {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${translate(context, "password")} *", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
              SizedBox(height: 2),
              TextFormField(
                onChanged: (value) {
                  loginForm.password = value;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => _validPassword(context, value, loginForm),
                autofocus: false,
                obscureText: hideTextPassword,
                textCapitalization: TextCapitalization.none,
                style: TextStyle(color: Colors.white),
                decoration: InputDecorations.authInputDecorationBorderFull(
                    hintText: translate(context, "enterPassword"),
                    labelText: translate(context, "password"),
                    suffixIcon: IconButton(
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          hideTextPassword = !hideTextPassword;
                        });
                      }, 
                      icon: Icon(
                        hideTextPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      )
                    )
                  ),
              ),
              SizedBox(height: 8),
              _forgotPassword()
            ],
          );
  }

  _validPassword(BuildContext context, String? password, LoginFormProvider loginForm) {
    if (password == null || password.isEmpty) return translate(context, "enterPasswordPlease");
    return loginForm.passwordError; // Mostrar error dinámico si existe
  }

  TextButton _forgotPassword() {
    return TextButton(
              onPressed: () {
                //TODO: Navigator.push(context, MaterialPageRoute(builder: (context) => RecoverAccount()));
                print("Recover");
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: const Color.fromARGB(255, 224, 109, 101),
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact, 
              ),
              child: Text(translate(context, "forgotPassword"), style: TextStyle(fontSize: 12.5)),
            );
  }

  Container loginButton(LoginFormProvider loginForm, BuildContext context) {
    return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xFF3B82F6),
            ),
            width: double.infinity,
            height: 50,
            child: TextButton(
              onPressed: () => _loginUser(loginForm, context),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: Text(translate(context, "login"),style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          );
  }
  
  _loginUser(LoginFormProvider loginForm, BuildContext context) async {
      loginForm.clearErrors();
      bool isValid = true;
      print('Comprobando');

      if(!loginForm.formKey.currentState!.validate()) isValid = false;

      if(isValid) {
        loginForm.isLoading = true;
        final authService = AuthService(); 
        authService.login(loginForm, context);
      }

      loginForm.isLoading = false;
    
  }
}

