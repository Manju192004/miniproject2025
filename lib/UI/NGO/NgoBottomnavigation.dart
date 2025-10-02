import 'package:flutter/material.dart';
import 'package:project/UI/Feedback/feedback.dart';
import 'package:project/UI/Home_screen/home_screen.dart';
import 'package:project/UI/NGO/NGOviewrequest.dart' show NGOViewRequestScreen;

import 'package:project/UI/NGO/ngohomescreen.dart';
import 'package:project/UI/NGO/ngoprofile.dart' show NgoProfileScreen;
import 'package:project/UI/NGO/ngorequest_status.dart';

class NgoDashboardScreen extends StatefulWidget {
  const NgoDashboardScreen({super.key});

  @override
  State<NgoDashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<NgoDashboardScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Prepare multiple requests for RequestStatus
    final List<RequestItem> requestItems = [
      RequestItem(
        name: 'Rice Biryani',
        plates: '10 plates',
        status: 'Pending',
        dateTime: '02-10-2025 10:00 AM',
        donorName: 'Donor Name',
        contact: '9876543210',
        location: 'Chennai, TN',
      ),
      RequestItem(
        name: 'Dosa',
        plates: '15 plates',
        status: 'Approved',
        dateTime: '01-10-2025 08:30 AM',
        donorName: 'Another Donor',
        contact: '9123456780',
        location: 'Coimbatore, TN',
      ),
      RequestItem(
        name: 'Idly',
        plates: '12 plates',
        status: 'Rejected',
        dateTime: '30-09-2025 09:15 AM',
        donorName: 'Third Donor',
        contact: '9012345678',
        location: 'Madurai, TN',
      ),
    ];

    _pages = [
      const NgoHomeScreen(),
       NGOViewRequestScreen(),
      RequestStatus(),
      const FeedbackFormScreen(),
      const NgoProfileScreen(),
    ];
  }

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
          _buildNavItem(Icons.remove_red_eye_sharp, 'View Requests', 1),
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
