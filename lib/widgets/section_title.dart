import 'package:cash_heart/theme/app_colors.dart';
import 'package:cash_heart/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// design_handoff `SectionTitle` 이식 — 카드 내 소제목("거래 내역" 등).
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Text(title, style: AppTextStyles.sectionTitle.copyWith(color: colors.text));
  }
}
