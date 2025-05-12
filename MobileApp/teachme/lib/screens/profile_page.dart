import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:teachme/service/auth_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/widgets/hamburguer_menu.dart';
import 'package:teachme/widgets/skill_chips.dart';
import 'package:teachme/widgets/standard_app_bar.dart';
import 'package:teachme/widgets/widgets.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = 'profilePage';

  const ProfilePage({
    super.key,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    print(currentTeacher.country);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(child: _header(context)),
          ],
          body: currentUser.isTeacher ? _teacherSection(context) : _teacherSection(context),
        ),
      ),
    );
  }

  TabBar _tabBarTeacher(BuildContext context) {
    return TabBar(
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Estilo del tab activo
            unselectedLabelStyle: TextStyle(fontSize: 16, color: Colors.white), // Estilo de los inactivos
            
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: Color(0xFF3B82F6),
            labelColor: Color(0xFF3B82F6),
            tabs: [
              Tab(text: "Sobre mi"), 
              Tab(text: "Mis anuncios"),
              Tab(text: "Comentarios")
            ]
          );
  }

  Widget _header(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(),
        Container(
          padding: EdgeInsets.only(top: 60, bottom: 16, left: 16, right: 16),
          child: Column(
            children: [
              _profilePicture(context),
              const SizedBox(height: 15),
              Text(
                currentUser.username,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
        Positioned(
          top: 50,
          right: 0,

          child: HamburguerMenu()
        ),
      ],
    );
  }

  GestureDetector _profilePicture(BuildContext context) {
    return GestureDetector(
          onTap: () => _showConnectionOptions(context),
          child: Stack(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundImage: NetworkImage(currentUser.profilePicture),
                backgroundColor: Colors.grey[800],
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: currentUser.connected == 'yes' ?Colors.green : Colors.grey,
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
          padding: const EdgeInsets.only(left: 5, right: 5, bottom: 35, top: 10),
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
                title: Text("Desconectado", style: TextStyle(color: Colors.white)),
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

  Widget _teacherSection(BuildContext context) {
    return Column(
        children: [
          _tabBarTeacher(context),
          Expanded(
            child: TabBarView(
              children: [
                _aboutMeSection(),
                _aboutMeSection(),
                _aboutMeSection(),
              ]
            ),
          ),
        ],
      );
  }

  Widget _aboutMeSection() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User information', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
            SizedBox(height: 7,),
            ExpandableText(
              currentTeacher.aboutMe, maxLines: 5, style: TextStyle(color: Colors.white, fontSize: 15),
              expandText: 'show more', collapseText: 'show less', linkColor: Color(0xFF3B82F6),
            ),
            InfoListTile(subtitle: currentTeacher.country, icon: Icons.location_on, title: 'From',),
            InfoListTile(subtitle: currentTeacher.memberSince, icon: Icons.person_outline, title: 'Member since',),
            InfoListTile(subtitle: '2h ago', icon: Icons.location_on, title: 'Last active',),
            SizedBox(height: 7,),
            Text('Skills', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
            SizedBox(height: 7,),
            SkillChips(editable: false,)
          ],
        ),
      ),
    );
  }
}
