import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project/UI/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project/UI/buttomnavigationbar/buttomnavigation.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  dynamic userId;
  dynamic roleId;
  int _activeDotIndex = 0;
  Timer? _dotTimer;

  @override
  void initState() {
    super.initState();
    _startDotAnimation();
    _loadData();
  }

  void _startDotAnimation() {
    _dotTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() {
        _activeDotIndex = (_activeDotIndex + 1) % 3; // 3 dots
      });
    });
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
    roleId = prefs.getString("roleId");

    debugPrint("SplashUserId: $userId");
    debugPrint("SplashRoleId: $roleId");

    await Future.delayed(const Duration(seconds: 3));
    _dotTimer?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _dotTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            // Center Image
            Image.asset(
              'assets/image/donationlogo.jpeg', // Replace with your asset
              height: size.height * 0.25,
            ),
            const Spacer(flex: 2),
            // Animated horizontal dots loader
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return _buildDot(index == _activeDotIndex);
              }),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 10 : 8,
      height: isActive ? 10 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
    );
  }
}