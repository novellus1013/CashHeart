import 'package:cash_heart/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final FormFieldValidator<String?> validator;

  TextInputType? keyboardType;
  int? maxLines;
  int? maxLength;
  String? suffix;

  CustomTextFormField({
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
          color: cashBlueColor,
        )),
      ),
      validator: validator,
    );
  }
}


// (value) {
//         if (value == null || value.isEmpty) {
//           return '금액을 입력해주세요.';
//         }

//         final number = int.tryParse(value);

//         if (number == null) {
//           return '올바른 숫자를 입력해주세요.';
//         }

//         if (number <= 0) {
//           return '금액은 0보다 커야 합니다.';
//         }

//         return null;
//       },