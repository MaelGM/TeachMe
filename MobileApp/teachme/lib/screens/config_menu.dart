
import 'package:flutter/material.dart';
import 'package:teachme/screens/choose_language_page.dart';
import 'package:teachme/service/auth_service.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate(context, "myAccount"), style: TextStyle(color: Colors.white, fontSize: 24),),
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
            Divider()
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
                Icon(Icons.logout, color: Colors.white, size: 24,),
                SizedBox(width: 10,),
                Text(
                  translate(context, "logout"),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
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
        child: _standardCard(Icons.settings, translate(context, "configurationTitle")),
      );
  }

  Padding _standardSwitcher(IconData icon,String text,bool switchValue,ValueChanged<bool> onChanged,) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 24,),
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
                  Text(text, style: TextStyle(color: Colors.white, fontSize: 18),),
                ],
              ),
              Expanded(child: Container(color: Colors.amber,)),
              Icon(Icons.arrow_forward, color: Colors.white,)
            ],
          ),
    );
  }
}