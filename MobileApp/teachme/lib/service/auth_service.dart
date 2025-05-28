import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:teachme/models/user_model.dart' as user;
import 'package:teachme/providers/providers.dart';
import 'package:teachme/screens/pages.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/utils/user_preferences.dart';

class AuthService extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<bool> initSession() async {
    final savedUser = await UserPreferences.instance.getUser();
    if (savedUser != null) {
      currentUser = savedUser;
      return true;
    }
    return false;
  }

<<<<<<< Updated upstream
=======
  Future<void> initUser() async {
    if (currentUser.isStudent) await checkAndSetStudent(currentUser.id);
    if (currentUser.isTeacher) await checkAndSetTeacher(currentUser.id);

    await updateUserConnectionStatus('yes');
  }

  Future<void> checkAndSetStudent(String userUid) async {
    if (await UserPreferences.instance.existStudent()) {
      print('STUDENT EXIST');
      currentStudent = (await UserPreferences.instance.getStudent())!;
    } else {
      print('CREATING STUDENT');
      await saveStudent(userUid);
    }
  }

  Future<void> checkAndSetTeacher(String userUid) async {
    print("SAVING TEACHER");
    if (await UserPreferences.instance.existTeacher()) {
      print("TEACHER EXISTS");
      currentTeacher = (await UserPreferences.instance.getTeacher())!;
    } else {
      print("NO TEACHER");
      await saveTeacher(userUid);
    }
    print("FINAL SAVING");
  }

>>>>>>> Stashed changes
  Future<bool> emailExists(String email) async {
    // ignore: deprecated_member_use
    final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    return methods.isNotEmpty; // Si hay métodos, el email ya está registrado
  }


  Future<void> register(BuildContext context) async {
    try {
      String uid;

      if (!isGoogleSignUp) {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: creatingUser.email.trim(),
          password: creatingUserPassword.trim(),
        );
        uid = userCredential.user!.uid;

        await UserPreferences.instance.saveRefreshToken(
          userCredential.user?.refreshToken ?? '',
        );
      } else {
        uid = FirebaseAuth.instance.currentUser!.uid;
      }

      creatingUser.id = uid;
      await _firestore.collection('users').doc(uid).set(creatingUser.toMap());
      currentUser = creatingUser;
      await UserPreferences.instance.saveUser(currentUser);

      if (creatingUser.isStudent) _registerStudent();
      if (creatingUser.isTeacher) _registerTeacher();

<<<<<<< Updated upstream
      Navigator.pushNamedAndRemoveUntil(context, HomePage.routeName, (Route<dynamic> route) => false);
    } on FirebaseAuthException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate(context, "randomError"))),
      );
=======
      Navigator.pushNamedAndRemoveUntil(
        context,
        NavBarPage.routeName,
        (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (ex){
      ScaffoldMessageError(ex.message ?? translate(context, "randomError"), context);
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate(context, "unexpectedError"))),
      );
    }
  }

  Future<void> _registerStudent() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw FirebaseAuthException(code: 'no-user', message: 'Usuario no autenticado');
      }

      creatingStudent.userId = currentUser.uid; // Aquí se asigna el ID del user

      await _firestore.collection('students').doc(creatingStudent.userId).set({
        'userId': creatingStudent.userId,
        'interestsIds': creatingStudent.interestsIds,
        'interestsNames': creatingStudent.interestsNames,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _registerTeacher() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw FirebaseAuthException(code: 'no-user', message: 'Usuario no autenticado');
      }
  
      currentTeacher.userId = currentUser.uid; // Aquí se asigna el ID del user
  
      await _firestore.collection('teachers').doc(currentTeacher.userId).set({
        'userId': currentTeacher.userId,
        'aboutMe': currentTeacher.aboutMe,
        'birthDate': currentTeacher.birthDate,
        'rating': 0,
      });
    } catch (e) {
      rethrow;
    }
  }


  Future<void> login(LoginFormProvider loginForm, BuildContext context) async {
    try {
      // Limpiar errores y activar loading
      loginForm.clearErrors();
      loginForm.isLoading = true;

      // Iniciar sesión con Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: loginForm.email.trim(),
        password: loginForm.password.trim(),
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(translate(context, "unexpectedError"))),
        );
        loginForm.isLoading = false;
        return;
      }

      final refreshToken = firebaseUser.refreshToken;
      if (refreshToken != null) {
        await UserPreferences.instance.saveRefreshToken(refreshToken);
      }

      final uid = firebaseUser.uid;
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final userModel = user.UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
        await UserPreferences.instance.saveUser(userModel);
        currentUser = userModel;

        loginForm.isLoading = false;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        loginForm.emailError = translate(context, "invalidEmailOrPassword");
        loginForm.passwordError = translate(context, "invalidEmailOrPassword");
        loginForm.formKey.currentState?.validate();
        loginForm.isLoading = false;
      }

    } on FirebaseAuthException catch (e) {
      print(e.code);
      switch (e.code) {
        case 'invalid-email':
          loginForm.emailError = translate(context, "incorrectEmail");
          break;
        case 'user-disabled':
          loginForm.emailError = translate(context, "dishabledUser");
          break;
        case 'user-not-found':
          loginForm.emailError = translate(context, "userNotFound");
          break;
        case 'wrong-password':
          loginForm.emailError = translate(context, "incorrectEmailOrPassword");;
          loginForm.passwordError = translate(context, "incorrectEmailOrPassword");;
          break;
        case 'too-many-requests':
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(translate(context, "maxTries"))),
          );
          break;
        case 'operation-not-allowed':
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(translate(context, "loginDishabled"))),
          );
          break;
        case 'network-request-failed':
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(translate(context, "redError"))),
          );
          break;
        case 'invalid-credential':
          loginForm.emailError = translate(context, "incorrectEmailOrPassword");
          loginForm.passwordError = translate(context, "incorrectEmailOrPassword");
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(translate(context, "loginError"))),
          );
      }

      loginForm.formKey.currentState?.validate(); // Forzar revalidación de errores
      loginForm.isLoading = false;
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate(context, "unexpectedError"))),
      );
      loginForm.isLoading = false;
    }
  }
  
  

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    
    await UserPreferences.instance.deleteUser();
    await UserPreferences.instance.deleteRefreshToken();
    Navigator.pushReplacementNamed(context, AccessPage.routeName);
  }
}