import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:teachme/models/models.dart';
import 'package:teachme/screens/pages.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/utils/user_preferences.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      print("VAMOS A INICIAL EL LOGIN CON GOOGLE");
      // Se hace el login con google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // Cancelado
      }

      print("USUARIO DE GOOGLE NO ES NULL");

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("CREDENTIAL OBTENIDO");

      // Se obtienen los datos del inicio de sesión
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      print(userCredential.toString());
      
      if (user == null) return;
      
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      
      if (!mounted) return;
      if (!userDoc.exists) {
        print("FIRST LOGIN WITH GOOGLE");
        _firstRegister(googleUser);
      } else {
        print("NOT FIRST LOGIN WITH GOOGLE");
        // 1. Obtener los datos del usuario
        _loginWithGoogle(userDoc);
      }

    } catch (e) {
      print("ERROR: "+e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translate(context, "googleError")),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const CircularProgressIndicator()
        : ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 2,
            ),
            icon: Image.asset('assets/google_logo.png', height: 24),
            label: Text(translate(context, "googleButton"), style: TextStyle(fontSize: 20),),
            onPressed: _handleGoogleSignIn,
          );
  }
  
  void _firstRegister(GoogleSignInAccount googleUser) {
    print("REGISTRANDO CON GOOGLE POR PRIMERA VEZ");

    creatingUser = UserModel(
      id: '',
      connected: false, 
      email: googleUser.email, 
      isStudent: false, 
      isTeacher: false, 
      name: googleUser.displayName ?? googleUser.email, 
      profilePicture: googleUser.photoUrl ?? ''
    );

    isGoogleSignUp = true;
    print("CREATING USER INICIALIZADO");
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
  
  Future<void> _loginWithGoogle(DocumentSnapshot<Map<String, dynamic>> userDoc) async {
    final userModel = UserModel.fromJson(userDoc.data()!);

    await UserPreferences.instance.saveUser(userModel);
    currentUser = userModel;
  
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => HomePage(),
        transitionsBuilder: (_, animation, __, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
      (route) => false,
    );
  }
}
