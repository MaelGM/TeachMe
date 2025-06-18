import 'package:flutter/material.dart';
import 'package:teachme/models/user_model.dart';
import 'package:teachme/service/auth_service.dart';
import 'package:teachme/service/teacher_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/widgets/hamburguer_menu.dart';
import 'package:teachme/widgets/my_interests.dart';

class StudentScreen extends StatefulWidget {
  final UserModel user;

  const StudentScreen({super.key, required this.user});
  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  bool _isLoading = false;

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
    });
    await TeacherService.setTeacher(widget.user.id);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        actions: [
          HamburguerMenu(
            onConfigUpdated: () async {
              await _loadUser();
              setState(() {});
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _header(context),
                  MyInterests(
                    onBecameTeacher: () async {
                      await _loadUser();
                      setState(() {});
                    },
                  ),
                ],
              ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border:
            currentUser.isStudent && !currentUser.isTeacher
                ? Border(bottom: BorderSide(width: 1, color: Color(0xFF3B82F6)))
                : null,
        color: Color(0xFF151515),
      ),
      width: double.infinity,
      padding: EdgeInsets.only(top: 60, bottom: 16, left: 16, right: 16),
      child: Column(
        children: [
          _profilePicture(context),
          const SizedBox(height: 15),
          Text(
            widget.user.username,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector _profilePicture(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.user.id == currentUser.id) _showConnectionOptions(context);
      },
      child: Stack(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundImage:
                widget.user.profilePicture.isEmpty
                    ? AssetImage('assets/defaultProfilePicture.png')
                    : NetworkImage(widget.user.profilePicture),
            backgroundColor: Colors.grey[800],
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color:
                    widget.user.connected == 'yes' ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConnectionOptions(BuildContext context) {
    AuthService authService = AuthService();
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 5,
            right: 5,
            bottom: 35,
            top: 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.circle, color: Colors.green),
                title: Text(translate(context, "connected"), style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  await authService.updateUserConnectionStatus("yes");
                  setState(() {});
                },
              ),
              ListTile(
                leading: Icon(Icons.circle, color: Colors.grey),
                title: Text(
                  translate(context, "disconnected"),
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await authService.updateUserConnectionStatus("no");
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }
}