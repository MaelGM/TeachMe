import 'package:flutter/material.dart';
import 'package:teachme/providers/providers.dart';
import 'package:teachme/ui/input_decorations.dart';
import 'package:teachme/utils/translate.dart';

class EmailInputLogin extends StatelessWidget {
  const EmailInputLogin({
    super.key,
    required this.loginForm,
    required this.context,
  });

  final LoginFormProvider loginForm;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${translate(context, "email")} *", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
              SizedBox(height: 2),
              TextFormField(
                onChanged: (value) {
                  loginForm.email = value;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => _validEmail(context, value, loginForm),
                autofocus: false,
                textCapitalization: TextCapitalization.none,
                style: TextStyle(color: Colors.white),
                decoration: InputDecorations.authInputDecorationBorderFull(
                    hintText: translate(context, "email"),
                    labelText: translate(context, "email")),
              ),
            ],
          );
  }
  _validEmail(BuildContext context, String? email, LoginFormProvider loginForm) {
    if (email == null || email.isEmpty) return translate(context, "enterEmailPlease");
    return loginForm.emailError; // Mostrar error dinámico si existe
  }
}


class EmailInputSign extends StatelessWidget {
  const EmailInputSign({
    super.key,
    required this.signForm,
    required this.context,
  });

  final SignFormProvider signForm;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${translate(context, "email")} *", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
              SizedBox(height: 2),
              TextFormField(
                onChanged: (value) {
                  signForm.email = value;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => _validEmail(context, value, signForm),
                autofocus: false,
                textCapitalization: TextCapitalization.none,
                style: TextStyle(color: Colors.white),
                decoration: InputDecorations.authInputDecorationBorderFull(
                    hintText: translate(context, "email"),
                    labelText: translate(context, "email")),
              ),
            ],
          );
  }

  _validEmail(BuildContext context, String? email, SignFormProvider signForm) {
    if (email == null || email.isEmpty) return translate(context, "enterEmailPlease");
    return signForm.emailError; // Mostrar error dinámico si existe
  }
}