import 'package:flutter/material.dart'; // Changed from Cupertino for Material widgets
import 'package:project/Reusable/color.dart';
import 'package:project/Reusable/text_styles.dart'; // Import MyTextStyle

/// Provides standard vertical spacing using a [SizedBox].
Widget verticalSpace({double height = 8.0}) {
  return SizedBox(
    height: height,
  );
}

/// Provides standard horizontal spacing using a [SizedBox].
Widget horizontalSpace({double width = 8.0}) {
  return SizedBox(
    width: width,
  );
}

/// A custom application button widget.
///
/// This button is designed with a specific primary color background and white text.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    this.height,
    this.width,
    this.fontSize,
    required this.buttonText, // Made required for clarity
    this.color,
    this.onTap, // Added onTap callback
  });

  final double? height;
  final double? width;
  final double? fontSize; // Font size is passed as a parameter
  final String buttonText;
  final Color? color;
  final VoidCallback? onTap; // Callback for button press

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // Using GestureDetector for tap functionality
      onTap: onTap,
      child: Center(
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: color ?? appPrimaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              buttonText,
              style: MyTextStyle.f16( // Using MyTextStyle for consistency
                whiteColor,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}