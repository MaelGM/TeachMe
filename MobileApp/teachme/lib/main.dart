import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:teachme/firebase_options.dart';
import 'package:teachme/providers/providers.dart';
import 'package:teachme/providers/teacher_form_provider.dart';
import 'package:teachme/routes/routes.dart';
import 'package:teachme/screens/pages.dart';
import 'package:teachme/service/auth_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/utils/user_preferences.dart';
import 'package:teachme/widgets/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  await UserPreferences.instance.initPrefs();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  bool isSessionActive = await AuthService.initSession();
  if(isSessionActive) currentUser = (await UserPreferences.instance.getUser())!;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => TeacherFormProvider()),
        ChangeNotifierProvider(create: (_) => LoginFormProvider()),
        ChangeNotifierProvider(create: (_) => SignFormProvider()),
      ],
      child: MyApp(isSessionActive: isSessionActive)
    )
    
  );
    
    
}

class MyApp extends StatelessWidget {
  final bool isSessionActive;

  MyApp({required this.isSessionActive});
    @override
    Widget build(BuildContext context) {
      final languageProvider = Provider.of<LanguageProvider>(context);

      return MaterialApp(
        locale: languageProvider.locale,
        supportedLocales: supportedLanguages.map((lang) => Locale(lang)).toList(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        title: 'TeachMe',
        debugShowCheckedModeBanner: false, 
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            color: Color(0xFF151515), 
            iconTheme: IconThemeData(color: Colors.white), 
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 28)
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF151515),
            selectedItemColor: Color(0xFF3B82F6), 
            unselectedItemColor: Colors.white,
          ),
          scaffoldBackgroundColor: Color(0xFF090909),
          primaryColor: Color(0xFF090909),
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF090909)),
        ),
        initialRoute: isSessionActive ? NavBarPage.routeName :AccessPage.routeName,
        routes: getApplicationRoutes(),
      );
  }
}