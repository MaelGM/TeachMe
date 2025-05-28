import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:teachme/screens/choose_interests_page.dart';
import 'package:teachme/screens/payment_page.dart';
import 'package:teachme/screens/profile_page.dart';
import 'package:teachme/service/course_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/utils.dart';
import 'package:teachme/widgets/hamburguer_menu.dart';
import 'package:teachme/widgets/horizontal_comments.dart';
import 'package:teachme/widgets/other_courses_recomendations.dart';

class CourseDetailsPage extends StatefulWidget {
  static final routeName = 'courseDetails';

  const CourseDetailsPage({super.key});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentTabIndex = 0;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final CourseService _courseService = CourseService();
  bool _isScrolledPastImage = false;
  bool _hasChangedFavorite = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: CourseService.course.prices.length,
      vsync: this,
    );

    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });

    _scrollController.addListener(() {
      final scrollOffset = _scrollController.offset;
      final screenHeight = MediaQuery.of(context).size.height;
      final imageHeight = screenHeight * 0.3;

      if (scrollOffset > imageHeight && !_isScrolledPastImage) {
        setState(() => _isScrolledPastImage = true);
      } else if (scrollOffset <= imageHeight && _isScrolledPastImage) {
        setState(() => _isScrolledPastImage = false);
      }
    });

    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    await CourseService.setTeacher(CourseService.course.tutorId);
    await _courseService.getFirstsComments();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              color:
                  _isScrolledPastImage ? Color(0xFF151515) : Colors.transparent,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context, _hasChangedFavorite);
                  },
                ),
                actions: [
                  if (currentUser.isStudent &&
                      CourseService.course.tutorId != currentUser.id)
                    _favButton(),
                  HamburguerMenu(),
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _topImage(screenHeight),
                _teacherBanner(),
                _textContent(),
                _pricesTab(),
                HorizontalComments(),
                OtherCoursesRecomendations(),
                SizedBox(height: 40),
              ],
            ),
          ),
        );
  }

  Widget _favButton() {
    final isFavorite = currentStudent.savedAdvertisements.any(
      (ad) => ad.id == CourseService.course.id,
    );

    return IconButton(
      icon:
          isFavorite
              ? Icon(Icons.favorite, color: Colors.red)
              : Icon(Icons.favorite_outline, color: Colors.white),
      onPressed: () async {
        setState(() {
          if (isFavorite) {
            currentStudent.savedAdvertisements.removeWhere(
              (ad) => ad.id == CourseService.course.id,
            );
          } else {
            currentStudent.savedAdvertisements.add(CourseService.course);
          }
          _hasChangedFavorite = true;
        });

        await _courseService.updateSavedAdvertisementsInFirestore(
          currentStudent.userId,
          currentStudent.savedAdvertisements,
        );
      },
    );
  }

  Widget _pricesTab() {
    final prices = CourseService.course.prices;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xFF151515),
        border: Border.symmetric(
          horizontal: BorderSide(
            width: 1,
            color: Color.fromARGB(255, 44, 44, 44),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_tabBar(prices), SizedBox(height: 10), _tabContent(prices)],
      ),
    );
  }

  TabBar _tabBar(List<double> prices) {
    return TabBar(
      controller: _tabController,
      labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontSize: 18, color: Colors.white),
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorColor: Color(0xFF3B82F6),
      labelColor: Color(0xFF3B82F6),
      onTap: (index) {
        setState(() {
          _currentTabIndex = index;
        });
      },
      tabs: prices.map((p) => Tab(text: '${p.toStringAsFixed(0)} €')).toList(),
    );
  }

  IndexedStack _tabContent(List<double> prices) {
    final course =
        CourseService
            .course; // Obtenemos el curso de esta manera y asi podemos hacer uso de el de manera mas facil

    // Obtenemos el mapa correcto dependiendo de que pantalla del tab estamos mirando
    Map<String, String>? getParametersForIndex(int index) {
      if (index == 0) return course.parametersBasic;
      if (index == 1) return course.parametersPro;
      if (index == 2) return course.parametersDeluxe;
      return null;
    }

    return IndexedStack(
      index: _currentTabIndex,
      children:
          prices.map((price) {
            final index = prices.indexOf(
              price,
            ); // Cogemos en que posición estamos de la lista de precios
            final parameters = getParametersForIndex(
              index,
            ); // Dependiendo del indice, cogemos unos parametros u otros

            if (parameters == null || parameters.isEmpty) {
              // En caso de error mostramos un mensaje
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "No hay información disponible.",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (parameters.containsKey('title')) ...[
                    Text(
                      parameters['title']!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                  ],

                  if (parameters.containsKey('description')) ...[
                    Text(
                      parameters['description']!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 8),
                  ],

                  // Mostrar el resto del mapa, excluyendo 'Titulo' y 'Descripcion'
                  ...parameters.entries
                      .where(
                        (entry) =>
                            entry.key != 'title' && entry.key != 'description',
                      )
                      .map((entry) => _printParameter(entry)),
                  SizedBox(height: 10),
                  _payButton(price),
                ],
              ),
            );
          }).toList(),
    );
  }

  TextButton _payButton(double price) {
    return TextButton(
      onPressed: () async {
        if (currentUser.isTeacher &&
            CourseService.course.tutorId == currentTeacher.userId) {
          ScaffoldMessageError(
            'El autor del curso no puede comprar este mismo curso',
            context,
          );
        } else if (!currentUser.isStudent) {
          _alertDialogNoEstudiante(context);
        } else if (currentStudent.payedAdvertisements.any(
          (ad) =>
              ad.id == CourseService.course.id &&
              ad.paidPrice != null && ad.paidPrice == price, 
        )) {
          ScaffoldMessageError(
            'Ya ha pagado esta versión de este curso',
            context,
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => PaymentPage(
                    amount: price,
                    courseTitle: CourseService.course.title,
                  ),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color:
              currentUser.isTeacher &&
                      CourseService.course.tutorId == currentTeacher.userId
                  ? Colors.grey
                  : Color(0xFF3B82F6),
        ),
        child: Center(
          child: Text(
            'Continuar ${price.toStringAsFixed(0)} €',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Future<bool?> _alertDialogNoEstudiante(BuildContext context) {
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
                  Icons.error_outline,
                  color: Color(0xFFEF4444), // Color de advertencia (rojo)
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  "Acceso restringido",
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
                  "No puedes pagar este curso o servicio si no eres un estudiante.",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                    children: [
                      TextSpan(text: 'Haz clic '),
                      TextSpan(
                        text: 'aquí',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ChooseInterestsPage(
                                          editing: false,
                                          newStudent: true,
                                        ),
                                  ),
                                );
                              },
                      ),
                      TextSpan(text: ' para convertirte en uno.'),
                    ],
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                onPressed: () {
                  print("Cancelar presionado");
                  Navigator.of(context).pop(false);
                },
                child: Text("Cancelar"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  print("Confirmar presionado");
                  Navigator.of(context).pop(true);
                },
                child: Text("Confirmar", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  Container _printParameter(MapEntry<String, String> entry) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            entry.key,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            entry.value,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _textContent() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Color(0xFF151515),
        border: Border.symmetric(
          horizontal: BorderSide(
            width: 1,
            color: Color.fromARGB(255, 44, 44, 44),
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 15,
        children: [
          Text(
            CourseService.course.title,
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          ExpandableText(
            CourseService.course.description,
            maxLines: 7,
            style: TextStyle(color: Colors.white, fontSize: 15),
            expandText: 'show more',
            linkColor: Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  Widget _teacherBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (_, __, ___) =>
                    ProfilePage(user: CourseService.authorUserAcount),
            transitionsBuilder: (_, animation, __, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              var tween = Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: ListTile(
          leading: _circleAvatar(),
          title: Text(
            CourseService.authorUserAcount.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          subtitle: _showUserScore(),
        ),
      ),
    );
  }

  Stack _circleAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(
            CourseService.authorUserAcount.profilePicture,
          ),
          backgroundColor: Colors.grey[800],
        ),
        Positioned(
          bottom: 2,
          right: 0,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color:
                  CourseService.authorUserAcount.connected == 'yes'
                      ? Colors.green
                      : Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Row _showUserScore() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        Icon(Icons.star, color: Colors.white, size: 18),
        const SizedBox(width: 4),
        Text(
          CourseService.author.rating.toStringAsFixed(1),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Text(
          "(${CourseService.author.ratingCount.toInt()})",
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }

  SizedBox _topImage(double screenHeight) {
    return SizedBox(
      height: screenHeight * 0.33,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: CourseService.course.photos.length,
            itemBuilder: (context, index) {
              return Image.network(
                CourseService.course.photos[index],
                width: double.infinity,
                fit: BoxFit.cover,
              );
            },
          ),
          Positioned(
            bottom: 15,
            child: SmoothPageIndicator(
              controller: _pageController,
              count: CourseService.course.photos.length,
              effect: WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Colors.white,
                dotColor: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
