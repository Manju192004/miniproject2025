import 'package:flutter/material.dart';
import 'package:project/UI/DonationRequestScreen/DonationRequestScreen.dart';
import 'package:project/UI/Feedback/feedback.dart';
import 'package:project/UI/Home_screen/home_screen.dart';
import 'package:project/UI/NGO/NGO%20viewrequest.dart' hide DonationRequestScreen;
import 'package:project/UI/NGO/ngohomescreen.dart';
import 'package:project/UI/NGO/ngoprofile.dart' show NgoProfileScreen;
import 'package:project/UI/NGO/request_status.dart' show RequestStatus;

import 'package:project/UI/Profile/profile.dart';
import 'package:project/UI/adddonation/add_donation.dart';
import 'package:project/main.dart' show MyApp;

class NgoDashboardScreen extends StatefulWidget {
  const NgoDashboardScreen({super.key});

  @override
  State<NgoDashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<NgoDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [


    NgoHomeScreen(),
    DonationRequestScreen(),
    //MyApp(),
    RequestStatus(),
    FeedbackFormScreen(),
    NgoProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
        ),
      ),
    );
  }
}

class RequestView {
  const RequestView();
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'NgoHome', 0),
          _buildNavItem(Icons.remove_red_eye_sharp, 'View Donations', 1),
          _buildNavItem(Icons.list_alt, 'Request Status', 2),
          _buildNavItem(Icons.feedback, 'Feedback', 3),
          _buildNavItem(Icons.person, 'Profile', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.green : Colors.black,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            label,
            style: TextStyle(
              color: isSelected ? Colors.green : Colors.black,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}