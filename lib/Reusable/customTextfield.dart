import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/Reusable/color.dart'; // Reused from refactored color.dart
import 'package:project/Reusable/formatter.dart'; // Reused from refactored formatter.dart
import 'package:project/Reusable/text_styles.dart'; // Reused from refactored text_styles.dart

/// A customizable text input field widget for the application.
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.hint,
    this.readOnly = false, // Default to false for common use case
    required this.controller,
    this.baseColor = appPrimaryColor, // Default color for focus border
    this.borderColor = appGreyColor, // Default color for enabled border
    this.errorColor = redColor, // Default color for error border
    this.inputType = TextInputType.text, // Default to text input type
    this.obscureText = false, // Default to not obscure text
    this.maxLength = TextField.noMaxLength, // Default to no length limit
    this.maxLine,
    this.onChanged,
    this.onTap,
    this.validator,
    this.showSuffixIcon = false,
    this.suffixIcon,
    this.countryCodePicker,
    this.prefixText,
    this.textInputFormatter, // Renamed for clarity and Dart naming conventions
    this.isUpperCase = false,
    this.enableNricFormatter = false,
    this.height,
  });

  final String hint;
  final bool readOnly;
  final TextEditingController controller;
  final Color baseColor;
  final Color borderColor;
  final Color errorColor;
  final TextInputType inputType;
  final bool obscureText;
  final int maxLength;
  final int? maxLine;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final bool showSuffixIcon;
  final Widget? suffixIcon;
  final Widget? countryCodePicker;
  final String? prefixText;
  final FilteringTextInputFormatter? textInputFormatter; // Renamed
  final bool isUpperCase;
  final bool enableNricFormatter;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
      children: [
        if (countryCodePicker != null) countryCodePicker!,
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10), // Consistent margin
            child: TextSelectionTheme(
              data: const TextSelectionThemeData(
                cursorColor: appPrimaryColor,
                selectionColor: appPrimaryColor,
                selectionHandleColor: appPrimaryColor,
              ),
              child: TextFormField(
                style: MediaQuery.of(context).size.width < 650
                    ? MyTextStyle.f16(blackColor, weight: FontWeight.w400) // Reused from text_styles.dart and color.dart
                    : MyTextStyle.f20(blackColor, weight: FontWeight.w400), // Reused from text_styles.dart and color.dart
                controller: controller,
                readOnly: readOnly,
                obscureText: obscureText,
                keyboardType: inputType,
                expands: false,
                textCapitalization: isUpperCase
                    ? TextCapitalization.characters
                    : TextCapitalization.none,
                inputFormatters: [
                  if (textInputFormatter != null) textInputFormatter!, // Using renamed property
                  if (isUpperCase)
                    FilteringTextInputFormatter.allow(RegExp("[A-Z0-9 ]")),
                  if (enableNricFormatter) NricFormatter(separator: '-'),
                  LengthLimitingTextInputFormatter(maxLength),
                ],
                maxLength: maxLength,
                maxLines: maxLine ?? 1,
                onChanged: onChanged,
                onTap: onTap,
                validator: validator,
                textAlignVertical: TextAlignVertical.center, // Center text vertically in the field
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: height ?? 12.0, // Adjusted default content padding slightly
                    horizontal: 12.0,
                  ),
                  counterText: "", // Hides the default maxLength counter
                  hintText: hint,
                  hintStyle: MediaQuery.of(context).size.width < 650
                      ? MyTextStyle.f14(greyColor, weight: FontWeight.w300) // Reused
                      : MyTextStyle.f18(greyColor, weight: FontWeight.w300), // Reused
                  prefixText: prefixText,
                  prefixStyle: MediaQuery.of(context).size.width < 650
                      ? MyTextStyle.f14(blackColor, weight: FontWeight.w300) // Reused
                      : MyTextStyle.f18(blackColor, weight: FontWeight.w300), // Reused
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: borderColor), // Reused from color.dart
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: borderColor), // Reused
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: baseColor), // Reused
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: errorColor), // Reused
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedErrorBorder: OutlineInputBorder( // Added focusedErrorBorder for better UX
                    borderSide: BorderSide(color: errorColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: showSuffixIcon ? suffixIcon : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}