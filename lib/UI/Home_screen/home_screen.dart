import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/Reusable/color.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// New Department Model Class
class Department {
  final String name;
  final String logoPath;
  final int schemeCount;

  Department({
    required this.name,
    required this.logoPath,
    required this.schemeCount,
  });
}

class HomeScreen extends StatelessWidget {
  final bool isDarkMode;
  const HomeScreen({super.key, required this.isDarkMode});
  @override
  Widget build(BuildContext context) {
    return HomeScreenView(
      isDarkMode: isDarkMode,
    );
  }
}

class HomeScreenView extends StatefulWidget {
  final bool isDarkMode;
  const HomeScreenView({
    super.key,
    required this.isDarkMode,
  });

  @override
  HomeScreenViewState createState() => HomeScreenViewState();
}

class HomeScreenViewState extends State<HomeScreenView> {
  final PageController _carouselPageController = PageController(initialPage: 0);
  final PageController _newsEventsPageController = PageController(initialPage: 0);
  final PageController _smallTestimonialsPageController = PageController(initialPage: 0);
  final PageController _largeTestimonialPageController = PageController(initialPage: 0);

  Timer? _carouselTimer;
  Timer? _newsEventsTimer;
  Timer? _smallTestimonialsTimer;
  Timer? _largeTestimonialTimer;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  int _selectedStars = 5;

  final List<Department> departments = [
    Department(
      name: 'Healthcare',
      logoPath: 'assets/image/healthcare.jpg',
      schemeCount: 15,
    ),
    Department(
      name: 'Education and Learning',
      logoPath: 'assets/image/education.jpg',
      schemeCount: 10,
    ),
    Department(
      name: 'Agriculture and Rural Environment',
      logoPath: 'assets/image/agriculture.jpg',
      schemeCount: 8,
    ),
    Department(
      name: 'Social Welfare',
      logoPath: 'assets/image/socialwelfare.jpg',
      schemeCount: 20,
    ),
    Department(
      name: 'Employment',
      logoPath: 'assets/image/employment.jpg',
      schemeCount: 12,
    ),
    Department(
      name: 'Infrastructure',
      logoPath: 'assets/image/infrastructure.jpg',
      schemeCount: 7,
    ),
    Department(
      name: 'Banking,Financial Services and Insurance',
      logoPath: 'assets/image/banking.jpg',
      schemeCount: 7,
    ),
    Department(
      name: 'Business & Entrepreneurship',
      logoPath: 'assets/image/business.jpg',
      schemeCount: 7,
    ),
    Department(
      name: 'Housing & Shelter',
      logoPath: 'assets/image/housing.jpg',
      schemeCount: 7,
    ),
    Department(
      name: 'Public Safety, Law & Justice',
      logoPath: 'assets/image/safety.jpg',
      schemeCount: 7,
    ),
    Department(
      name: 'Science, IT & Communications',
      logoPath: 'assets/image/science.jpg',
      schemeCount: 7,
    ),
    Department(
      name: 'Skills & Employment',
      logoPath: 'assets/image/employment.jpg',
      schemeCount: 7,
    ),
    Department(
      name: 'Social welfare & Empowerment',
      logoPath: 'assets/image/socialwelfare.jpg',
      schemeCount: 7,
    ),
    Department(
      name: 'Sports & Culture',
      logoPath: 'assets/image/sports.jpg',
      schemeCount: 7,
    ),
    Department(
      name: 'Transport & Infrastruture',
      logoPath: 'assets/image/transport.jpg',
      schemeCount: 7,
    ),
    Department(
      name: 'Travel & Tourism',
      logoPath: 'assets/image/tourism.jpg',
      schemeCount: 7,
    ),
    Department(
      name: 'Utility & Sanitation',
      logoPath: 'assets/image/utility.jpg',
      schemeCount: 7,
    ),
    Department(
      name: 'Women and Child',
      logoPath: 'assets/image/women_child.jpg',
      schemeCount: 10,
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _carouselPageController.dispose();
    _newsEventsPageController.dispose();
    _smallTestimonialsPageController.dispose();
    _largeTestimonialPageController.dispose();
    _carouselTimer?.cancel();
    _newsEventsTimer?.cancel();
    _smallTestimonialsTimer?.cancel();
    _largeTestimonialTimer?.cancel();
    _fullNameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Widget mainContainer() {
      return SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/image/banner.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.red,
                          size: 60,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Benefits available by Department wise',
                style: TextStyle(
                  color: appPrimaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Container(
                height: 2.0,
                width: double.infinity,
                color: appPrimaryColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16.0),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.8,
              ),
              itemCount: departments.length,
              itemBuilder: (context, index) {
                final department = departments[index];
                return InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tapped on ${department.name}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  // splashColor: darkModeBannerColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  child: Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Image.asset(
                            department.logoPath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(child: Icon(Icons.error_outline, color: Colors.red, size: 40));
                            },
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '${department.schemeCount} Schemes',
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  department.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
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
        // backgroundColor: scaffoldBackgroundColor,
        appBar: AppBar(
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
        ),
        body: mainContainer(),
      ),
    );
  }
}