import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:teachme/models/student_model.dart';
import 'package:teachme/models/teacher_model.dart';
import 'package:teachme/models/user_model.dart';
import 'package:teachme/providers/providers.dart';
import 'package:teachme/screens/pages.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/utils/user_preferences.dart';
import 'package:teachme/utils/utils.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> initSession() async {
    final savedUser = await UserPreferences.instance.getUser();

    if (savedUser != null) {
      currentUser = savedUser;

      if (currentUser.isStudent) await checkAndSetStudent(savedUser.id);
      if (currentUser.isTeacher) await checkAndSetTeacher(savedUser.id);

      await updateUserConnectionStatus('yes');
      return true;
    }
    return false;
  }

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

  Future<bool> emailExists(String email) async {
    // ignore: deprecated_member_use
    final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(
      email,
    );
    return methods.isNotEmpty; // Si hay métodos, el email ya está registrado
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('No se pudo enviar el correo. Verifica el email.');
    }
  }

  static Future<UserModel> getUserById(String id) async {
    try {

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(id).get();

      if (!doc.exists) {
        throw Exception('User not found');
      }

      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  Future<void> register(BuildContext context) async {
    try {
      print("REGISTRANDO");
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

      if (creatingUser.isStudent) registerStudent();
      if (creatingUser.isTeacher) registerTeacher();
      await updateUserConnectionStatus('yes');

      Navigator.pushNamedAndRemoveUntil(context, HomePage.routeName, (Route<dynamic> route) => false);
    } on FirebaseAuthException catch (ex){
      ScaffoldMessageError(ex.message ?? translate(context, "randomError"), context);
    } catch (e) {
      print(e.toString());
      ScaffoldMessageError(translate(context, "unexpectedError"), context);
    }
  }

  Future<void> registerStudent() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'Usuario no autenticado',
        );
      }

      currentStudent.userId = currentUser.uid; // Aquí se asigna el ID del user

      await _firestore.collection('students').doc(currentStudent.userId).set({
        'userId': currentStudent.userId,
        'interestsIds': currentStudent.interestsIds,
        'interestsNames': currentStudent.interestsNames,
        'savedAdvertisements': currentStudent.savedAdvertisements
      });
      await UserPreferences.instance.saveStudent(currentStudent);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registerTeacher() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'Usuario no autenticado',
        );
      }

      currentTeacher.userId = currentUser.uid; // Aquí se asigna el ID del user

      await _firestore.collection('teachers').doc(currentTeacher.userId).set({
        'userId': currentTeacher.userId,
        'aboutMe': currentTeacher.aboutMe,
        'birthDate': currentTeacher.birthDate,
        'countryName': currentTeacher.country,
        'memberSince': currentTeacher.memberSince,
        'skills': currentTeacher.skills,
        'timeZone': currentTeacher.timeZone,
        'rating': 0,
      });
      await UserPreferences.instance.saveTeacher(currentTeacher);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> transformStudentToTeacher(BuildContext context) async {
    try {
      registerTeacher();

      currentUser.isTeacher = true;

      await _firestore.collection('users').doc(currentUser.id).update({
        'isTeacher': currentUser.isTeacher,
      });

      await UserPreferences.instance.saveUser(currentUser);
      Navigator.pop(context, true); // true = indica que hubo cambios
    } catch (e) {
      rethrow;
    }
  }

  Future<void> transformTeacherToStudent(BuildContext context) async {
    try {
      registerStudent();

      currentUser.isStudent = true;

      await _firestore.collection('users').doc(currentUser.id).update({
        'isStudent': currentUser.isStudent,
      });

      await UserPreferences.instance.saveUser(currentUser);
      Navigator.pop(context, true); // true = indica que hubo cambios
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
        ScaffoldMessageError(translate(context, "unexpectedError"), context);
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
        final userModel = UserModel.fromDocument(userDoc);
        await UserPreferences.instance.saveUser(userModel);
        currentUser = userModel;

        loginForm.isLoading = false;

        if (userModel.isStudent) saveStudent(uid);
        if (userModel.isTeacher) saveTeacher(uid);

        await updateUserConnectionStatus('yes');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NavBarPage()),
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
          loginForm.emailError = translate(context, "incorrectEmailOrPassword");
          ;
          loginForm.passwordError = translate(
            context,
            "incorrectEmailOrPassword",
          );
          ;
          break;
        case 'too-many-requests':
          ScaffoldMessageError(translate(context, "maxTries"), context);
          break;
        case 'operation-not-allowed':
          ScaffoldMessageError(translate(context, "loginDishabled"), context);
          break;
        case 'network-request-failed':
          ScaffoldMessageError(translate(context, "redError"), context);
          break;
        case 'invalid-credential':
          loginForm.emailError = translate(context, "incorrectEmailOrPassword");
          loginForm.passwordError = translate(
            context,
            "incorrectEmailOrPassword",
          );
          break;
        default:
          ScaffoldMessageError(translate(context, "loginError"), context);
      }

      loginForm.formKey.currentState
          ?.validate(); // Forzar revalidación de errores
      loginForm.isLoading = false;
    } catch (_) {
      ScaffoldMessageError(translate(context, "unexpectedError"), context);
      loginForm.isLoading = false;
    }
  }

  Future<void> saveStudent(String uid) async {
    try {
      final studentDoc = await _firestore.collection('students').doc(uid).get();
      if (studentDoc.exists) {
        final studentModel = StudentModel.fromFirestore(studentDoc);
        print('AFTER FROM FIRESTORE');
        await UserPreferences.instance.saveStudent(studentModel);
        currentStudent = studentModel;
      }
    } catch (e) {
      print("Error loading student data: $e");
    }
  }

  Future<void> saveTeacher(String uid) async {
    try {
      final teacherDoc = await _firestore.collection('teachers').doc(uid).get();
      if (teacherDoc.exists) {
        final teacherModel = TeacherModel.fromFirestore(teacherDoc);
        await UserPreferences.instance.saveTeacher(teacherModel);
        currentTeacher = teacherModel;
      }
    } catch (e) {
      print("Error loading student/teacher data: $e");
    }
  }

  Future<void> logout(BuildContext context) async {
    await updateUserConnectionStatus('no');
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();

    await UserPreferences.instance.deleteUser();
    await UserPreferences.instance.deleteStudent();
    await UserPreferences.instance.deleteTeacher();
    await UserPreferences.instance.deleteRefreshToken();
    Navigator.pushReplacementNamed(context, AccessPage.routeName);
  }

  Future<void> updateUserConnectionStatus(String status) async {
    try {
      final uid = currentUser.id;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'conected': status,
      });

      currentUser.connected = status;
      await UserPreferences.instance.saveUser(currentUser);
    } catch (e) {
      print('Error al actualizar el estado de conexión: $e');
    }
  }
}
