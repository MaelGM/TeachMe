import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teachme/utils/utils.dart';

class WaitingEmailVerificationPage extends StatefulWidget {
  final String newEmail;

  const WaitingEmailVerificationPage({required this.newEmail});

  @override
  _WaitingEmailVerificationPageState createState() => _WaitingEmailVerificationPageState();
}

class _WaitingEmailVerificationPageState extends State<WaitingEmailVerificationPage> {
  bool _checking = false;
  String? _error;

  Future<void> _checkEmailVerified() async {
    setState(() {
      _checking = true;
      _error = null;
    });

    try {
      await FirebaseAuth.instance.currentUser!.reload();
      final user = FirebaseAuth.instance.currentUser!;

      if (user.email == widget.newEmail) {
        Navigator.pop(context, true); // Puedes usar esto para volver a la pantalla anterior con éxito
      } else {
        setState(() {
          _error = "Tu email aún no ha sido verificado. Revisa tu bandeja de entrada.";
          _checking = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error verificando el estado. Intenta nuevamente.";
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text("Verifica tu correo"),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mark_email_read, color: Color(0xFF3B82F6), size: 64),
              SizedBox(height: 20),
              Text(
                "Te enviamos un enlace de verificación a:",
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                widget.newEmail,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              _checking
                  ? CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _checkEmailVerified,
                      icon: Icon(Icons.refresh),
                      label: Text("He verificado mi correo"),
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF3B82F6)),
                    ),
              if (_error != null) ...[
                SizedBox(height: 16),
                Text(_error!, style: TextStyle(color: Colors.redAccent)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
