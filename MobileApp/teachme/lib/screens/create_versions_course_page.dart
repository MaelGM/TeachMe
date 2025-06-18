import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teachme/models/adverstiment_model.dart';
import 'package:teachme/providers/tab_form_data.dart';
import 'package:teachme/service/course_service.dart';
import 'package:teachme/service/navigation_service.dart';
import 'package:teachme/utils/translate.dart';
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(translate(context, "creatingVersions")),
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
                translate(context, "versionsTutorial"),
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
    final levelNames = [translate(context, "basic"), translate(context, "pro"), translate(context, "deluxe")];

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
          onPressed: _isLoading ? null : _onCreatePressed,
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
                _isLoading ? translate(context, "creating") : translate(context, "create"),
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
      bool isPrice = false, // <-- nuevo parámetro
    }) {
      return TextField(
        controller: controller,
        maxLines: null,
        minLines: minLines,
        style: TextStyle(color: Colors.white),
        keyboardType:
            isPrice
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
        inputFormatters:
            isPrice
                ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
                : [],
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
            label: '${translate(context, "price")} *',
            controller: tabData.priceController,
            hintText: translate(context, "tapPrice"),
            isPrice: true,
          ),
          SizedBox(height: 16),
          _inputField(
            label: translate(context, "titleOptional"),
            controller: tabData.titleController,
            minLines: 1,
            hintText: translate(context, "typeTitleForVersion"),
          ),
          SizedBox(height: 16),
          _inputField(
            label: '${translate(context, "description")} *',
            controller: tabData.descriptionController,
            minLines: 3,
            hintText: translate(context, "typeDescription"),
          ),
          SizedBox(height: 24),
          Text(
            translate(context, "additionalsThings"),
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
                      label: translate(context, "key"),
                      controller: tabData.keyControllers[index],
                      hintText: translate(context, "keyExample"),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _inputField(
                      label: translate(context, "valor"),
                      controller: tabData.valueControllers[index],
                      hintText: translate(context, "valorExample"),
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
              translate(context, "addThing"),
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF3B82F6)),
          ),
        ],
      ),
    );
  }

  void _onCreatePressed() async {
    final levelNames = [translate(context, "basic"), translate(context, "pro"), translate(context, "deluxe")];

    setState(() {
      _isLoading = true;
    });

    for (int i = 0; i < tabsData.length; i++) {
      final price = tabsData[i].priceController.text.trim();
      final description = tabsData[i].descriptionController.text.trim();
      if (price.isEmpty || description.isEmpty) {
        ScaffoldMessageError(
          translate(context, "completeVersions"),
          context,
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

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

    await CourseService.postAdvertisement(widget.advertisement, context);
    setState(() {
      _isLoading = false;
    });

    if (context.mounted) {
      // Cambias el índice para que muestre la pantalla perfil
      navIndexNotifier.value = 3;

      // Luego haces pop hasta que vuelvas a la raíz
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}
