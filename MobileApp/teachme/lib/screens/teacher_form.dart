import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:teachme/models/country_model.dart';
import 'package:teachme/models/models.dart';
import 'package:teachme/models/skill_model.dart';
import 'package:teachme/providers/language_provider.dart';
import 'package:teachme/providers/teacher_form_provider.dart';
import 'package:teachme/service/auth_service.dart';
import 'package:teachme/service/country_service.dart';
import 'package:teachme/service/skill_service.dart';
import 'package:teachme/ui/input_decorations.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/utils/user_preferences.dart';
import 'package:teachme/utils/utils.dart';
import 'package:teachme/widgets/skill_chips.dart';

class TeacherForm extends StatefulWidget{
  static const routeName = "teacherForm";
  final bool editing;

  const TeacherForm({super.key, required this.editing});

  @override
  State<TeacherForm> createState() => _TeacherFormState();
}

class _TeacherFormState extends State<TeacherForm> {
  final TextEditingController _dateController = TextEditingController();
  late TextEditingController localidadController;
  late TextEditingController skillController;
  late TextEditingController englishSkillController;
  late Pais? country;
  DateTime? selectedDate;
  String description = '';

  @override
  void initState() {
    super.initState();
    currentTeacher = TeacherModel(userId: '', aboutMe: '', birthDate: '', rating: 0, ratingCount: 0, country: '', timeZone: '', memberSince: '', skills: []);
    localidadController = TextEditingController();
    skillController = TextEditingController();
    englishSkillController = TextEditingController();
  }

  @override
  void dispose() {
    localidadController.dispose();
    skillController.dispose();
    
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final teacherForm = Provider.of<TeacherFormProvider>(context);
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        title: Text(
          translate(context, "tellUsAboutYou"),
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        toolbarHeight: 70,
      ),
      body: Form(
        key: teacherForm.formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _teacherForm(teacherForm),
                      Spacer(), // empuja los botones al fondo si hay espacio
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50, top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _backButton(context),
                            widget.editing ? _saveButton(context, teacherForm) : _nextButton(context, teacherForm),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

  }

  Widget _teacherForm(TeacherFormProvider teacherForm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(translate(context, "aboutYou"), style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
        SizedBox(height: 2),
        _aboutMeField(teacherForm),
        SizedBox(height: 31),
        Text("${translate(context, "birthDate")}*", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
        SizedBox(height: 2),
        _dateField(teacherForm),
        SizedBox(height: 31),
        Text(translate(context, "locality"), style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
        SizedBox(height: 2),
        _countryField(teacherForm),
        SizedBox(height: 31),
        Text(translate(context, "skills"), style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
        SizedBox(height: 2),
        _skillsCards(teacherForm),
        SizedBox(height: 20),
        SkillChips(editable: true, teacher: currentTeacher),

      ],
    );
  }

  TypeAheadField<Pais> _countryField(TeacherFormProvider teacherForm) {
    return TypeAheadField<Pais>(
        suggestionsCallback: (pattern) async {
          final paises = UserPreferences.getPaises();
          final resultados = paises.where((p) => p.nombre.toLowerCase().contains(pattern.toLowerCase())).toList();

          return resultados;
        },
        itemBuilder: (context, Pais suggestion) {
          return ListTile(
            title: Text(suggestion.nombre),
            tileColor: const Color.fromARGB(255, 26, 26, 26),
            textColor: Colors.white,
          );
        },
        onSelected: (Pais suggestion) async {
          localidadController.text = suggestion.nombre;
          if(await lenguageValid()) {
            print("IDIOMA CAMBIADO");
            final langCode = getPreferredLanguageCode(country!);
            Provider.of<LanguageProvider>(context, listen: false).setLanguage(langCode);
          }
        },
        emptyBuilder: (context) => SizedBox.shrink(),
        controller: localidadController,
        builder: (context, controller, focusNode) {
          return TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator:(value) {
              if (value == null || value.isEmpty) return translate(context, "chooseYourCountry");
              return null;
            },
            style: TextStyle(color: Colors.white),
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecorations.authInputDecorationBorderFull(
              hintText: translate(context, "chooseYourHomeCountry"),
              labelText: translate(context, "country"),
              simplySuffixIcon: Icons.flag
            ),
          );
        },
      );
  }

  TextFormField _dateField(TeacherFormProvider teacherForm) {
    return TextFormField(
        controller: _dateController,
        readOnly: true,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: TextStyle(color: Colors.white),
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode()); // Quita el foco del teclado
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2000), // Fecha inicial sugerida
            firstDate: DateTime(1900),   // Fecha mínima permitida
            lastDate: DateTime.now(),    // No se puede seleccionar el futuro
          );
          if (picked != null) {
            setState(() {
              selectedDate = picked;
              _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
              teacherForm.date = _dateController.text;
            });
            print("FECHA: ${selectedDate.toString()}");
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) return translate(context, "selectBirthDate");
          if (selectedDate == null) return translate(context, "validBirthDate");

          final today = DateTime.now();
          final age = today.year - selectedDate!.year - ((today.month < selectedDate!.month || (today.month == selectedDate!.month && today.day < selectedDate!.day)) ? 1 : 0);
          if (age < 18) return translate(context, "minimumAge");
          return null;
        },
        decoration: InputDecorations.authInputDecorationBorderFull(
          hintText: translate(context, "selectBirthDate"),
          labelText: translate(context, "birthDate"),
          simplySuffixIcon: Icons.calendar_today
        ),
      );
  }

  TextFormField _aboutMeField(TeacherFormProvider teacherForm) {
    return TextFormField(
        onChanged: (value) {
          teacherForm.description = value;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value)  {
          if(value == null || value.isEmpty) return translate(context, "talkAboutYou");
          return null;
        },
        maxLines: null, 
        minLines: 5,    
        autofocus: false,
        textCapitalization: TextCapitalization.none,
        style: TextStyle(color: Colors.white),
        decoration: InputDecorations.authInputDecorationBorderFull(
            hintText: translate(context, "infoAboutYou"),
            labelText: translate(context, "infoAboutYou")),
      );
  }

  _skillsCards(TeacherFormProvider teacherForm) {
    return Row(
        children: [
          Expanded(child: _skillField()),
          _addButton(),
        ],
      );
  }

  Container _addButton() {
    return Container(
      margin: EdgeInsets.only(left: 20),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(20)
              
            ),
            child: IconButton(
              onPressed: () async {
                final habilidad = englishSkillController.text;
                final service = SkillService();
                final exists = await service.skillExists(habilidad);

                if(!exists) {
                  ScaffoldMessageError(translate(context, "unknownSkill"), context);
                }

                if (habilidad.isNotEmpty && habilidad != '' && exists && !currentTeacher.skills.contains(habilidad)) {
                  setState(() {
                    currentTeacher.skills.add(habilidad);
                    print("Habilidad ${habilidad} añadida");
                    print(currentTeacher.skills.length);
                    skillController.clear();
                    FocusScope.of(context).unfocus();
                  });
                }
              },
              icon: Icon(Icons.add, color: Colors.white,),
            ),
          );
  }

  TypeAheadField<Skill> _skillField() {
    return TypeAheadField<Skill>(
        suggestionsCallback: (pattern) async {
          final skills = UserPreferences.getSkills();
          final resultados = skills
            .where((skill) => !currentTeacher.skills.contains(skill.name))
            .where((skill) => skill.name.toLowerCase().contains(pattern.toLowerCase())).toList();

          return resultados;
        },
        emptyBuilder: (context) => SizedBox.shrink(),
        itemBuilder: (context, Skill skill) {
          return ListTile(
            title: Text(translate(context, skill.name)),
            tileColor: const Color.fromARGB(255, 26, 26, 26),
            textColor: Colors.white,
          );
        },
        onSelected: (Skill suggestion) {
          englishSkillController.text = suggestion.name;
          skillController.text = translate(context, suggestion.name);
        },
        controller: skillController,
        builder: (context, controller, focusNode) {
          return TextFormField(
            autofocus: false,
            style: TextStyle(color: Colors.white),
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecorations.authInputDecorationBorderFull(
              hintText: translate(context, "selectSkill"),
              labelText: translate(context, "skill"),
              simplySuffixIcon: Icons.school
            ),
          );
        },
      );
  }
  
  ElevatedButton _backButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
    
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,
        minimumSize: Size(100, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Border radius leve
        ),
        
      ),
      child: Row(
        spacing: 8,
        children: [
          Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          Text(translate(context, "back"),style: TextStyle(fontSize: 18,color: Colors.white,),),
          SizedBox(width: 8),
        ],
      ),
    );
  }

  ElevatedButton _nextButton(BuildContext context, TeacherFormProvider teacherForm) {
    AuthService authService;
    return ElevatedButton(
      onPressed: () async {
        if(teacherForm.isValidForm() && await lenguageValid()) {

          final bool? confirm = await _confirmDialog(context);

          if(confirm != true) return;

          teacherForm.isLoading = true;
          
          currentTeacher.birthDate = teacherForm.date;
          currentTeacher.aboutMe = teacherForm.description;
          currentTeacher.country = country!.nombre;
          currentTeacher.timeZone = country!.zonaHoraria;
          currentTeacher.memberSince = DateFormat("MMM yy", 'en_US').format(DateTime.now());

          final langCode = getPreferredLanguageCode(country!);
          Provider.of<LanguageProvider>(context, listen: false).setLanguage(langCode);

          authService = AuthService(); // Instancia de AuthService
          authService.register(context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF3B82F6), //teacherForm.isValidForm() ? Color(0xFF3B82F6) : Colors.grey,
        minimumSize: Size(0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Border radius leve
        ),
        
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            translate(context, "next"),
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 8),
          Icon(
            Icons.arrow_forward,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  ElevatedButton _saveButton(BuildContext context, TeacherFormProvider teacherForm) {
    AuthService authService;
    return ElevatedButton(
      onPressed: () async {
        if(teacherForm.isValidForm() && await lenguageValid()) {

          final bool? confirm = await _confirmDialog(context);

          if(confirm != true) return;

          teacherForm.isLoading = true;
          
          currentTeacher.birthDate = teacherForm.date;
          currentTeacher.aboutMe = teacherForm.description;
          currentTeacher.country = country!.nombre;
          currentTeacher.timeZone = country!.zonaHoraria;
          currentTeacher.memberSince = DateFormat("MMM yy", 'en_US').format(DateTime.now());

          final langCode = getPreferredLanguageCode(country!);
          Provider.of<LanguageProvider>(context, listen: false).setLanguage(langCode);

          print('_saveButton method: ${currentUser.id}');
          
          authService = AuthService(); // Instancia de AuthService
          authService.transformStudentToTeacher(context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF3B82F6), //teacherForm.isValidForm() ? Color(0xFF3B82F6) : Colors.grey,
        minimumSize: Size(0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Border radius leve
        ),
        
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            translate(context, "save"),
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 8),
          Icon(
            Icons.arrow_forward,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF121212),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
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
            child: Text(translate(context, "confirm"), style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }



  Future<bool> lenguageValid() async{
    final countryService = CountryService();
    country = await countryService.getCountryByName(localidadController.text.trim());

    if (country == null) {
      ScaffoldMessageError(translate(context, "unknownCountry"), context);
      return false;
    }

    return true;
  }

  String capitalize(String word) {
    if (word.isEmpty) return word;
    return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
  }
  
  String capitalizePhrase(String phrase) {
    if (phrase.trim().isEmpty) return phrase;

    return phrase
        .trim()
        .split(RegExp(r'\s+'))
        .map((word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }
  
}