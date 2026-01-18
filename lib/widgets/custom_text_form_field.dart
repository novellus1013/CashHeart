import 'package:cash_heart/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final FormFieldValidator<String?> validator;

  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final String? suffix;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        suffix: suffix == null ? null : Text(suffix!),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
          color: Colors.black,
        )),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
          color: secondaryColor,
        )),
      ),
      validator: validator,
    );
  }
}
