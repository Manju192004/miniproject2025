import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project/Reusable/color.dart';
import 'package:project/Reusable/image.dart';
import 'package:project/UI/buttomnavigationbar/buttomnavigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _maskController;
  late Animation<double> _maskAnimation;
  late AnimationController _contentFadeController;
  late Animation<double> _contentFadeAnimation;

  dynamic userId;
  dynamic roleId;

  @override
  void dispose() {
    _maskController.dispose();
    _contentFadeController.dispose();
    super.dispose();
  }

  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString("userId");
      roleId = prefs.getString("roleId");
    });
    debugPrint("SplashUserId:$userId");
    debugPrint("SplashRoleId:$roleId");
  }

  callApis() async {
    await getToken();
    await Future.delayed(const Duration(seconds: 1));
  }

  void onSplashFinished() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  void initState() {
    super.initState();

    _maskController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _maskAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _maskController, curve: Curves.easeOutCubic),
    );

    _contentFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentFadeController, curve: Curves.easeIn),
    );

    _maskController.forward();
    _maskController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _contentFadeController.forward();
        callApis().then((_) {
          Timer(const Duration(milliseconds: 1000), () => onSplashFinished());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: whiteColor,
      body: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: _contentFadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/image/logo.png',
                    height: size.height * 0.25,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "CITIZEN",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: appPrimaryColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Text(
                    "BENEFITS",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: appPrimaryColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No More Missed Opportunity,",
                    style: TextStyle(
                      fontSize: 18,
                      color: appPrimaryColor,
                    ),
                  ),
                  const Text(
                    "Get What You Deserve.",
                    style: TextStyle(
                      fontSize: 18,
                      color: appPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50.0),
                    // child: Divider(thickness: 2, color: Colors.teal),
                  ),
                  const SizedBox(height: 30),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(appPrimaryColor),
                  ),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _maskAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _maskAnimation.value > 0.01 ? 1.0 : 0.0,
                child: Transform.scale(
                  scale: _maskAnimation.value,
                  child: Container(
                    height: size.height,
                    width: size.width,
                    color: whiteColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
