import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:teachme/models/models.dart';
import 'package:teachme/screens/pages.dart';
import 'package:teachme/service/auth_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/utils/user_preferences.dart';
import 'package:teachme/utils/utils.dart';

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
      // Se hace el login con google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // Cancelado
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

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
      ScaffoldMessageError(translate(context, "googleError"), context);
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
      connected: 'no', 
      email: googleUser.email, 
      isStudent: false, 
      isTeacher: false, 
      username: googleUser.displayName ?? googleUser.email, 
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
    final userModel = UserModel.fromDocument(userDoc);

    await UserPreferences.instance.saveUser(userModel);
    currentUser = userModel;
    AuthService authService = AuthService();

    await authService.initUser();
  
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => NavBarPage(),
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
