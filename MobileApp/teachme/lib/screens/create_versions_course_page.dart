import 'package:flutter/material.dart';
import 'package:teachme/models/adverstiment_model.dart';
import 'package:teachme/providers/tab_form_data.dart';
import 'package:teachme/service/course_service.dart';
import 'package:teachme/utils/utils.dart';

class CreateVersionsCoursePage extends StatefulWidget {
  final AdvertisementModel advertisement;

  const CreateVersionsCoursePage({super.key, required this.advertisement});

  @override
  State<CreateVersionsCoursePage> createState() =>
      _CreateVersionsCoursePageState();
}

class _CreateVersionsCoursePageState extends State<CreateVersionsCoursePage>
    with TickerProviderStateMixin {
  final List<String> _prices = [''];
  List<TabFormData> tabsData = [];

  int _currentTabIndex = 0;
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    tabsData.add(TabFormData());

    _tabController = TabController(length: _prices.length + 1, vsync: this);

    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    for (var tab in tabsData) {
      tab.dispose();
    }
    tabsData.clear();
    tabsData.add(TabFormData());
    _currentTabIndex = 0;

    _tabController.dispose();
    _tabController = TabController(length: tabsData.length + 1, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    super.dispose();
  }

  void _resetData() {
    for (var tab in tabsData) {
      tab.dispose();
    }
    tabsData.clear();
    tabsData.add(TabFormData());
    _currentTabIndex = 0;

    _tabController.dispose();
    _tabController = TabController(length: tabsData.length + 1, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Creando versiones'),
        actions: [
          IconButton(onPressed: () => _resetData(), icon: Icon(Icons.refresh)),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aqui puedes crear las versiones que podrán emplear los clientes. Puedes crear un máximo de 3 versiones, con diferente precio, descripción y especificaciones.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 10),
              _versionsTabBar(),
              SizedBox(height: 10),
              _tabContent(),
              SizedBox(height: 70),
            ],
          ),
        ),
      ),
      floatingActionButton: _createButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  TabBar _versionsTabBar() {
    final levelNames = ['Básico', 'Pro', 'Deluxe'];

    List<Tab> _tabs = [];

    for (int i = 0; i < tabsData.length; i++) {
      _tabs.add(Tab(text: levelNames[i]));
    }

    final canAddMore = tabsData.length < 3;
    if (canAddMore) {
      _tabs.add(Tab(icon: Icon(Icons.add)));
    }

    return TabBar(
      controller: _tabController,
      tabs: _tabs,
      onTap: (index) {
        if (canAddMore && index == _tabs.length - 1) {
          setState(() {
            tabsData.add(TabFormData());
            _tabController.dispose();
            _tabController = TabController(
              length: tabsData.length + (tabsData.length < 3 ? 1 : 0),
              vsync: this,
            );
            _tabController.addListener(() {
              setState(() {
                _currentTabIndex = _tabController.index;
              });
            });
            _tabController.animateTo(tabsData.length - 1);
          });
        }
      },
      isScrollable: false,
      labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontSize: 18, color: Colors.white),
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorColor: Color(0xFF3B82F6),
      labelColor: Color(0xFF3B82F6),
    );
  }

  Padding _createButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _onCreatePressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 43, 97, 184),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Crear',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabContent() {
    if (_currentTabIndex >= tabsData.length) {
      // Si pulsaron en "+" o índice fuera de rango, mostramos vacío o mensaje
      return SizedBox.shrink();
    }

    final tabData = tabsData[_currentTabIndex];

    void addParameter() {
      setState(() {
        tabData.keyControllers.add(TextEditingController());
        tabData.valueControllers.add(TextEditingController());
      });
    }

    void removeParameter(int index) {
      setState(() {
        tabData.keyControllers[index].dispose();
        tabData.valueControllers[index].dispose();
        tabData.keyControllers.removeAt(index);
        tabData.valueControllers.removeAt(index);
      });
    }

    Widget _inputField({
      required String label,
      required TextEditingController controller,
      int? minLines,
      required String hintText,
    }) {
      return TextField(
        controller: controller,
        maxLines: null,
        minLines: minLines,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white38),
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF3B82F6)),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputField(
            label: 'Precio *',
            controller: tabData.priceController,
            hintText: 'Introduce el precio',
          ),
          SizedBox(height: 16),
          _inputField(
            label: 'Título (opcional)',
            controller: tabData.titleController,
            minLines: 1,
            hintText: 'Introduce un título para esta versión',
          ),
          SizedBox(height: 16),
          _inputField(
            label: 'Descripción *',
            controller: tabData.descriptionController,
            minLines: 3,
            hintText: 'Introduce la descripción',
          ),
          SizedBox(height: 24),
          Text(
            'Características adicionales',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 8),

          ...List.generate(tabData.keyControllers.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: _inputField(
                      label: 'Clave',
                      controller: tabData.keyControllers[index],
                      hintText: 'Ejemplo: duración',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _inputField(
                      label: 'Valor',
                      controller: tabData.valueControllers[index],
                      hintText: 'Ejemplo: 30 días',
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => removeParameter(index),
                  ),
                ],
              ),
            );
          }),

          ElevatedButton.icon(
            onPressed: addParameter,
            icon: Icon(Icons.add, color: Colors.white),
            label: Text(
              'Agregar característica',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF3B82F6)),
          ),
        ],
      ),
    );
  }

  void _onCreatePressed() async {
    final levelNames = ['Básico', 'Pro', 'Deluxe'];
    print('Okeu');

    for (int i = 0; i < tabsData.length; i++) {
      final price = tabsData[i].priceController.text.trim();
      final description = tabsData[i].descriptionController.text.trim();
      if (price.isEmpty || description.isEmpty) {
        ScaffoldMessageError(
          'Por favor completa precio y descripción en la pestaña ${levelNames[i]}.',
          context,
        );
        return;
      }
    }

    print('Okeu');

    List<double> prices = [];
    Map<String, String> parametersBasic = {};
    Map<String, String>? parametersPro;
    Map<String, String>? parametersDeluxe;

    for (int i = 0; i < tabsData.length; i++) {
      final tab = tabsData[i];
      final price = double.tryParse(tab.priceController.text.trim()) ?? 0;

      // Obtenemos todos los parámetros, incluida la descripción
      final params = tab.getParametersMap();

      prices.add(price);

      switch (i) {
        case 0:
          parametersBasic = params; // no puede ser null
          break;
        case 1:
          parametersPro = params;
          break;
        case 2:
          parametersDeluxe = params;
          break;
      }
    }

    widget.advertisement.parametersBasic = parametersBasic;
    widget.advertisement.parametersPro = parametersPro;
    widget.advertisement.parametersDeluxe = parametersDeluxe;
    widget.advertisement.prices = prices;

    await CourseService.postAdvertisement(widget.advertisement);
  }
}
