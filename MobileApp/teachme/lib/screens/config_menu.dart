import 'package:flutter/material.dart';
import 'package:teachme/screens/choose_language_page.dart';
import 'package:teachme/screens/pages.dart';
import 'package:teachme/service/auth_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/utils/user_preferences.dart';
import 'package:teachme/utils/utils.dart';

class ConfigMenuPage extends StatefulWidget {
  static const routeName = "menuConfig";
  @override
  State<ConfigMenuPage> createState() => _ConfigMenuPageState();
}

class _ConfigMenuPageState extends State<ConfigMenuPage> {
  bool isSwitched = false;

  @override
  void initState() {
    super.initState();
    UserPreferences.getSwitchValue().then((value) {
      setState(() {
        isSwitched = value;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          translate(context, "myAccount"),
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Divider(),
            _standardSwitcher(
              Icons.notifications,
              translate(context, "notifications"),
              isSwitched,
              (value) {
                setState(() {
                  isSwitched = value;
                  UserPreferences.saveSwitchValue(value);
                });
              },
            ),
            Divider(),
            _languageCard(),
            _configurationCard(),
            if (!currentUser.isStudent) _becomeStudentCard(),
            if (!currentUser.isTeacher) _becomeTeacherCard(),
            Divider(),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              final authService = AuthService();
              authService.logout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: Colors.white, size: 24),
                SizedBox(width: 10),
                Text(
                  translate(context, "logout"),
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _languageCard() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, ChooseLanguagePage.routeName),
      child: _standardCard(Icons.language, translate(context, "language")),
    );
  }

  Widget _configurationCard() {
    return GestureDetector(
      //TODO: onTap: () => Navigator.pushNamed(context, ChooseLanguagePage.routeName),
      child: _standardCard(
        Icons.settings,
        translate(context, "configurationTitle"),
      ),
    );
  }

  Widget _becomeTeacherCard() {
    return GestureDetector(
      onTap: () async {
        final bool? confirm = await _alertDialog(context, "profesor");

        if(confirm != true) return;

        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TeacherForm(editing: true)),
        );
      },
      child: _standardCard(Icons.person, 'Become a teacher'),
    );
  }

  Widget _becomeStudentCard() {
    return GestureDetector(
      onTap: () async {
        final bool? confirm = await _alertDialog(context, "estudiante");

        if(confirm != true) return;

        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChooseInterestsPage(editing: false, newStudent: true,)),
        );
      },
      child: _standardCard(Icons.school, 'Become a student'),
    );
  }

  Padding _standardSwitcher(
    IconData icon,
    String text,
    bool switchValue,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          const Spacer(),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: switchValue,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: selectedColor,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _standardCard(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: Color(0xFF090909),
      child: Row(
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              SizedBox(width: 10),
              Text(text, style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          Expanded(child: Container(color: Colors.amber)),
          Icon(Icons.arrow_forward, color: Colors.white),
        ],
      ),
    );
  }

  Future<bool?> _alertDialog(BuildContext context, String palabra) {
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
                  Icons.warning_amber_rounded,
                  color: Color(0xFFF59E0B), // Color de advertencia (amarillo)
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  "Confirmar acción",
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
                  "¿Estás seguro de que deseas convertirte en un $palabra?",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  "Esta acción no es reversible.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(
                      0xFF3B82F6,
                    ), // Color rojo claro para advertencia
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
                child: Text("Cancelar"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Confirmar", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }
}
