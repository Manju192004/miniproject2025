import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/Bloc/demo/demo_bloc.dart';
import 'package:project/Bloc/demo/demo_bloc.dart'; // Assuming this path is correct for your project
import 'package:project/Reusable/color.dart'; // Assuming this path is correct for your project

class SchemesScreen extends StatelessWidget {
  final bool isDarkMode;

  const SchemesScreen({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // For All Schemes, State Schemes, Central Schemes, Departmentwise Schemes
      child: BlocProvider(
        create: (_) => DemoBloc(),
        child: SchemesScreenView(isDarkMode: isDarkMode),
      ),
    );
  }
}

class SchemesScreenView extends StatefulWidget {
  final bool isDarkMode;

  const SchemesScreenView({
    super.key,
    required this.isDarkMode,
  });

  @override
  SchemesScreenViewState createState() => SchemesScreenViewState();
}

class SchemesScreenViewState extends State<SchemesScreenView> {
  String? errorMessage;
  bool loginLoad = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContainer() {
      // The content inside TabBarView
      return TabBarView(
        children: [
          Center(
            child: Text(
              'Content for All Schemes',
              // Text color needs to adapt to the scaffold background, not fixed white
              style: TextStyle(fontSize: 18, color: widget.isDarkMode ? Colors.white : Colors.black),
            ),
          ),
          Center(
            child: Text(
              'Content for State Schemes',
              style: TextStyle(fontSize: 18, color: widget.isDarkMode ? Colors.white : Colors.black),
            ),
          ),
          Center(
            child: Text(
              'Content for Central Schemes',
              style: TextStyle(fontSize: 18, color: widget.isDarkMode ? Colors.white : Colors.black),
            ),
          ),
          Center(
            child: Text(
              'Content for Departmentwise Schemes',
              style: TextStyle(fontSize: 18, color: widget.isDarkMode ? Colors.white : Colors.black),
            ),
          ),
        ],
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        bool? shouldExit = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text("Exit App"),
            content: const Text("Are you sure you want to exit?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text("Yes"),
              ),
            ],
          ),
        );

        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        // Scaffold background color respects dark mode
        // backgroundColor: scaffoldBackgroundColor,
        appBar: AppBar(
          // AppBar background color (uses appPrimaryColor in light mode)
          backgroundColor: appPrimaryColor,
          title: const Text(
            'Benefit Detection and Awareness',
            style: TextStyle(
              fontFamily: 'Times New Roman',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'All Schemes'),
              Tab(text: 'State Schemes'),
              Tab(text: 'Central Schemes'),
              Tab(text: 'Departmentwise Schemes'),
            ],
          ),
        ),
        body: BlocBuilder<DemoBloc, dynamic>(
          buildWhen: ((previous, current) {
            return false;
          }),
          builder: (context, dynamic) {
            return mainContainer();
          },
        ),
      ),
    );
  }
}