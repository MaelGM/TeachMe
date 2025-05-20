import 'package:flutter/material.dart';
import 'package:teachme/service/auth_service.dart';
import 'package:teachme/ui/input_decorations.dart';
import 'package:teachme/utils/translate.dart';

class ForgotPasswordPage extends StatefulWidget {
  static const routeName = 'forgotPassword';

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _message;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final email = _emailController.text.trim();

    try {
      await AuthService().sendPasswordResetEmail(email);
      setState(() {
        _message = 'Te hemos enviado un enlace para restablecer tu contraseña.';
      });
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('¿Olvidaste tu contraseña?', style: TextStyle(fontSize: 22),), centerTitle: true,),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              _emailInput(),
              const SizedBox(height: 24),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _resetPasswordButton(),
              if (_message != null) ...[
                const SizedBox(height: 24),
                Text(_message!, style: TextStyle(color: Colors.white70)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  SizedBox _resetPasswordButton() {
    return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3B82F6),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Enviar enlace', style: TextStyle(color: Colors.white, fontSize: 16),),
                  ),
                );
  }

  TextFormField _emailInput() {
    return TextFormField(
      controller: _emailController,
      style: TextStyle(color: Colors.white),
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecorations.authInputDecorationBorderFull(
        hintText: translate(context, "email"),
        labelText: translate(context, "email"),
      ),
      validator: (value) {
        if (value == null || value.isEmpty || !value.contains('@')) {
          return 'Ingresa un correo válido';
        }
        return null;
      },
    );
  }
}
