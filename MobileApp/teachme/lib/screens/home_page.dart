import 'package:flutter/material.dart';
import 'package:teachme/service/auth_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/widgets/widgets.dart';

class HomePage extends StatelessWidget{
  static const routeName = 'home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('TeachMe'), 
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          HamburguerMenu()
        ],
      ),
      body: Column(
        children: [
          Text(currentUser.email, style: TextStyle(color: Colors.white),),
          Text(currentUser.username, style: TextStyle(color: Colors.white),),
          Text(currentUser.isStudent.toString(), style: TextStyle(color: Colors.white),),
          Text(currentUser.isTeacher.toString(), style: TextStyle(color: Colors.white),),
          Text(currentUser.profilePicture, style: TextStyle(color: Colors.white),),
          Image(image: NetworkImage(currentUser.profilePicture)),
          if(currentUser.isTeacher) Column(
            children: [
              Text('About Me: ${currentTeacher.aboutMe}'),
              Text('Birth Date: ${currentTeacher.birthDate}')
            ],
          )
        ],
      )
      
      //Container(
        //child: Center(child: Text(translate(context, "home"), style: TextStyle(color: Colors.white, fontSize: 24),),),
      //)
    );
  }
}