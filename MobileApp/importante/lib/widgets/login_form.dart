
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teachme/providers/providers.dart';
import 'package:teachme/ui/input_decorations.dart';
import 'package:teachme/widgets/widgets.dart';

class LoginForm extends StatefulWidget{
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
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
            emailInput(loginForm, context),
            SizedBox(height: 31),
            passwordInput(loginForm, context),
            SizedBox(height: 31),
            loginButton(),
            SizedBox(height: 10),
            _divider(),
            SizedBox(height: 10),
            GoogleSignInButton(),
            
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

  Column emailInput(LoginFormProvider loginForm, BuildContext context) {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Email *", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
              SizedBox(height: 2),
              TextFormField(
                onChanged: (value) {
                  loginForm.email = value;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value)  {
                  if (value == null || value.isEmpty) {
                    return "Por favor introduzca el email";
                  }
                  return loginForm.emailError;
                },
                autofocus: false,
                textCapitalization: TextCapitalization.none,
                style: TextStyle(color: Colors.white),
                decoration: InputDecorations.authInputDecorationBorderFull(
                    hintText: 'Email',
                    labelText: 'Email'),
              ),
            ],
          );
  }

  Column passwordInput(LoginFormProvider loginForm, BuildContext context) {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Contraseña *", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
              SizedBox(height: 2),
              TextFormField(
                onChanged: (value) {
                  loginForm.email = value;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor introduzca la contraseña";
                  }
                  return loginForm.passwordError;
                },
                autofocus: false,
                textCapitalization: TextCapitalization.none,
                style: TextStyle(color: Colors.white),
                decoration: InputDecorations.authInputDecorationBorderFull(
                    hintText: 'Introduce la contraseña',
                    labelText: 'Contraseña'),
              ),
              SizedBox(height: 8),
              _forgotPassword()
            ],
          );
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
              child: Text("Forgot Password?", style: TextStyle(fontSize: 12.5)),
            );
  }

  Container loginButton() {
    return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xFF3B82F6),
            ),
            width: double.infinity,
            height: 50,
            child: TextButton(
              onPressed: () => {print("Button")},
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: Text('Iniciar sesión',style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          );
  }

  String? _validPassword(BuildContext context, String? value, LoginFormProvider loginForm) {
    if (value == null || value.isEmpty) {
      loginForm.setEmailError("Por favor introduzca el email");
    }
    return loginForm.emailError;
  }
}