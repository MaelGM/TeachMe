import 'package:flutter/material.dart';
import 'package:teachme/screens/pages.dart';
import 'package:teachme/service/navigation_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';

class NavBarPage extends StatefulWidget {
  static const routeName = 'nav';
  @override
  _NavBarPageState createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    HomePage(),
    SearchPage(),
    MessagesPage(),
    ProfilePage(user: currentUser),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      navIndexNotifier.addListener(_navIndexListener);
    });
  }

  void _onItemTapped(int index) {
    navIndexNotifier.value = index;
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navIndexListener() {
    final index = navIndexNotifier.value;
    if (_pageController.hasClients) {
      // Importante: verificar si tiene clientes
      _pageController.jumpToPage(index);
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    navIndexNotifier.removeListener(_navIndexListener);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: translate(context, "home"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 30),
            label: translate(context, "search"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline, size: 30),
            label: translate(context, "messages"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30),
            label: translate(context, "profile"),
          ),
        ],
      ),
    );
  }
}
