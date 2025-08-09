import 'package:flutter/material.dart';
import 'package:project/Reusable/color.dart';
import 'package:project/UI/Home_screen/home_screen.dart';
import 'package:project/UI/contact_screen/contact_screen.dart';
import 'package:project/UI/schemes_screen/schemes.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';



class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(
      isDarkMode: false,
    ),
    SchemesScreen(isDarkMode: false,),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          isDarkMode: isDarkMode,
        ),
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDarkMode;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isDarkMode,
  });

  final List<BottomNavigationBarItem> navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Schemes'),
    BottomNavigationBarItem(icon: Icon(Icons.map), label: 'States'),
    BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chatbot'),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      showUnselectedLabels: true,
      selectedFontSize: 14,
      unselectedFontSize: 12,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: isDarkMode ? Colors.amber : appPrimaryColor,
      unselectedItemColor:
          isDarkMode ? Colors.grey[600] : blackColor.withOpacity(0.5),
      backgroundColor: isDarkMode ? Colors.grey[800] : whiteColor,
      onTap: onTap,
      items: navItems,
    );
  }
}
