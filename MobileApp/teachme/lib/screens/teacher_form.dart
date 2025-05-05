import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:teachme/models/country_model.dart';
import 'package:teachme/models/models.dart';
import 'package:teachme/providers/teacher_form_provider.dart';
import 'package:teachme/service/auth_service.dart';
import 'package:teachme/ui/input_decorations.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/utils/user_preferences.dart';

class TeacherForm extends StatefulWidget{
  static const routeName = "teacherForm";
  @override
  State<TeacherForm> createState() => _TeacherFormState();
}

class _TeacherFormState extends State<TeacherForm> {
  final TextEditingController _dateController = TextEditingController();
  late TextEditingController localidadController;
  late TextEditingController zonaHorariaController;
  late TextEditingController lenguajeController;
  DateTime? selectedDate;
  String description = '';

  @override
  void initState() {
    super.initState();
    currentTeacher = TeacherModel(userId: '', aboutMe: '', birthDate: '', rating: 0, country: '', timeZone: '', memberSince: '');
    localidadController = TextEditingController();
    zonaHorariaController = TextEditingController();
    lenguajeController = TextEditingController();
  }

  @override
  void dispose() {
    localidadController.dispose();
    zonaHorariaController.dispose();
    lenguajeController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final teacherForm = Provider.of<TeacherFormProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        title: Text(translate(context, "tellUsAboutYou"), style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),),
        centerTitle: true,
        toolbarHeight: 70,
      ),
      body: Form(
        key: teacherForm.formKey,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _teacherForm(teacherForm),
              Container(),
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _backButton(context),
                    _nextButton(context, teacherForm),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _teacherForm(TeacherFormProvider teacherForm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Sobre ti*", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
        SizedBox(height: 2),
        _aboutMeField(teacherForm),
        SizedBox(height: 31),
        Text("Fecha de nacimiento*", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
        SizedBox(height: 2),
        _dateField(teacherForm),
        SizedBox(height: 31),
        Text("Localidad*", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
        SizedBox(height: 2),
        _countryField(teacherForm),

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
          return ListTile(title: Text(suggestion.nombre));
        },
        onSelected: (Pais suggestion) {
          localidadController.text = suggestion.nombre;
          setState(() {
            zonaHorariaController.text = suggestion.zonaHoraria;
            lenguajeController.text = suggestion.idiomas.join(', ');
            // update modelo del trabajador
          });
        },
        controller: localidadController,
        builder: (context, controller, focusNode) {
          return TextFormField(
            validator:(value) {
              if (value == null || value.isEmpty) return 'Seleccione su país';
              return null;
              
            },
            style: TextStyle(color: Colors.white),
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecorations.authInputDecorationBorderFull(
              hintText: 'Seleccione el pais en el que habita',
              labelText: 'Pais',
              simplySuffixIcon: Icons.calendar_today
            ),
          );
        },
      );
  }

  TextFormField _dateField(TeacherFormProvider teacherForm) {
    return TextFormField(
        controller: _dateController,
        readOnly: true,
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
            print("FECHA: ${_dateController.text}");
            print("FECHA: ${teacherForm.date}");
            print("PICKED");
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) return 'Selecciona tu fecha de nacimiento';
          if (selectedDate == null) return 'Selecciona una fecha válida';

          final today = DateTime.now();
          final age = today.year - selectedDate!.year - ((today.month < selectedDate!.month || (today.month == selectedDate!.month && today.day < selectedDate!.day)) ? 1 : 0);
          if (age < 18) return 'Para impartir clases, debes tener al menos 18 años';
          return null;
        },
        decoration: InputDecorations.authInputDecorationBorderFull(
          hintText: 'Selecciona tu fecha de nacimiento',
          labelText: 'Fecha de nacimiento',
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
          if(value == null || value.isEmpty) return 'Hablanos un poco de ti';
          return null;
        },
        maxLines: null, 
        minLines: 5,    
        autofocus: false,
        textCapitalization: TextCapitalization.none,
        style: TextStyle(color: Colors.white),
        decoration: InputDecorations.authInputDecorationBorderFull(
            hintText: 'Escribe algo sobre ti, como tu objetivo o tu formación',
            labelText: 'Escribe algo sobre ti, como tu objetivo o tu formación'),
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
      onPressed: () => {
        if(teacherForm.isValidForm()) {
          teacherForm.isLoading = true,
          currentTeacher.birthDate = teacherForm.date,
          currentTeacher.aboutMe = teacherForm.description,

          authService = AuthService(), // Instancia de AuthService
          authService.register(context)
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF3B82F6),
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
}