import 'package:cash_heart/theme/app_colors.dart';
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
    final colors = Theme.of(context).extension<AppColors>()!;

    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      style: TextStyle(color: colors.text),
      decoration: InputDecoration(
        hintText: hintText,
        suffix: suffix == null ? null : Text(suffix!),
        border: OutlineInputBorder(),
        // 2026-07-11 검수: 하드코딩된 Colors.black 테두리가 다크 모드에서
        // 배경과 거의 구분되지 않던 문제 픽스.
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.secondary),
        ),
      ),
      validator: validator,
    );
  }
}
