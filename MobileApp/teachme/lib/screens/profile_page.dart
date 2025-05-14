import 'package:flutter/material.dart';
import 'package:teachme/models/models.dart';
import 'package:teachme/service/auth_service.dart';
import 'package:teachme/service/teacher_service.dart';
import 'package:teachme/widgets/about_me_section.dart';
import 'package:teachme/widgets/widgets.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = 'profilePage';
  final UserModel user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.user.isTeacher) _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {_isLoading = true;});
    await TeacherService.setTeacher(widget.user.id);
    setState(() {_isLoading = false;});
  }

  @override
  void dispose() {
    TeacherService.ratings = [];
    TeacherService.courses = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          actions: [HamburguerMenu()],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _header(context),
                  _tabBarTeacher(context),
                  _teacherSection(context),
                ],
              ),
      ),
    );
  }

  Widget _teacherSection(BuildContext context) {
    return Expanded(
      child: TabBarView(
        children: [
          AboutMeSection(),
          TeacherCourses(),
          CommentsSection(),
        ],
      ),
    );
  }

  Container _tabBarTeacher(BuildContext context) {
    return Container(
      color: Color(0xFF151515),
      child: TabBar(
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorColor: Color(0xFF3B82F6),
        labelColor: Color(0xFF3B82F6),
        tabs: [
          Tab(text: "Sobre mi"),
          Tab(text: "Anuncios"),
          Tab(text: "Comentarios"),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      color: Color(0xFF151515),
      child: Container(
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
      ),
    );
  }

  GestureDetector _profilePicture(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.user.id == widget.user.id) _showConnectionOptions(context);
      },
      child: Stack(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundImage: NetworkImage(widget.user.profilePicture),
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
                title: Text("Conectado", style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  await authService.updateUserConnectionStatus("yes");
                  setState(() {});
                },
              ),
              ListTile(
                leading: Icon(Icons.circle, color: Colors.grey),
                title: Text(
                  "Desconectado",
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
