import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/Alertbox/snackBarAlert.dart';
import 'package:project/Bloc/Contact/contact_bloc.dart';
import 'package:project/ModelClass/Contact/getContactModel.dart';
import 'package:project/Reusable/color.dart';
import 'package:project/Reusable/image.dart';
import 'package:project/Reusable/text_styles.dart';
import 'package:project/UI/buttomnavigationbar/buttomnavigation.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ContactScreen extends StatelessWidget {
  final bool isDarkMode;
  const ContactScreen({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContactDentalBloc(),
      child: ContactScreenView(
        isDarkMode: isDarkMode,
      ),
    );
  }
}

class ContactScreenView extends StatefulWidget {
  final bool isDarkMode;
  const ContactScreenView({
    super.key,
    required this.isDarkMode,
  });

  @override
  ContactScreenViewState createState() => ContactScreenViewState();
}

class ContactScreenViewState extends State<ContactScreenView>
{
  GetContactModel getContactModel = GetContactModel();
  String? errorMessage;
  bool contactLoad = false;
  @override
  void initState() {
    super.initState();
    context.read<ContactDentalBloc>().add(ContactDental());
    contactLoad = true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final Color scaffoldBackgroundColor = widget.isDarkMode ? greyColor: whiteColor;
    final Color appBarBackgroundColor = widget.isDarkMode ? appBarBackgroundColordark : appPrimaryColor;

    final width = MediaQuery.of(context).size.width;

    final columns = width < 600 ? 1 : 2;

    final tileWidth = (width - 32 - (columns - 1) * 24) / columns;

    final thumbHeight = tileWidth * 9 / 16;

    final cardHeight = thumbHeight + 8 + 26 + 24 + 22;

    final Color highlightColor =
        widget.isDarkMode ? Colors.amber : Colors.pink[900]!;
    final Color textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final Color secondaryTextColor =
        widget.isDarkMode ? Colors.grey[400]! : Colors.grey;
    final Color cardBackgroundColor =
        widget.isDarkMode ? Colors.grey[800]! : Colors.white;
    final Color iconColor =
        widget.isDarkMode ? Colors.lightBlueAccent : Colors.purple;
    // Define a background color for the main card that wraps the contact cards
    final Color mainCardBackgroundColor =
        widget.isDarkMode ? Colors.grey[850]! : const Color(0xFFF8F5FB);

    Widget mainContainer() {
      return contactLoad
          ? const SpinKitChasingDots(color: appPrimaryColor, size: 30)
          : getContactModel.data == null
              ? Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.02),
                  alignment: Alignment.center,
                  child: Text(
                    "No Contacts found !!!",
                    style: MyTextStyle.f16(
                      appPrimaryColor,
                      weight: FontWeight.w500,
                    ),
                  ))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Get in Touch',
                        style:MyTextStyle.f36(
                          textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'We would love to hear from you. Feel free to reach out through any of the following channels.',
                        style:MyTextStyle.f16(
                          secondaryTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      // New parent card wrapping the three contact cards
                      Container(
                        padding: const EdgeInsets.all(
                            24.0), // Padding inside the main card
                        decoration: BoxDecoration(
                          color:
                              mainCardBackgroundColor, // Use the new background color
                          borderRadius: BorderRadius.circular(
                              16), // Slightly larger rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(
                                  0.2), // More prominent shadow for the main card
                              spreadRadius: 3,
                              blurRadius: 7,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 700) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: buildContactCard(
                                      icon: Icons.location_on,
                                      title: 'Address',
                                      content:
                                          "${getContactModel.data!.contact!.contactAddress}",
                                      cardBackgroundColor: cardBackgroundColor,
                                      textColor: textColor,
                                      secondaryTextColor: secondaryTextColor,
                                      iconColor: iconColor,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: buildContactCard(
                                      icon: Icons.phone,
                                      title: 'Phone',
                                      content:
                                          "${getContactModel.data!.contact!.contactPhone}",
                                      cardBackgroundColor: cardBackgroundColor,
                                      textColor: textColor,
                                      secondaryTextColor: secondaryTextColor,
                                      iconColor: iconColor,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: buildContactCard(
                                      icon: Icons.mail,
                                      title: 'Mail',
                                      content:
                                          "${getContactModel.data!.contact!.contactMail}",
                                      cardBackgroundColor: cardBackgroundColor,
                                      textColor: textColor,
                                      secondaryTextColor: secondaryTextColor,
                                      iconColor: iconColor,
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  buildContactCard(
                                    icon: Icons.location_on,
                                    title: 'Address',
                                    content:
                                        "${getContactModel.data!.contact!.contactAddress}",
                                    cardBackgroundColor: cardBackgroundColor,
                                    textColor: textColor,
                                    secondaryTextColor: secondaryTextColor,
                                    iconColor: iconColor,
                                  ),
                                  const SizedBox(height: 20),
                                  buildContactCard(
                                    icon: Icons.phone,
                                    title: 'Phone',
                                    content:
                                        "${getContactModel.data!.contact!.contactPhone}",
                                    cardBackgroundColor: cardBackgroundColor,
                                    textColor: textColor,
                                    secondaryTextColor: secondaryTextColor,
                                    iconColor: iconColor,
                                  ),
                                  const SizedBox(height: 20),
                                  buildContactCard(
                                    icon: Icons.mail,
                                    title: 'Mail',
                                    content:
                                        "${getContactModel.data!.contact!.contactMail}",
                                    cardBackgroundColor: cardBackgroundColor,
                                    textColor: textColor,
                                    secondaryTextColor: secondaryTextColor,
                                    iconColor: iconColor,
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false,
        );
        return false; // Prevent default back action
      },
      child: Scaffold(
          backgroundColor: scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: appBarBackgroundColor,
            title: Row(
              children: [
                Image.asset(Images.logo1, height: 50, width: 50),
                const SizedBox(width: 10),
                Text(
                  'PAUL DENTAL CARE',
                  style:MyTextStyle.f20(
                    whiteColor
                  ),
                ),
              ],
            ),
            actions: [
              // IconButton(
              //   icon: Icon(
              //     widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              //     color: Colors.white, // Always white for visibility
              //   ),
              //   onPressed: () {
              //     setState(() {
              //       // widget.isDarkMode = !widget.isDarkMode;
              //     });
              //   },
              // ),
            ],
          ),
          body: BlocBuilder<ContactDentalBloc, dynamic>(
            buildWhen: ((previous, current) {
              debugPrint("current:$current");
              if (current is GetContactModel) {
                getContactModel = current;
                if (current.errorResponse != null) {
                  if (current.errorResponse!.errors != null &&
                      current.errorResponse!.errors!.isNotEmpty) {
                    errorMessage = current.errorResponse!.errors![0].message ??
                        "Something went wrong";
                  } else {
                    errorMessage = "Something went wrong";
                  }
                  showToast("$errorMessage", context, color: false);
                  setState(() {
                    contactLoad = false;
                  });
                } else if (getContactModel.success == true) {
                  if (getContactModel.data?.status == true) {
                    setState(() {
                      contactLoad = false;
                    });
                  } else if (getContactModel.data?.status == false) {
                    debugPrint("getContactModel:${getContactModel.message}");
                    setState(() {
                      showToast("${getContactModel.message}", context,
                          color: false);
                      contactLoad = false;
                    });
                  }
                }
                return true;
              }
              return false;
            }),
            builder: (context, dynamic) {
              return mainContainer();
            },
          )),
    );
  }

  Widget buildContactCard({
    required IconData icon,
    required String title,
    required String content,
    required Color cardBackgroundColor,
    required Color textColor,
    required Color secondaryTextColor,
    required Color iconColor,
  }) {
    return Container(
      height: 250, // Fixed height to ensure all cards are the same size
      width: 250,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // No mainAxisSize.min or Flexible/Expanded on content here,
        // the fixed height of the Container manages the layout.
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1), // Light background for icon
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Times New Roman',
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontFamily: 'Times New Roman',
              color: secondaryTextColor,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
            maxLines: 2, // Allow content to wrap
            overflow:
                TextOverflow.ellipsis, // Add ellipsis if it still overflows
          ),
        ],
      ),
    );
  }
}
