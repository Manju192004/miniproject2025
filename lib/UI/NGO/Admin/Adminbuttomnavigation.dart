import 'package:flutter/material.dart';
import 'package:project/UI/Feedback/feedback.dart';
import 'package:project/UI/Home_screen/home_screen.dart';
import 'package:project/UI/NGO/Admin/AdminHomepage.dart' show  AdminHomeScreen;
import 'package:project/UI/NGO/Admin/AdminViewRequest.dart' show AdminViewRequestsScreen;
import 'package:project/UI/NGO/Admin/Adminreports.dart';
import 'package:project/UI/NGO/Admin/ViewDonorProfile.dart' show DonorProfileScreen;
import 'package:project/UI/NGO/Admin/ViewNGOprofile.dart' show NGOProfileScreen;

import 'package:project/UI/Profile/profile.dart';
import 'package:project/UI/adddonation/add_donation.dart';

import 'AdminViewfeedback.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    AdminHomeScreen(),
    AdminViewRequestsScreen(),
    DonorProfileScreen(),
    FeedbackScreen(),
    NGOProfileScreen(),
    ReportsScreen(),
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
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNavItem(Icons.inbox, 'NgoRequests', 1),
          _buildNavItem(Icons.person, 'Donorprofile', 2),
          _buildNavItem(Icons.chat, 'feedback', 3),
          _buildNavItem(Icons.person, 'NGOProfile', 4),
          _buildNavItem(Icons.bar_chart, 'Reports', 5),
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