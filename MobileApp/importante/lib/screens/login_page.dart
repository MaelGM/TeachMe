import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teachme/providers/providers.dart';
import 'package:teachme/widgets/widgets.dart';

class LoginPage extends StatelessWidget{
  static const routeName = "login";
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: Text("Bienvenido a TeachMe", style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),),
          bottom: TabBar(

            labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Estilo del tab activo
            unselectedLabelStyle: TextStyle(fontSize: 16, color: Colors.white), // Estilo de los inactivos

            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: Color(0xFF3B82F6),
            labelColor: Color(0xFF3B82F6),
            tabs: [Tab(text: "Iniciar sesión", ), Tab(text: "Registrarse",)]
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),

          children: [
            ChangeNotifierProvider(create: (_) => LoginFormProvider(), child: LoginForm()),
            Container()
          ]
        ),
      )
    );
  }
}
