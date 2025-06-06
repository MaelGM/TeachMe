import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:teachme/providers/edit_form_provider.dart';
import 'package:teachme/screens/waiting_email_verification_page.dart';
import 'package:teachme/service/image_service.dart';
import 'package:teachme/service/profile_service.dart';
import 'package:teachme/ui/input_decorations.dart';

import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/utils/utils.dart';
import 'package:teachme/widgets/email_input_login.dart';
import 'package:teachme/widgets/hamburguer_menu.dart';

class EditAccountPage extends StatefulWidget {
  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final picker = ImagePicker();
  bool _isLoading = false;
  late String profileImage;
  File? _localProfileImageFile;

  @override
  void initState() {
    super.initState();
    final editForm = Provider.of<EditFormProvider>(context, listen: false);
    profileImage = currentUser.profilePicture;
    editForm.name = currentUser.username;
    editForm.email = currentUser.email;
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 35,
            top: 20,
          ),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.white),
                title: Text(
                  'Usar cámara',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.white),
                title: Text(
                  'Elegir de galería',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _localProfileImageFile = File(pickedFile.path);
        profileImage = pickedFile.path; // para previsualizar
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final editForm = Provider.of<EditFormProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [HamburguerMenu()],
      ),
      body: Column(
        children: [
          _header(context),
          Form(
            key: editForm.formKey,
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(
                vertical: 30,
                horizontal: 20,
              ),
              child: Column(
                children: [
                  _nameInput(editForm, context),
                  SizedBox(height: 25),
                  EmailInputEdit(editForm: editForm, context: context),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _saveButton(editForm, context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Column _nameInput(EditFormProvider signForm, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${translate(context, "name")} *",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2),
        TextFormField(
          initialValue: currentUser.username,
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
            labelText: translate(context, "name"),
          ),
        ),
      ],
    );
  }

  _validName(
    BuildContext context,
    String? username,
    EditFormProvider signForm,
  ) {
    if (username == null || username.isEmpty)
      return translate(context, "enterNamePlease");
    return signForm.nameError; // Mostrar error dinámico si existe
  }

  Padding _saveButton(EditFormProvider editForm, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: FloatingActionButton.extended(
          backgroundColor: Color(0xFF3B82F6),
          onPressed:
              _isLoading
                  ? () {}
                  : () async {
                    final bool? confirm = await _confirmDialog(context);

                    if (confirm != true) return;

                    setState(() {
                      _isLoading = true;
                    });
                    if (!editForm.formKey.currentState!.validate()) {
                      setState(() => _isLoading = false);
                      ScaffoldMessageError('Revise los campos', context);
                      return;
                    }

                    if (_localProfileImageFile != null) {
                      final uploadedUrl =
                          await ImageService.uploadImageToCloudinary(
                            _localProfileImageFile!,
                          );
                      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
                        profileImage = uploadedUrl;
                      } else {
                        ScaffoldMessageError(
                          'Error al subir la imagen',
                          context,
                        );
                        setState(() => _isLoading = false);
                        return;
                      }
                    }

                    final user = FirebaseAuth.instance.currentUser!;

                    if (editForm.email != currentUser.email) {
                      try {
                        await user.verifyBeforeUpdateEmail(editForm.email);
                        // Aquí rediriges a la pantalla de espera, no actualizas Firestore todavía
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => WaitingEmailVerificationPage(
                                  newEmail: editForm.email,
                                ),
                          ),
                        );
                        return;
                      } catch (e) {
                        ScaffoldMessageError(
                          'No se pudo enviar el correo de verificación',
                          context,
                        );
                        setState(() => _isLoading = false);
                        return;
                      }
                    }

                    // Si no cambia el email, entonces sí puedes actualizar inmediatamente
                    await ProfileService.updateUser(
                      editForm,
                      profileImage,
                      context,
                    );
                    setState(() {
                      _isLoading = false;
                      _localProfileImageFile = null;
                    });
                    Navigator.pop(context, true);
                  },
          label: Text(
            'Save',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: Color(0xFF3B82F6))),
        color: Color(0xFF151515),
      ),
      width: double.infinity,
      padding: EdgeInsets.only(top: 80, bottom: 16),
      child: Column(
        children: [_profilePicture(context), const SizedBox(height: 15)],
      ),
    );
  }

  Widget _profilePicture(BuildContext context) {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundImage:
                _isLoading
                    ? null
                    : _localProfileImageFile != null
                    ? FileImage(_localProfileImageFile!)
                    : (profileImage.startsWith('http')
                        ? NetworkImage(profileImage)
                        : AssetImage('assets/defaultProfilePicture.png')
                            as ImageProvider),
            backgroundColor: Colors.grey[800],
            child:
                _isLoading ? Center(child: CircularProgressIndicator()) : null,
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 18,
              height: 18,
              child: Icon(Icons.camera_alt, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Color(0xFF121212),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Column(
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF3B82F6),
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  translate(context, "confirmData"),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  translate(context, "areYouSureData"),
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  translate(context, "youCanEditLater"),
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF3B82F6),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(translate(context, "cancel")),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  translate(context, "confirm"),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
