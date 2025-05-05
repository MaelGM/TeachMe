import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teachme/providers/language_provider.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/utils/utils.dart';

class ChooseLanguagePage extends StatelessWidget{
  static const routeName = "chooseLanguage";
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(translate(context, "chooseLanguage"), style: TextStyle(color: Colors.white, fontSize: 24),),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: supportedLanguages.map((langCode) {
                final isSelected = languageProvider.locale.languageCode == langCode;

                return Card(
                  color: darkerColor,
                  elevation: isSelected ? 6 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide( 
                      color: isSelected ? selectedColor : darkerColor,
                      width: 2
                    )
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    title: Text(
                      getNativeDisplayLanguage(langCode),
                      style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? selectedColor : Colors.white),
                    ),
                    trailing: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isSelected ? Icon(Icons.check_circle, color: selectedColor, size: 28) : SizedBox.shrink()
                    ),
                    onTap: () {
                      languageProvider.setLanguage(langCode);
                      //Navigator.of(context).pop();
                    },
                  ),
                  
                );
              }
            ).toList(),
            
          ),
        ),
      ),
    );

  }
}