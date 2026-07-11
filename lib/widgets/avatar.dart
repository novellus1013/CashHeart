import 'package:cash_heart/constants/avatar_tints.dart';
import 'package:flutter/material.dart';

/// 이름 첫 글자 + person별 고정 tint. design_handoff `Avatar` 이식.
class Avatar extends StatelessWidget {
  final String name;

  /// person.id 등 person별로 고정되는 값 — tint를 순환 배정하는 시드.
  final int tintSeed;
  final double size;

  const Avatar({
    super.key,
    required this.name,
    required this.tintSeed,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final tint = avatarTintFor(tintSeed);
    final initial = name.isEmpty ? '?' : name.substring(0, 1);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: tint.background, shape: BoxShape.circle),
      child: Text(
        initial,
        style: TextStyle(
          fontFamily: 'pretendard',
          fontWeight: FontWeight.w600,
          fontSize: size * 0.4,
          color: tint.foreground,
        ),
      ),
    );
  }
}
