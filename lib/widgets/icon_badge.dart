import 'package:flutter/material.dart';

/// design_handoff `IconBadge` 이식 — pastel 원형 배경 + 아이콘.
class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? soft;
  final double size;
  final double? iconSize;

  const IconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.soft,
    this.size = 38,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: soft ?? color, shape: BoxShape.circle),
      child: Icon(
        icon,
        size: iconSize ?? size * 0.52,
        color: soft != null ? color : Colors.white,
      ),
    );
  }
}
