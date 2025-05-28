import 'package:teachme/models/models.dart';
import 'package:teachme/service/auth_service.dart';
import 'package:teachme/service/teacher_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/widgets/favorite_courses.dart';
import 'package:teachme/widgets/about_me_section.dart';
import 'package:teachme/widgets/payed_courses.dart';
import 'package:teachme/widgets/student_screen.dart';
import 'package:teachme/widgets/widgets.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = 'profilePage';
  final UserModel user;
  final int? initialIndex;

  const ProfilePage({super.key, required this.user, this.initialIndex});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false;
  String _currentView = 'Favoritos';

  @override
  void initState() {
    super.initState();
    if (widget.user.isTeacher) _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
    });
    await TeacherService.setTeacher(widget.user.id);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    TeacherService.ratings = [];
    TeacherService.courses = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.user.isTeacher
        ? _teacherScreen(context)
        : StudentScreen(user: widget.user);
  }

  DefaultTabController _teacherScreen(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialIndex != null ? widget.initialIndex! : 0,
      length: currentUser.isStudent && currentUser.id == widget.user.id ? 4 : 3,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          actions: [HamburguerMenu()],
        ),
        body:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    _header(context),
                    _tabBarTeacher(context),
                    _teacherSection(context),
                  ],
                ),
      ),
    );
  }

  Widget _teacherSection(BuildContext context) {
    return Expanded(
      child: TabBarView(
        children: [
          AboutMeSection(),
          TeacherCourses(),
          CommentsSection(),
          if (currentUser.isStudent && currentUser.id == widget.user.id)
            _otrosTab(),
        ],
      ),
    );
  }

  Widget _otrosTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.only(top: 15, right: 20),
          child: TextButton(
            onPressed: () => _showViewOptions(context),
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: _textButtonText(),
          ),
        ),
        Expanded(
          child: _currentView == 'Favoritos'
              ? FavoriteCourses()
              : PayedCourses(),
        ), // Mostrar vista según opción
      ],
    );
  }

  Widget _textButtonText() {
    return Text(
      "Ver: $_currentView",
      style: TextStyle(
        color: Color(0xFF3B82F6),
        fontSize: 16,
      ),
    );
  }

  void _showViewOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 35,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mostrar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 10),
              Divider(color: const Color.fromARGB(31, 158, 158, 158)),
              ListTile(
                leading: Icon(Icons.favorite, color: Colors.white),
                title: Text("Favoritos", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentView = 'Favoritos';
                  });
                },
              ),
              Divider(color: const Color.fromARGB(31, 158, 158, 158)),
              ListTile(
                leading: Icon(Icons.payment, color: Colors.white),
                title: Text("Pagados", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentView = 'Pagados';
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Container _tabBarTeacher(BuildContext context) {
    return Container(
      color: Color(0xFF151515),
      child: TabBar(
        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 14, color: Colors.white),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorColor: Color(0xFF3B82F6),
        labelColor: Color(0xFF3B82F6),
        tabs: [
          Tab(text: "Sobre mi"),
          Tab(text: "Anuncios"),
          Tab(text: "Comentarios"),
          if (currentUser.isStudent && currentUser.id == widget.user.id)
            Tab(text: "Otros"),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border:
            currentUser.isStudent && !currentUser.isTeacher
                ? Border(bottom: BorderSide(width: 1, color: Color(0xFF3B82F6)))
                : null,
        color: Color(0xFF151515),
      ),
      width: double.infinity,
      padding: EdgeInsets.only(top: 60, bottom: 16, left: 16, right: 16),
      child: Column(
        children: [
          _profilePicture(context),
          const SizedBox(height: 15),
          Text(
            widget.user.username,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector _profilePicture(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.user.id == currentUser.id) _showConnectionOptions(context);
      },
      child: Stack(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundImage:
                widget.user.profilePicture.isEmpty
                    ? AssetImage('assets/defaultProfilePicture.png')
                    : NetworkImage(widget.user.profilePicture),
            backgroundColor: Colors.grey[800],
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color:
                    widget.user.connected == 'yes' ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConnectionOptions(BuildContext context) {
    AuthService authService = AuthService();
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 5,
            right: 5,
            bottom: 35,
            top: 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.circle, color: Colors.green),
                title: Text("Conectado", style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  await authService.updateUserConnectionStatus("yes");
                  setState(() {});
                },
              ),
              ListTile(
                leading: Icon(Icons.circle, color: Colors.grey),
                title: Text(
                  "Desconectado",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await authService.updateUserConnectionStatus("no");
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
>>>>>>> Stashed changes
    );
  }
}
